import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';
import 'drive_client.dart';

/// Tablas que viajan entre equipos, en orden: primero las que otras apuntan.
const syncTables = [
  'crops',
  'pheno_scales',
  'pheno_macros',
  'pheno_stages',
  'varieties',
  'projects',
  'treatments',
  'seasons',
  'units',
  'week_statuses',
  'observations',
  'photos',
];

/// Columnas que apuntan a filas de otra tabla: tabla → {columna: tabla apuntada}.
const syncReferences = <String, Map<String, String>>{
  'pheno_scales': {'crop_id': 'crops'},
  'pheno_macros': {'scale_id': 'pheno_scales'},
  'pheno_stages': {'scale_id': 'pheno_scales'},
  'varieties': {'crop_id': 'crops'},
  'projects': {'crop_id': 'crops', 'scale_id': 'pheno_scales'},
  'treatments': {'project_id': 'projects'},
  'seasons': {'project_id': 'projects'},
  'units': {'project_id': 'projects', 'variety_id': 'varieties'},
  'week_statuses': {'season_id': 'seasons'},
  'observations': {'season_id': 'seasons', 'unit_id': 'units', 'stage_id': 'pheno_stages'},
  'photos': {'observation_id': 'observations'},
};

/// Datos que identifican «la misma cosa» aunque se haya creado en dos equipos
/// con distinto id (p. ej. el registro de una unidad en una semana, o el
/// catálogo del cultivo que cada equipo carga al instalarse).
const syncNaturalKeys = <String, List<String>>{
  'crops': ['code'],
  'pheno_scales': ['crop_id', 'name', 'version'],
  'pheno_macros': ['scale_id', 'code'],
  'pheno_stages': ['scale_id', 'code'],
  'week_statuses': ['season_id', 'week_number'],
  'observations': ['season_id', 'unit_id', 'week_number'],
};

/// Carpeta de Drive (dentro de la principal) con los archivos de cambios.
const syncDataFolder = 'datos';

/// Lo que cada equipo recuerda de la sincronización.
class SyncState {
  SyncState({required this.deviceId, this.lastPush, Map<String, String>? seen, Map<String, String>? aliases})
    : seen = seen ?? {},
      aliases = aliases ?? {};

  /// Identificador de este equipo (nombre de su carpeta en Drive).
  final String deviceId;

  /// Hasta cuándo ya se subieron los cambios locales (`null` = nunca: se sube todo).
  DateTime? lastPush;

  /// Último archivo de cambios leído de cada otro equipo.
  final Map<String, String> seen;

  /// Ids que otro equipo usa para una fila que aquí tiene otro id.
  final Map<String, String> aliases;

  Map<String, Object?> toJson() => {
    'equipo': deviceId,
    'subidoHasta': lastPush?.toUtc().toIso8601String(),
    'leidos': seen,
    'alias': aliases,
  };

  factory SyncState.fromJson(Map<String, Object?> j) => SyncState(
    deviceId: j['equipo'] as String,
    lastPush: DateTime.tryParse(j['subidoHasta'] as String? ?? ''),
    seen: (j['leidos'] as Map? ?? {}).cast<String, String>(),
    aliases: (j['alias'] as Map? ?? {}).cast<String, String>(),
  );
}

/// Dónde se guarda el [SyncState] (se reemplaza en las pruebas).
abstract class SyncStateStore {
  Future<SyncState> load();
  Future<void> save(SyncState state);

  /// Tras restaurar una copia: los datos locales se vuelven a subir completos.
  Future<void> afterRestore() async {
    final s = await load();
    s.lastPush = null;
    await save(s);
  }

  /// Otra cuenta de Google = otro Drive: se empieza de cero (mismo equipo).
  Future<void> reset() async {
    final s = await load();
    await save(SyncState(deviceId: s.deviceId));
  }
}

class MemorySyncStateStore extends SyncStateStore {
  MemorySyncStateStore([String? deviceId]) : _state = SyncState(deviceId: deviceId ?? newId());
  SyncState _state;

  @override
  Future<SyncState> load() async => SyncState.fromJson(jsonDecode(jsonEncode(_state.toJson())) as Map<String, Object?>);

  @override
  Future<void> save(SyncState state) async => _state = state;
}

class PrefsSyncStateStore extends SyncStateStore {
  PrefsSyncStateStore(this.prefs);
  final SharedPreferences prefs;
  static const _key = 'sincronizacion_estado';

  @override
  Future<SyncState> load() async {
    final raw = prefs.getString(_key);
    if (raw != null) return SyncState.fromJson(jsonDecode(raw) as Map<String, Object?>);
    final fresh = SyncState(deviceId: newId());
    await save(fresh);
    return fresh;
  }

  @override
  Future<void> save(SyncState state) => prefs.setString(_key, jsonEncode(state.toJson()));
}

/// Resultado de sincronizar los datos.
class DataSyncResult {
  const DataSyncResult({required this.received, required this.sent});

  /// Filas que cambiaron aquí por cambios de otros equipos.
  final int received;

  /// Filas de este equipo subidas a Drive.
  final int sent;
}

/// Sincroniza la base entre equipos usando Google Drive como punto de encuentro.
///
/// Cada equipo sube a `FramBitácora/datos/<equipo>/` un archivo JSON con las filas
/// que cambiaron desde su última subida, y lee los archivos nuevos de los demás.
/// Cada fila trae su fecha de cambio (`updated_at`): si la misma fila cambió en
/// los dos lados, **gana la más reciente**. Nada se borra de verdad: los borrados
/// viajan como `deleted_at`.
class DataSync {
  DataSync({required this.db, required this.drive, required this.store, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DriveApi drive;
  final SyncStateStore store;
  final DateTime Function() _clock;

  Future<DataSyncResult> sync({required String rootFolderId}) async {
    final state = await store.load();
    final dataFolder = await drive.folder(syncDataFolder, parentId: rootFolderId);

    // 1. Leer lo nuevo de los otros equipos, en orden de creación.
    final pending = <({String device, DriveEntry file})>[];
    for (final dev in (await drive.list(dataFolder)).where((e) => e.isFolder && e.name != state.deviceId)) {
      final last = state.seen[dev.name] ?? '';
      for (final f in await drive.list(dev.id)) {
        if (!f.isFolder && f.name.endsWith('.json') && f.name.compareTo(last) > 0) {
          pending.add((device: dev.name, file: f));
        }
      }
    }
    pending.sort((a, b) => a.file.name.compareTo(b.file.name));
    var received = 0;
    final echoes = <String>{}, keep = <String>{};
    for (final p in pending) {
      final data = jsonDecode(utf8.decode(await drive.download(p.file.id))) as Map<String, Object?>;
      received += await applyChanges(data, state, versions: echoes, kept: keep);
      final last = state.seen[p.device];
      if (last == null || p.file.name.compareTo(last) > 0) state.seen[p.device] = p.file.name;
      await store.save(state);
    }

    // 2. Subir lo que cambió aquí.
    final until = _clock();
    // Lo que llegó de otros equipos y sigue igual no se reenvía.
    // Las filas en que este equipo conservó su id se envían siempre, para que el
    // otro equipo adopte ese id.
    final changes = await collectChanges(since: state.lastPush, until: until, skip: echoes, always: keep);
    final sent = changes.values.fold(0, (n, rows) => n + rows.length);
    if (sent > 0) {
      final folder = await drive.folder(state.deviceId, parentId: dataFolder);
      final body = utf8.encode(
        jsonEncode({
          'formato': 1,
          'equipo': state.deviceId,
          'creado': until.toUtc().toIso8601String(),
          'tablas': changes,
        }),
      );
      await drive.uploadBytes(body, name: changeFileName(until), parentId: folder, mime: 'application/json');
    }
    state.lastPush = until;
    await store.save(state);
    return DataSyncResult(received: received, sent: sent);
  }

  /// Nombre del archivo de cambios: ordena por fecha (UTC) al ordenar por nombre.
  static String changeFileName(DateTime at) {
    final iso = at.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '');
    return '${iso.split('.').first}Z-${(at.microsecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}.json';
  }

  /// Filas cambiadas en (since, until]. Con `since` nulo, todas. Se omiten las
  /// versiones de [skip] (`id|updated_at`).
  Future<Map<String, List<Map<String, Object?>>>> collectChanges({
    DateTime? since,
    required DateTime until,
    Set<String> skip = const {},
    Set<String> always = const {},
  }) async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final table in syncTables) {
      final rows = await db.customSelect('SELECT * FROM $table').get();
      final changed = [
        for (final r in rows)
          if (always.contains(r.data['id']) ||
              _inRange(_date(r.data['updated_at']), since, until) &&
                  !skip.contains('${r.data['id']}|${r.data['updated_at']}'))
            r.data,
      ];
      if (changed.isNotEmpty) out[table] = changed;
    }
    return out;
  }

  static bool _inRange(DateTime? d, DateTime? since, DateTime until) =>
      d != null && !d.isAfter(until) && (since == null || d.isAfter(since));

  static DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

  /// Aplica un archivo de cambios. Devuelve cuántas filas cambiaron aquí. Anota
  /// en [versions] las versiones (`id|updated_at`) que quedaron iguales a las recibidas.
  /// En [kept] anota los ids locales que se conservaron frente a uno recibido.
  Future<int> applyChanges(
    Map<String, Object?> data,
    SyncState state, {
    Set<String>? versions,
    Set<String>? kept,
  }) async {
    final tables = (data['tablas'] as Map? ?? {}).cast<String, Object?>();
    var changed = 0;
    await db.transaction(() async {
      // Las referencias se revisan al final: así se pueden cambiar ids en cadena.
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in syncTables) {
        final rows = (tables[table] as List? ?? const []).cast<Map<String, Object?>>();
        if (rows.isEmpty) continue;
        final columns = await _columns(table);
        for (final row in rows) {
          if (await _applyRow(table, row, columns, state.aliases, versions, kept)) changed++;
        }
      }
    });
    return changed;
  }

  final _columnCache = <String, Set<String>>{};

  Future<Set<String>> _columns(String table) async => _columnCache[table] ??= {
    for (final r in await db.customSelect('PRAGMA table_info($table)').get()) r.read<String>('name'),
  };

  Future<Map<String, Object?>?> _byId(String table, String id) async =>
      (await db
              .customSelect('SELECT * FROM $table WHERE id = ?', variables: [Variable.withString(id)])
              .getSingleOrNull())
          ?.data;

  Future<bool> _applyRow(
    String table,
    Map<String, Object?> raw,
    Set<String> columns,
    Map<String, String> aliases,
    Set<String>? versions,
    Set<String>? kept,
  ) async {
    final row = {
      for (final e in raw.entries)
        if (columns.contains(e.key)) e.key: e.value,
    };
    String resolve(String id) => aliases[id] ?? id;
    row['id'] = resolve(row['id'] as String);
    for (final col in (syncReferences[table] ?? const <String, String>{}).keys) {
      if (row[col] is String) row[col] = resolve(row[col] as String);
    }

    var local = await _byId(table, row['id'] as String);
    if (local == null) {
      final twin = await _twin(table, row);
      if (twin != null) {
        // La misma cosa creada en dos equipos: ambos se quedan con el id menor.
        final incomingId = row['id'] as String, localId = twin['id'] as String;
        if (incomingId.compareTo(localId) < 0) {
          await _changeId(table, localId, incomingId);
          aliases[localId] = incomingId;
          local = {...twin, 'id': incomingId};
        } else {
          aliases[incomingId] = localId;
          kept?.add(localId);
          row['id'] = localId;
          local = twin;
        }
      }
    }

    void remember() => versions?.add('${row['id']}|${row['updated_at']}');

    if (local == null) {
      remember();
      final cols = row.keys.toList();
      await db.customStatement(
        'INSERT INTO $table (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})',
        [for (final c in cols) row[c]],
      );
      return true;
    }

    // Mismo contenido (p. ej. el catálogo del cultivo cargado en ambos equipos):
    // se adopta la fecha recibida para que no vuelva a viajar.
    final sameContent = row.keys.every(
      (c) => const {'id', 'created_at', 'updated_at'}.contains(c) || '${row[c]}' == '${local![c]}',
    );
    if (sameContent) {
      if (local['updated_at'] != row['updated_at']) {
        await db.customStatement('UPDATE $table SET updated_at = ?, created_at = ? WHERE id = ?', [
          row['updated_at'],
          row['created_at'] ?? local['created_at'],
          row['id'],
        ]);
      }
      remember();
      return false;
    }

    final incoming = _date(row['updated_at']), mine = _date(local['updated_at']);
    if (incoming == null || (mine != null && !incoming.isAfter(mine))) {
      if (local['updated_at'] == row['updated_at']) remember();
      return false;
    }
    remember();
    final cols = row.keys.where((c) => c != 'id').toList();
    await db.customStatement('UPDATE $table SET ${cols.map((c) => '$c = ?').join(', ')} WHERE id = ?', [
      for (final c in cols) row[c],
      row['id'],
    ]);
    return true;
  }

  /// Fila local que representa lo mismo que [row] (según su clave natural).
  Future<Map<String, Object?>?> _twin(String table, Map<String, Object?> row) async {
    final key = syncNaturalKeys[table];
    if (key == null || key.any((c) => row[c] == null)) return null;
    final found = await db
        .customSelect(
          'SELECT * FROM $table WHERE ${key.map((c) => '$c = ?').join(' AND ')} LIMIT 1',
          variables: [for (final c in key) _variable(row[c])],
        )
        .getSingleOrNull();
    return found?.data;
  }

  static Variable<Object> _variable(Object? v) => switch (v) {
    final int i => Variable<int>(i),
    final double d => Variable<double>(d),
    final String t => Variable<String>(t),
    _ => const Variable<Object>(null),
  };

  /// Cambia el id de una fila local y de todo lo que la apunta.
  Future<void> _changeId(String table, String from, String to) async {
    await db.customStatement('UPDATE $table SET id = ? WHERE id = ?', [to, from]);
    for (final e in syncReferences.entries) {
      for (final ref in e.value.entries.where((r) => r.value == table)) {
        await db.customStatement('UPDATE ${e.key} SET ${ref.key} = ? WHERE ${ref.key} = ?', [to, from]);
      }
    }
  }
}
