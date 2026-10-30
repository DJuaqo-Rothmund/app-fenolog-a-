import 'dart:convert';
import 'dart:io';

import 'package:frambitacora_server/server.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

/// Requiere un PostgreSQL de pruebas. Por defecto: localhost:5433, base
/// `frambitacora_test`, usuario `postgres` sin contraseña (ver docs/06-servidor.md).
Endpoint testEndpoint() {
  final env = Platform.environment;
  return Endpoint(
    host: env['TEST_DB_HOST'] ?? 'localhost',
    port: int.parse(env['TEST_DB_PORT'] ?? '5433'),
    database: env['TEST_DB_NAME'] ?? 'frambitacora_test',
    username: env['TEST_DB_USER'] ?? 'postgres',
    password: env['TEST_DB_PASSWORD'],
  );
}

void main() {
  late Pool<void> pool;
  late Directory photos;
  late Handler h;

  setUp(() async {
    pool = Pool.withEndpoints([testEndpoint()], settings: const PoolSettings(sslMode: SslMode.disable));
    await pool.execute('DROP TABLE IF EXISTS tokens, users, sync_rows, photo_files');
    await pool.execute('DROP SEQUENCE IF EXISTS sync_seq');
    photos = await Directory.systemTemp.createTemp('fotos_servidor');
    final server = SyncServer(pool, photosDir: photos);
    await server.init(ownerEmail: 'Duenno@Campo.cl', ownerPassword: 'clave-segura');
    h = server.handler;
  });

  tearDown(() async {
    await pool.close();
    await photos.delete(recursive: true);
  });

  Future<(int, dynamic)> call(String method, String path, {Object? body, String? token, List<int>? bytes}) async {
    final res = await h(
      Request(
        method,
        Uri.parse('http://x$path'),
        body: bytes ?? (body == null ? null : jsonEncode(body)),
        headers: {'authorization': ?(token == null ? null : 'Bearer $token')},
      ),
    );
    final raw = await res.read().expand((c) => c).toList();
    if (res.headers['content-type']?.startsWith('image/') ?? false) return (res.statusCode, raw);
    return (res.statusCode, raw.isEmpty ? null : jsonDecode(utf8.decode(raw)));
  }

  Future<String> login(String email, String password) async {
    final (status, body) = await call(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password, 'device': 'test'},
    );
    expect(status, 200, reason: '$body');
    return body['token'] as String;
  }

  Map<String, Object?> row(String id, int updatedAt, String name) => {
    'id': id,
    'updated_at': '2026-10-30T10:00:00.000',
    'deleted_at': null,
    'name': name,
  };

  test('contraseñas: PBKDF2 verificable y con sal distinta', () {
    final a = hashPassword('secreto');
    expect(verifyPassword('secreto', a), isTrue);
    expect(verifyPassword('otro', a), isFalse);
    expect(hashPassword('secreto'), isNot(a));
  });

  test('login: correo sin importar mayúsculas; errores claros', () async {
    expect(await login('duenno@campo.cl', 'clave-segura'), isNotEmpty);
    final (status, body) = await call('POST', '/auth/login', body: {'email': 'duenno@campo.cl', 'password': 'mala'});
    expect(status, 401);
    expect(body['error'], 'Correo o contraseña incorrectos.');
    expect((await call('GET', '/sync/pull')).$1, 401);
  });

  test('push y pull: correlativos, la escritura más reciente gana', () async {
    final t = await login('duenno@campo.cl', 'clave-segura');
    var (status, body) = await call(
      'POST',
      '/sync/push',
      token: t,
      body: {
        'rows': [
          {'table': 'varieties', 'data': row('v1', 100, 'Heritage'), 'updatedAt': 100},
          {'table': 'varieties', 'data': row('v2', 100, 'Tulameen'), 'updatedAt': 100},
        ],
      },
    );
    expect(status, 200);
    expect(body['accepted'], 2);

    // Una versión más antigua se descarta; una más nueva reemplaza.
    (status, body) = await call(
      'POST',
      '/sync/push',
      token: t,
      body: {
        'rows': [
          {'table': 'varieties', 'data': row('v1', 50, 'Antigua'), 'updatedAt': 50},
          {'table': 'varieties', 'data': row('v2', 200, 'Tulameen (corregida)'), 'updatedAt': 200},
        ],
      },
    );
    expect(body['accepted'], 1);
    expect(body['stale'], ['varieties/v1']);

    (status, body) = await call('GET', '/sync/pull?since=0', token: t);
    final rows = (body['rows'] as List).cast<Map<String, dynamic>>();
    expect(rows.map((r) => r['data']['name']), ['Heritage', 'Tulameen (corregida)']);
    final next = body['next'] as int;

    (status, body) = await call('GET', '/sync/pull?since=$next', token: t);
    expect(body['rows'], isEmpty);
    expect(body['next'], next);

    (status, body) = await call('GET', '/sync/pull?since=0&limit=1', token: t);
    expect(body['rows'], hasLength(1));
    expect(body['more'], isTrue);
  });

  test('rechaza tablas desconocidas', () async {
    final t = await login('duenno@campo.cl', 'clave-segura');
    final (status, _) = await call(
      'POST',
      '/sync/push',
      token: t,
      body: {
        'rows': [
          {'table': 'users', 'data': row('x', 1, 'x'), 'updatedAt': 1},
        ],
      },
    );
    expect(status, 400);
  });

  test('equipo: el dueño crea usuarios; el lector no puede escribir', () async {
    final owner = await login('duenno@campo.cl', 'clave-segura');
    var (status, body) = await call(
      'POST',
      '/users',
      token: owner,
      body: {'email': 'lector@campo.cl', 'name': 'Lector', 'role': 'viewer', 'password': 'lector-123'},
    );
    expect(status, 201);
    final viewerId = body['id'] as String;
    expect(
      (await call('POST', '/users', token: owner, body: {'email': 'lector@campo.cl', 'password': 'xxxxxxxx'})).$1,
      409,
    );

    final viewer = await login('lector@campo.cl', 'lector-123');
    expect((await call('GET', '/sync/pull', token: viewer)).$1, 200);
    (status, body) = await call('POST', '/sync/push', token: viewer, body: {'rows': []});
    expect(status, 403);
    expect(body['error'], 'Tu usuario es de solo lectura.');
    expect((await call('GET', '/users', token: viewer)).$1, 403);

    // Desactivar cierra sus sesiones.
    expect((await call('PATCH', '/users/$viewerId', token: owner, body: {'disabled': true})).$1, 200);
    expect((await call('GET', '/sync/pull', token: viewer)).$1, 401);

    (status, body) = await call('GET', '/users', token: owner);
    expect((body['users'] as List).map((u) => u['email']), ['duenno@campo.cl', 'lector@campo.cl']);
  });

  test('fotos: subir y descargar', () async {
    final t = await login('duenno@campo.cl', 'clave-segura');
    expect((await call('GET', '/photos/p1', token: t)).$1, 404);
    expect((await call('PUT', '/photos/p1', token: t, bytes: [1, 2, 3])).$1, 200);
    final (status, bytes) = await call('GET', '/photos/p1', token: t);
    expect(status, 200);
    expect(bytes, [1, 2, 3]);
    expect((await call('PUT', '/photos/..%2Fx', token: t, bytes: [1])).$1, 400);
  });

  test('cerrar sesión invalida el token', () async {
    final t = await login('duenno@campo.cl', 'clave-segura');
    expect((await call('POST', '/auth/logout', token: t)).$1, 200);
    expect((await call('GET', '/auth/me', token: t)).$1, 401);
  });
}
