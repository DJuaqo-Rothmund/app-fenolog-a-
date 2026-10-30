import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'database.dart';
import 'passwords.dart';

typedef User = ({String id, String email, String name, String role});

/// API del servidor de sincronización.
///
/// - `POST /auth/login` → token para el teléfono.
/// - `GET /sync/pull?since=N` → filas cambiadas después del correlativo N.
/// - `POST /sync/push` → filas cambiadas en el teléfono; gana la escritura
///   más reciente (`updated_at`).
/// - `PUT/GET /photos/<id>` → archivos de foto.
/// - `/users` → equipo (solo el dueño).
class SyncServer {
  SyncServer(this.db, {required this.photosDir});
  final Pool<void> db;
  final Directory photosDir;

  static const maxPullRows = 1000;
  static const maxPhotoBytes = 25 * 1024 * 1024;

  /// Crea las tablas y, si no hay usuarios, el dueño inicial.
  Future<void> init({String? ownerEmail, String? ownerPassword}) async {
    await migrate(db);
    await photosDir.create(recursive: true);
    final count = (await db.execute('SELECT count(*) FROM users')).first.first as int;
    if (count == 0 && ownerEmail != null && ownerPassword != null) {
      await _createUser(email: ownerEmail, name: 'Dueño', role: 'owner', password: ownerPassword);
    }
  }

  Handler get handler {
    final r = Router()
      ..get('/health', (Request _) => _json({'ok': true}))
      ..post('/auth/login', _login)
      ..get('/auth/me', _auth((req, user) => _json({'user': _userJson(user)})))
      ..post('/auth/logout', _auth(_logout))
      ..get('/sync/pull', _auth(_pull))
      ..post('/sync/push', _auth(_push, write: true))
      ..put('/photos/<id>', (Request req, String id) => _auth((r, u) => _putPhoto(r, u, id), write: true)(req))
      ..get('/photos/<id>', (Request req, String id) => _auth((r, u) => _getPhoto(id))(req))
      ..get('/users', _auth(_listUsers, owner: true))
      ..post('/users', _auth(_addUser, owner: true))
      ..patch('/users/<id>', (Request req, String id) => _auth((r, u) => _updateUser(r, u, id), owner: true)(req));
    return const Pipeline().addMiddleware(_errors).addHandler(r.call);
  }

  // --- Utilidades -----------------------------------------------------------

  static Response _json(Object body, [int status = 200]) =>
      Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json; charset=utf-8'});

  static Response _error(int status, String message) => _json({'error': message}, status);

  static Middleware get _errors =>
      (inner) => (req) async {
        try {
          return await inner(req);
        } on _HttpError catch (e) {
          return _error(e.status, e.message);
        } on FormatException {
          return _error(400, 'Solicitud mal formada.');
        }
      };

  static Future<Map<String, dynamic>> _body(Request req) async {
    final data = jsonDecode(await req.readAsString());
    if (data is! Map<String, dynamic>) throw const FormatException();
    return data;
  }

  static Map<String, Object?> _userJson(User u) => {'id': u.id, 'email': u.email, 'name': u.name, 'role': u.role};

  /// Exige un token válido. [write]: no se permite a lectores. [owner]: solo el dueño.
  Handler _auth(FutureOr<Response> Function(Request, User) handler, {bool write = false, bool owner = false}) =>
      (req) async {
        final header = req.headers['authorization'] ?? '';
        if (!header.startsWith('Bearer ')) return _error(401, 'Falta iniciar sesión.');
        final rows = await db.execute(
          Sql.named('''
UPDATE tokens t SET last_used_at = now() FROM users u
WHERE t.token_hash = @h AND u.id = t.user_id AND NOT u.disabled
RETURNING u.id, u.email, u.name, u.role'''),
          parameters: {'h': sha256Hex(header.substring(7))},
        );
        if (rows.isEmpty) return _error(401, 'La sesión no es válida o expiró.');
        final m = rows.first.toColumnMap();
        final user = (
          id: m['id'] as String,
          email: m['email'] as String,
          name: m['name'] as String,
          role: m['role'] as String,
        );
        if (owner && user.role != 'owner') return _error(403, 'Solo el dueño puede hacer esto.');
        if (write && user.role == 'viewer') return _error(403, 'Tu usuario es de solo lectura.');
        return handler(req, user);
      };

  Future<String> _createUser({
    required String email,
    required String name,
    required String role,
    required String password,
  }) async {
    final id = randomToken(12);
    await db.execute(
      Sql.named('INSERT INTO users (id, email, name, role, password_hash) VALUES (@id, @e, @n, @r, @p)'),
      parameters: {'id': id, 'e': email.trim().toLowerCase(), 'n': name.trim(), 'r': role, 'p': hashPassword(password)},
    );
    return id;
  }

  // --- Sesión ---------------------------------------------------------------

  Future<Response> _login(Request req) async {
    final b = await _body(req);
    final email = (b['email'] as String? ?? '').trim().toLowerCase();
    final rows = await db.execute(
      Sql.named('SELECT id, email, name, role, password_hash FROM users WHERE email = @e AND NOT disabled'),
      parameters: {'e': email},
    );
    if (rows.isEmpty ||
        !verifyPassword(b['password'] as String? ?? '', rows.first.toColumnMap()['password_hash'] as String)) {
      return _error(401, 'Correo o contraseña incorrectos.');
    }
    final m = rows.first.toColumnMap();
    final token = randomToken();
    await db.execute(
      Sql.named('INSERT INTO tokens (token_hash, user_id, device) VALUES (@h, @u, @d)'),
      parameters: {'h': sha256Hex(token), 'u': m['id'], 'd': (b['device'] as String? ?? '').trim()},
    );
    return _json({
      'token': token,
      'user': {'id': m['id'], 'email': m['email'], 'name': m['name'], 'role': m['role']},
    });
  }

  Future<Response> _logout(Request req, User user) async {
    await db.execute(
      Sql.named('DELETE FROM tokens WHERE token_hash = @h'),
      parameters: {'h': sha256Hex(req.headers['authorization']!.substring(7))},
    );
    return _json({'ok': true});
  }

  // --- Sincronización -------------------------------------------------------

  Future<Response> _pull(Request req, User user) async {
    final since = int.tryParse(req.url.queryParameters['since'] ?? '0') ?? 0;
    final limit = (int.tryParse(req.url.queryParameters['limit'] ?? '') ?? maxPullRows).clamp(1, maxPullRows);
    final rows = await db.execute(
      Sql.named('SELECT tbl, id, data, updated_at, seq FROM sync_rows WHERE seq > @s ORDER BY seq LIMIT @l'),
      parameters: {'s': since, 'l': limit + 1},
    );
    final page = rows.take(limit).map((r) => r.toColumnMap()).toList();
    return _json({
      'rows': [
        for (final r in page) {'table': r['tbl'], 'id': r['id'], 'data': r['data'], 'updatedAt': r['updated_at']},
      ],
      'next': page.isEmpty ? since : page.last['seq'],
      'more': rows.length > limit,
    });
  }

  /// Cada fila se acepta si es más nueva (o igual) que la guardada.
  Future<Response> _push(Request req, User user) async {
    final b = await _body(req);
    final rows = (b['rows'] as List? ?? const []).cast<Map<String, dynamic>>();
    var accepted = 0;
    final stale = <String>[];
    await db.runTx((tx) async {
      // Las subidas se hacen de a una: así los correlativos se confirman en
      // orden y quien descarga «desde N» nunca se salta filas.
      await tx.execute('SELECT pg_advisory_xact_lock(4242)');
      for (final r in rows) {
        final table = r['table'] as String?;
        final data = r['data'];
        if (table == null || !syncTables.contains(table) || data is! Map<String, dynamic>) {
          throw _HttpError(400, 'Fila no válida.');
        }
        final id = data['id'];
        // Fecha de modificación de la fila, en milisegundos desde 1970.
        final updatedAt = r['updatedAt'];
        if (id is! String || updatedAt is! int) throw _HttpError(400, 'Fila sin id o fecha.');
        final result = await tx.execute(
          Sql.named('''
INSERT INTO sync_rows (tbl, id, data, updated_at, seq, updated_by)
VALUES (@t, @id, @d, @u, nextval('sync_seq'), @by)
ON CONFLICT (tbl, id) DO UPDATE
  SET data = EXCLUDED.data, updated_at = EXCLUDED.updated_at, seq = EXCLUDED.seq,
      updated_by = EXCLUDED.updated_by, received_at = now()
  WHERE sync_rows.updated_at <= EXCLUDED.updated_at
RETURNING seq'''),
          parameters: {'t': table, 'id': id, 'd': TypedValue(Type.jsonb, data), 'u': updatedAt, 'by': user.id},
        );
        if (result.isEmpty) {
          stale.add('$table/$id');
        } else {
          accepted++;
        }
      }
    });
    return _json({'accepted': accepted, 'stale': stale});
  }

  // --- Fotos ----------------------------------------------------------------

  static final _safeId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  File _photoFile(String id) {
    if (!_safeId.hasMatch(id)) throw _HttpError(400, 'Identificador de foto no válido.');
    return File('${photosDir.path}/$id.jpg');
  }

  Future<Response> _putPhoto(Request req, User user, String id) async {
    final file = _photoFile(id);
    final tmp = File('${file.path}.subiendo');
    final sink = tmp.openWrite();
    var size = 0;
    try {
      await for (final chunk in req.read()) {
        size += chunk.length;
        if (size > maxPhotoBytes) throw _HttpError(413, 'La foto es demasiado grande.');
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
    if (size == 0) {
      await tmp.delete();
      return _error(400, 'La foto está vacía.');
    }
    await tmp.rename(file.path);
    await db.execute(
      Sql.named('''
INSERT INTO photo_files (id, size, uploaded_by) VALUES (@id, @s, @u)
ON CONFLICT (id) DO UPDATE SET size = EXCLUDED.size, uploaded_by = EXCLUDED.uploaded_by, uploaded_at = now()'''),
      parameters: {'id': id, 's': size, 'u': user.id},
    );
    return _json({'ok': true, 'size': size});
  }

  Future<Response> _getPhoto(String id) async {
    final file = _photoFile(id);
    if (!await file.exists()) return _error(404, 'La foto aún no se ha subido.');
    return Response.ok(
      file.openRead(),
      headers: {'content-type': 'image/jpeg', 'content-length': '${await file.length()}'},
    );
  }

  // --- Equipo ---------------------------------------------------------------

  static const _roles = {'owner', 'editor', 'viewer'};

  Future<Response> _listUsers(Request req, User user) async {
    final rows = await db.execute('SELECT id, email, name, role, disabled FROM users ORDER BY created_at');
    return _json({
      'users': [for (final r in rows) r.toColumnMap()],
    });
  }

  Future<Response> _addUser(Request req, User user) async {
    final b = await _body(req);
    final email = (b['email'] as String? ?? '').trim();
    final password = b['password'] as String? ?? '';
    final role = b['role'] as String? ?? 'editor';
    if (!email.contains('@')) return _error(400, 'Correo no válido.');
    if (password.length < 8) return _error(400, 'La contraseña debe tener al menos 8 caracteres.');
    if (!_roles.contains(role)) return _error(400, 'Rol no válido.');
    final exists = await db.execute(
      Sql.named('SELECT 1 FROM users WHERE email = @e'),
      parameters: {'e': email.toLowerCase()},
    );
    if (exists.isNotEmpty) return _error(409, 'Ya existe un usuario con ese correo.');
    final id = await _createUser(email: email, name: b['name'] as String? ?? '', role: role, password: password);
    return _json({'id': id}, 201);
  }

  Future<Response> _updateUser(Request req, User user, String id) async {
    final b = await _body(req);
    if (id == user.id && (b['role'] != null && b['role'] != 'owner' || b['disabled'] == true)) {
      return _error(400, 'No puedes quitarte el rol de dueño ni desactivarte.');
    }
    if (b['role'] != null && !_roles.contains(b['role'])) return _error(400, 'Rol no válido.');
    final password = b['password'] as String?;
    if (password != null && password.length < 8) {
      return _error(400, 'La contraseña debe tener al menos 8 caracteres.');
    }
    final result = await db.execute(
      Sql.named('''
UPDATE users SET
  role = COALESCE(@r, role),
  disabled = COALESCE(@d, disabled),
  name = COALESCE(@n, name),
  password_hash = COALESCE(@p, password_hash)
WHERE id = @id RETURNING id'''),
      parameters: {
        'id': id,
        'r': TypedValue(Type.text, b['role']),
        'd': TypedValue(Type.boolean, b['disabled']),
        'n': TypedValue(Type.text, b['name']),
        'p': TypedValue(Type.text, password == null ? null : hashPassword(password)),
      },
    );
    if (result.isEmpty) return _error(404, 'Usuario no encontrado.');
    // Al desactivar o cambiar la contraseña se cierran sus sesiones.
    if (b['disabled'] == true || password != null) {
      await db.execute(Sql.named('DELETE FROM tokens WHERE user_id = @id'), parameters: {'id': id});
    }
    return _json({'ok': true});
  }
}

class _HttpError implements Exception {
  _HttpError(this.status, this.message);
  final int status;
  final String message;
}
