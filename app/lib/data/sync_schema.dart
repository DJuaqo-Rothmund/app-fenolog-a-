import 'package:drift/drift.dart';

import 'ids.dart';

/// Tablas que se sincronizan con el servidor (nombres SQL). El servidor
/// acepta exactamente estas.
const syncedTables = [
  'crops',
  'pheno_scales',
  'pheno_macros',
  'pheno_stages',
  'varieties',
  'projects',
  'seasons',
  'units',
  'week_statuses',
  'observations',
  'photos',
  'measurement_defs',
  'measurement_values',
];

/// Columnas propias de cada teléfono: no se envían ni se reciben.
const localOnlyColumns = {
  'photos': {'local_path', 'upload_status'},
};

/// Cada inserción o cambio en una tabla sincronizada queda anotado en
/// `sync_outbox`, salvo mientras se aplican cambios que vienen del servidor
/// (`sync_meta.applying = '1'`).
Future<void> createSyncTriggers(GeneratedDatabase db, Map<String, List<String>> columnsByTable) async {
  const when = "WHEN COALESCE((SELECT value FROM sync_meta WHERE key = 'applying'), '0') <> '1'";
  for (final t in syncedTables) {
    final local = localOnlyColumns[t] ?? const {};
    final watched = local.isEmpty ? '' : ' OF ${columnsByTable[t]!.where((c) => !local.contains(c)).join(', ')}';
    await db.customStatement('DROP TRIGGER IF EXISTS sync_${t}_insert');
    await db.customStatement('DROP TRIGGER IF EXISTS sync_${t}_update');
    await db.customStatement(
      "CREATE TRIGGER sync_${t}_insert AFTER INSERT ON $t $when "
      "BEGIN INSERT INTO sync_outbox (tbl, row_id) VALUES ('$t', NEW.id); END",
    );
    await db.customStatement(
      "CREATE TRIGGER sync_${t}_update AFTER UPDATE$watched ON $t $when "
      "BEGIN INSERT INTO sync_outbox (tbl, row_id) VALUES ('$t', NEW.id); END",
    );
  }
}

/// Anota todas las filas existentes para enviarlas en la primera sincronización.
Future<void> seedOutbox(GeneratedDatabase db) async {
  for (final t in syncedTables) {
    await db.customStatement("INSERT INTO sync_outbox (tbl, row_id) SELECT '$t', id FROM $t");
  }
}

/// Pasa los identificadores creados al azar (versión 1-2 de la base) a los
/// deterministas de [Ids], actualizando todas las referencias.
Future<void> remapToDeterministicIds(GeneratedDatabase db) async {
  Future<List<QueryRow>> q(String sql) => db.customSelect(sql).get();
  Future<void> change(String table, String oldId, String newId, List<(String, String)> refs) async {
    if (oldId == newId) return;
    await db.customStatement('UPDATE $table SET id = ? WHERE id = ?', [newId, oldId]);
    for (final (refTable, refColumn) in refs) {
      await db.customStatement('UPDATE $refTable SET $refColumn = ? WHERE $refColumn = ?', [newId, oldId]);
    }
  }

  for (final r in await q('SELECT id, code FROM crops')) {
    await change('crops', r.read('id'), Ids.crop(r.read('code')), [
      ('pheno_scales', 'crop_id'),
      ('varieties', 'crop_id'),
      ('projects', 'crop_id'),
    ]);
  }
  for (final r in await q('SELECT s.id, s.name, c.code FROM pheno_scales s JOIN crops c ON c.id = s.crop_id')) {
    await change('pheno_scales', r.read('id'), Ids.scale(r.read('code'), r.read('name')), [
      ('pheno_macros', 'scale_id'),
      ('pheno_stages', 'scale_id'),
      ('projects', 'scale_id'),
    ]);
  }
  for (final r in await q('SELECT id, scale_id, code FROM pheno_macros')) {
    await change('pheno_macros', r.read('id'), Ids.macro(r.read('scale_id'), r.read('code')), const []);
  }
  for (final r in await q('SELECT id, scale_id, code FROM pheno_stages')) {
    await change('pheno_stages', r.read('id'), Ids.stage(r.read('scale_id'), r.read('code')), [
      ('observations', 'stage_id'),
    ]);
  }
  for (final r in await q('SELECT id, season_id, unit_id, week_number FROM observations')) {
    await change(
      'observations',
      r.read('id'),
      Ids.observation(r.read('season_id'), r.read('unit_id'), r.read('week_number')),
      [('photos', 'observation_id'), ('measurement_values', 'observation_id')],
    );
  }
  for (final r in await q('SELECT id, season_id, week_number FROM week_statuses')) {
    await change('week_statuses', r.read('id'), Ids.weekStatus(r.read('season_id'), r.read('week_number')), const []);
  }
  // Los valores borrados nunca se sincronizaron y podrían repetir el id nuevo.
  await db.customStatement('DELETE FROM measurement_values WHERE deleted_at IS NOT NULL');
  for (final r in await q('SELECT id, def_id, observation_id, season_id, variety_id FROM measurement_values')) {
    final obs = r.read<String?>('observation_id');
    final newId = obs != null
        ? Ids.observationValue(r.read('def_id'), obs)
        : Ids.varietyValue(r.read('def_id'), r.read('season_id'), r.read('variety_id'));
    await change('measurement_values', r.read('id'), newId, const []);
  }
}
