import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../database.dart';
import '../photo_store.dart';
import '../sync_schema.dart';
import 'sync_api.dart';

/// Sesión guardada en el teléfono.
typedef SyncSession = ({String serverUrl, String token, SyncUser user});

class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.photosUp,
    required this.photosDown,
    this.readOnly = false,
  });
  final int pushed;
  final int pulled;
  final int photosUp;
  final int photosDown;

  /// El usuario es lector: sus cambios locales no se envían.
  final bool readOnly;
}

/// Motor de sincronización propio:
///
/// 1. **Enviar**: las filas anotadas en `sync_outbox` (por triggers) se mandan
///    al servidor.
/// 2. **Fotos**: los archivos pendientes se suben.
/// 3. **Recibir**: se piden las filas cambiadas desde el último correlativo
///    y se aplican; si la copia local es más nueva, se conserva («gana la
///    escritura más reciente»).
/// 4. **Fotos de otros**: se descargan las que faltan en el teléfono.
class SyncEngine {
  SyncEngine(this.db, this.photoStore, {http.Client? client}) : _http = client ?? http.Client();
  final AppDatabase db;
  final PhotoStore photoStore;
  final http.Client _http;

  static const _kServer = 'server_url', _kToken = 'token', _kUser = 'user', _kCursor = 'cursor';
  static const _kLastSync = 'last_sync', _kApplying = 'applying';
  static const _batch = 500;

  // --- Ajustes guardados en sync_meta ---------------------------------------

  Future<String?> _get(String key) async =>
      (await (db.select(db.syncMeta)..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.syncMeta)..where((m) => m.key.equals(key))).go();
    } else {
      await db.into(db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(key: key, value: value));
    }
  }

  Future<SyncSession?> session() async {
    final url = await _get(_kServer), token = await _get(_kToken), user = await _get(_kUser);
    if (url == null || token == null || user == null) return null;
    return (serverUrl: url, token: token, user: userFromJson(jsonDecode(user) as Map<String, dynamic>));
  }

  Stream<SyncSession?> watchSession() => db.select(db.syncMeta).watch().asyncMap((_) => session());

  Future<DateTime?> lastSync() async => DateTime.tryParse(await _get(_kLastSync) ?? '');

  Stream<int> watchPending() {
    final count = db.syncOutbox.seq.count();
    return (db.selectOnly(db.syncOutbox)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  SyncApi api(SyncSession s) => SyncApi(_http, s.serverUrl, token: s.token);

  /// Inicia sesión. Si es otro servidor que el anterior, se vuelve a recibir todo.
  Future<SyncSession> login({
    required String serverUrl,
    required String email,
    required String password,
    String device = '',
  }) async {
    var url = serverUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'https://$url';
    final r = await SyncApi(_http, url).login(email.trim(), password, device: device);
    final previous = await _get(_kServer);
    await db.transaction(() async {
      if (previous != url) await _set(_kCursor, '0');
      await _set(_kServer, url);
      await _set(_kToken, r.token);
      await _set(_kUser, jsonEncode(userToJson(r.user)));
    });
    return (serverUrl: url, token: r.token, user: r.user);
  }

  Future<void> logout() async {
    final s = await session();
    if (s != null) {
      try {
        await api(s).logout();
      } on SyncException {
        // Sin conexión: igual se olvida el token en el teléfono.
      }
    }
    await _set(_kToken, null);
    await _set(_kUser, null);
  }

  // --- Sincronización -------------------------------------------------------

  Future<SyncReport> sync({void Function(String status)? onStatus}) async {
    final s = await session();
    if (s == null) throw SyncException('Primero inicia sesión en el servidor.');
    final client = api(s);
    // Rol actualizado (el dueño pudo cambiarlo).
    final user = await client.me();
    await _set(_kUser, jsonEncode(userToJson(user)));
    final readOnly = user.role == 'viewer';

    var pushed = 0, photosUp = 0;
    if (!readOnly) {
      onStatus?.call('Enviando cambios…');
      pushed = await _push(client);
      if (!kIsWeb) {
        onStatus?.call('Subiendo fotos…');
        photosUp = await _uploadPhotos(client, onStatus);
      }
    }
    onStatus?.call('Recibiendo cambios…');
    final pulled = await _pull(client);
    // En el navegador las fotos se muestran directo desde el servidor.
    var photosDown = 0;
    if (!kIsWeb) {
      onStatus?.call('Descargando fotos…');
      photosDown = await _downloadPhotos(client, onStatus);
    }
    await _set(_kLastSync, DateTime.now().toIso8601String());
    return SyncReport(pushed: pushed, pulled: pulled, photosUp: photosUp, photosDown: photosDown, readOnly: readOnly);
  }

  Future<int> _push(SyncApi client) async {
    var total = 0;
    while (true) {
      final entries =
          await (db.select(db.syncOutbox)
                ..orderBy([(o) => OrderingTerm(expression: o.seq)])
                ..limit(_batch))
              .get();
      if (entries.isEmpty) return total;
      final maxSeq = entries.last.seq;
      final byTable = <String, Set<String>>{};
      for (final e in entries) {
        (byTable[e.tbl] ??= {}).add(e.rowId);
      }
      final rows = <SyncRow>[];
      // Se envían en el orden de las tablas (padres antes que hijos).
      for (final table in syncedTables) {
        final ids = byTable[table];
        if (ids == null) continue;
        final local = localOnlyColumns[table] ?? const {};
        final found = await db
            .customSelect(
              'SELECT * FROM $table WHERE id IN (${List.filled(ids.length, '?').join(', ')})',
              variables: [for (final id in ids) Variable.withString(id)],
            )
            .get();
        for (final r in found) {
          final data = {
            for (final e in r.data.entries)
              if (!local.contains(e.key)) e.key: e.value,
          };
          rows.add((table: table, data: data, updatedAt: _millis(data['updated_at'])));
        }
      }
      if (rows.isNotEmpty) await client.push(rows);
      // Solo se borra lo enviado: lo anotado mientras tanto queda para la próxima.
      await (db.delete(db.syncOutbox)..where((o) => o.seq.isSmallerOrEqualValue(maxSeq))).go();
      total += rows.length;
    }
  }

  static int _millis(Object? isoDate) =>
      isoDate is String ? DateTime.parse(isoDate).millisecondsSinceEpoch : (isoDate as int? ?? 0);

  Future<int> _pull(SyncApi client) async {
    final start = int.tryParse(await _get(_kCursor) ?? '0') ?? 0;
    // Se reciben todas las páginas antes de aplicar, así un hijo nunca queda
    // sin su padre (las referencias se revisan al final de la transacción).
    final rows = <SyncRow>[];
    var cursor = start;
    while (true) {
      final page = await client.pull(cursor);
      rows.addAll(page.rows);
      cursor = page.next;
      if (!page.more) break;
    }
    if (rows.isEmpty) return 0;

    final columns = {
      for (final t in db.allTables) t.actualTableName: {for (final c in t.$columns) c.name},
    };
    var applied = 0;
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      await _set(_kApplying, '1');
      for (final r in rows) {
        final known = columns[r.table];
        if (known == null || !syncedTables.contains(r.table)) continue;
        final id = r.data['id'] as String;
        final local = await db
            .customSelect('SELECT updated_at FROM ${r.table} WHERE id = ?', variables: [Variable.withString(id)])
            .getSingleOrNull();
        if (local != null && _millis(local.data['updated_at']) > r.updatedAt) continue;

        final localOnly = localOnlyColumns[r.table] ?? const {};
        final data = {
          for (final e in r.data.entries)
            if (known.contains(e.key) && !localOnly.contains(e.key)) e.key: e.value,
        };
        // Fotos nuevas de otro teléfono: el archivo se descarga después.
        final insertData = r.table == 'photos' ? {...data, 'local_path': '', 'upload_status': 'remote'} : data;
        final cols = insertData.keys.toList();
        final updates = [
          for (final c in data.keys)
            if (c != 'id') '$c = excluded.$c',
        ];
        await db.customStatement(
          'INSERT INTO ${r.table} (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')}) '
          'ON CONFLICT(id) DO UPDATE SET ${updates.join(', ')}',
          [for (final c in cols) insertData[c]],
        );
        applied++;
      }
      await _set(_kApplying, '0');
      await _set(_kCursor, '$cursor');
    });
    // Avisa a las pantallas abiertas que los datos cambiaron.
    db.notifyUpdates({for (final t in db.allTables) TableUpdate.onTable(t)});
    return applied;
  }

  Future<int> _uploadPhotos(SyncApi client, void Function(String)? onStatus) async {
    final pending = await (db.select(
      db.photos,
    )..where((x) => x.uploadStatus.equals('pending') & x.deletedAt.isNull())).get();
    var done = 0;
    for (final photo in pending) {
      final file = File(photo.localPath);
      if (!file.existsSync()) continue;
      onStatus?.call('Subiendo fotos: ${done + 1} de ${pending.length}');
      await client.putPhoto(photo.id, file);
      await (db.update(
        db.photos,
      )..where((x) => x.id.equals(photo.id))).write(const PhotosCompanion(uploadStatus: Value('uploaded')));
      done++;
    }
    return done;
  }

  Future<int> _downloadPhotos(SyncApi client, void Function(String)? onStatus) async {
    final rows = await db.customSelect('''
SELECT p.id, p.file_name, p.local_path, o.season_id FROM photos p
JOIN observations o ON o.id = p.observation_id
WHERE p.deleted_at IS NULL AND p.upload_status IN ('remote', 'uploaded')''').get();
    final missing = [
      for (final r in rows)
        if (!File(r.read<String>('local_path')).existsSync()) r,
    ];
    var done = 0;
    for (final r in missing) {
      onStatus?.call('Descargando fotos: ${done + 1} de ${missing.length}');
      final bytes = await client.getPhoto(r.read('id'));
      if (bytes == null) continue; // Aún no la sube quien la tomó.
      final tmp = File(p.join(Directory.systemTemp.path, 'descarga_${r.read<String>('id')}.jpg'));
      await tmp.writeAsBytes(bytes);
      final path = await photoStore.save(
        sourcePath: tmp.path,
        folder: r.read('season_id'),
        fileName: r.read('file_name'),
      );
      await tmp.delete();
      await (db.update(db.photos)..where((x) => x.id.equals(r.read('id')))).write(
        PhotosCompanion(localPath: Value(path), uploadStatus: const Value('uploaded')),
      );
      done++;
    }
    return done;
  }
}
