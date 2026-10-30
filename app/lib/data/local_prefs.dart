import 'database.dart';

/// Preferencias de este teléfono (no se sincronizan). Se guardan en la tabla
/// `sync_meta`, que es local.
class LocalPrefs {
  LocalPrefs(this.db);
  final AppDatabase db;

  static const _lastCrop = 'pref_last_crop';

  Future<String?> lastCropId() async =>
      (await (db.select(db.syncMeta)..where((m) => m.key.equals(_lastCrop))).getSingleOrNull())?.value;

  Future<void> setLastCropId(String id) =>
      db.into(db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(key: _lastCrop, value: id));
}
