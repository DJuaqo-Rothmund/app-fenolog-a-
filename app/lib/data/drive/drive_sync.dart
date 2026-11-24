import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

import '../backup_service.dart';
import '../database.dart';
import '../photo_store.dart';
import 'data_sync.dart';
import 'drive_client.dart';

/// Estado de subida de una foto que ya está en Drive (columna `photos.upload_status`).
const uploadedToDrive = 'drive';

/// Resultado de una sincronización.
class DriveSyncResult {
  const DriveSyncResult({
    required this.uploaded,
    required this.alreadyThere,
    required this.missing,
    this.backupName,
    this.received = 0,
    this.sent = 0,
    this.downloaded = 0,
  });

  /// Fotos subidas ahora.
  final int uploaded;

  /// Fotos que ya estaban en Drive (p. ej. tras reinstalar): solo se marcan.
  final int alreadyThere;

  /// Fotos cuyo archivo no está en el teléfono.
  final int missing;

  /// Nombre del respaldo subido, si se pidió.
  final String? backupName;

  /// Datos (filas) que llegaron de otros equipos y que se enviaron.
  final int received;
  final int sent;

  /// Fotos de otros equipos descargadas a este.
  final int downloaded;
}

/// Sube a Google Drive las fotos y una copia de seguridad, ordenadas así:
///
/// `FramBitácora/<proyecto>/<temporada>/Semana 07/<foto>.jpg`
/// `FramBitácora/Respaldos/FramBitacora_respaldo_<fecha>.zip`
///
/// Además intercambia los datos con los otros equipos (teléfono y web, ver
/// [DataSync]) y descarga las fotos que se agregaron en otro equipo. No borra
/// nada en Drive y no vuelve a subir lo que ya subió.
class DriveSync {
  DriveSync({required this.db, required this.photoStore, required this.drive, required this.backup, this.data});

  final AppDatabase db;
  final PhotoStore photoStore;
  final DriveApi drive;
  final BackupService backup;

  /// Sincronización de datos entre equipos (opcional: sin ella solo se suben fotos).
  final DataSync? data;

  static const rootFolder = 'FramBitácora';
  static const backupsFolder = 'Respaldos';

  static String weekFolder(int week) => 'Semana ${week.toString().padLeft(2, '0')}';

  static const _pendingSql = '''
SELECT ph.id, ph.file_name, ph.local_path, o.week_number, pr.name AS project, s.name AS season
FROM photos ph
JOIN observations o ON o.id = ph.observation_id
JOIN seasons s ON s.id = o.season_id
JOIN units u ON u.id = o.unit_id
JOIN projects pr ON pr.id = u.project_id
WHERE ph.deleted_at IS NULL AND o.deleted_at IS NULL AND pr.deleted_at IS NULL
  AND ph.upload_status <> ?
ORDER BY pr.name, s.name, o.week_number, ph.file_name''';

  /// Cantidad de fotos que aún no están en Drive.
  Stream<int> watchPending() => db
      .customSelect(
        'SELECT COUNT(*) AS n FROM ($_pendingSql)',
        variables: [Variable.withString(uploadedToDrive)],
        readsFrom: {db.photos, db.observations, db.projects},
      )
      .watchSingle()
      .map((r) => r.read<int>('n'));

  /// Al cambiar de cuenta de Google, todas las fotos vuelven a quedar pendientes.
  Future<void> resetUploads() => db.customUpdate(
    "UPDATE photos SET upload_status = 'pending' WHERE upload_status = ?",
    variables: [Variable.withString(uploadedToDrive)],
    updates: {db.photos},
  );

  /// Carpeta de la semana de una foto (la crea si no existe).
  Future<String> _weekFolderOf(String photoId) async {
    final r = await db
        .customSelect(
          '''
SELECT o.week_number, pr.name AS project, s.name AS season
FROM photos ph
JOIN observations o ON o.id = ph.observation_id
JOIN seasons s ON s.id = o.season_id
JOIN units u ON u.id = o.unit_id
JOIN projects pr ON pr.id = u.project_id
WHERE ph.id = ?''',
          variables: [Variable.withString(photoId)],
        )
        .getSingle();
    final root = await drive.folder(rootFolder);
    final pr = await drive.folder(r.read<String>('project'), parentId: root);
    final se = await drive.folder(r.read<String>('season'), parentId: pr);
    return drive.folder(weekFolder(r.read<int>('week_number')), parentId: se);
  }

  /// Sube al instante una foto que no tiene archivo local (la web) y la marca
  /// como subida, para que el teléfono la descargue al sincronizar.
  Future<void> uploadPhotoBytes(Photo photo, List<int> bytes) async {
    final folder = await _weekFolderOf(photo.id);
    await drive.uploadBytes(bytes, name: photo.fileName, parentId: folder, mime: 'image/jpeg');
    await (db.update(db.photos)..where((x) => x.id.equals(photo.id))).write(
      PhotosCompanion(uploadStatus: const Value(uploadedToDrive), updatedAt: Value(DateTime.now())),
    );
  }

  /// En la web no hay carpeta de fotos ni copias `.zip`: solo se intercambian
  /// los datos (las fotos se suben al momento de agregarlas y se ven desde Drive).
  Future<DriveSyncResult> sync({
    bool includeBackup = true,
    void Function(String step, int done, int total)? progress,
  }) async {
    if (kIsWeb) {
      progress?.call('Intercambiando datos', 0, 0);
      final d = await data?.sync(rootFolderId: await drive.folder(rootFolder));
      return DriveSyncResult(uploaded: 0, alreadyThere: 0, missing: 0, received: d?.received ?? 0, sent: d?.sent ?? 0);
    }
    final rows = await db.customSelect(_pendingSql, variables: [Variable.withString(uploadedToDrive)]).get();
    final root = await drive.folder(rootFolder);
    final folders = <String, String>{};
    final existing = <String, Set<String>>{};

    Future<String> folderFor(String project, String season, int week) async {
      final key = '$project/$season/$week';
      final cached = folders[key];
      if (cached != null) return cached;
      final pr = await drive.folder(project, parentId: root);
      final se = await drive.folder(season, parentId: pr);
      final wk = await drive.folder(weekFolder(week), parentId: se);
      existing[wk] = await drive.names(wk);
      return folders[key] = wk;
    }

    var uploaded = 0, already = 0, missing = 0;
    for (final (i, r) in rows.indexed) {
      progress?.call('Subiendo fotos', i, rows.length);
      final file = photoStore.file(r.read<String>('local_path'));
      if (!await file.exists()) {
        missing++;
        continue;
      }
      final name = r.read<String>('file_name');
      final folder = await folderFor(r.read<String>('project'), r.read<String>('season'), r.read<int>('week_number'));
      if (existing[folder]!.contains(name)) {
        already++;
      } else {
        await drive.upload(file, name: name, parentId: folder, mime: 'image/jpeg');
        existing[folder]!.add(name);
        uploaded++;
      }
      // La fecha de cambio avanza: así los otros equipos saben que la foto ya está en Drive.
      await (db.update(db.photos)..where((x) => x.id.equals(r.read<String>('id')))).write(
        PhotosCompanion(uploadStatus: const Value(uploadedToDrive), updatedAt: Value(DateTime.now())),
      );
    }

    var received = 0, sent = 0, downloaded = 0;
    if (data != null) {
      progress?.call('Intercambiando datos', rows.length, rows.length);
      final d = await data!.sync(rootFolderId: root);
      received = d.received;
      sent = d.sent;
      downloaded = await downloadMissingPhotos(progress: progress);
    }

    String? backupName;
    if (includeBackup) {
      progress?.call('Creando la copia de seguridad', rows.length, rows.length);
      final zip = await backup.create();
      progress?.call('Subiendo la copia de seguridad', rows.length, rows.length);
      final folder = await drive.folder(backupsFolder, parentId: root);
      backupName = p.basename(zip);
      await drive.upload(File(zip), name: backupName, parentId: folder, mime: 'application/zip');
    }
    return DriveSyncResult(
      uploaded: uploaded,
      alreadyThere: already,
      missing: missing,
      backupName: backupName,
      received: received,
      sent: sent,
      downloaded: downloaded,
    );
  }

  /// Descarga las fotos que están en Drive pero no en este equipo (las que se
  /// agregaron en otro). Devuelve cuántas bajó.
  Future<int> downloadMissingPhotos({void Function(String step, int done, int total)? progress}) async {
    final rows = await (db.select(
      db.photos,
    )..where((p) => p.deletedAt.isNull() & p.uploadStatus.equals(uploadedToDrive))).get();
    final missing = [
      for (final p in rows)
        if (!await photoStore.file(p.localPath).exists()) p,
    ];
    var done = 0;
    for (final (i, p) in missing.indexed) {
      progress?.call('Bajando fotos', i, missing.length);
      final id = await drive.findFile(p.fileName);
      if (id == null) continue;
      final file = photoStore.file(p.localPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(await drive.download(id), flush: true);
      done++;
    }
    return done;
  }
}
