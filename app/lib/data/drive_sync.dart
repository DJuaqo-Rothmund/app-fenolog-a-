import 'dart:io';

import 'drive_client.dart';
import 'season_data.dart';
import 'season_tables.dart';

const driveRootFolder = 'FramBitácora';

class DriveUploadResult {
  const DriveUploadResult({required this.uploadedPhotos, required this.skippedPhotos, required this.missingPhotos});
  final int uploadedPhotos;

  /// Ya estaban en Drive.
  final int skippedPhotos;

  /// Fotos registradas cuyo archivo no está en el teléfono.
  final int missingPhotos;
}

/// Sube la información al Google Drive personal, ordenada así:
///
/// ```
/// FramBitácora/
///   <Proyecto>/<Temporada>/
///     <Proyecto>_<Temporada>.xlsx     (se reemplaza en cada subida)
///     fotos/Semana 01/20260908_FRB_HERITAGE_G1.jpg …
///   Respaldos/FramBitacora_respaldo_….zip
/// ```
///
/// Las fotos que ya están en Drive (mismo nombre) no se vuelven a subir.
class DriveSync {
  DriveSync(this.client);
  final DriveClient client;

  Future<DriveUploadResult> uploadSeason(
    SeasonData d, {
    required File workbook,
    File? report,
    void Function(int done, int total)? onProgress,
  }) async {
    final root = await client.folder(driveRootFolder);
    final projectFolder = await client.folder(d.project.name.trim(), parentId: root);
    final seasonFolder = await client.folder(d.season.name.trim(), parentId: projectFolder);

    final existing = await client.list(seasonFolder);
    final excelName = '${safeFileName(d.project.name)}_${safeFileName(d.season.name)}.xlsx';
    await client.uploadFile(
      workbook,
      name: excelName,
      parentId: seasonFolder,
      mimeType: mimeTypeFor(excelName),
      replaceId: existing[excelName],
    );
    if (report != null) {
      final name = report.uri.pathSegments.last;
      await client.uploadFile(
        report,
        name: name,
        parentId: seasonFolder,
        mimeType: mimeTypeFor(name),
        replaceId: existing[name],
      );
    }

    final photos = [for (final r in d.records) ...r.photos.map((p) => (week: r.week, photo: p))];
    final total = photos.length;
    var uploaded = 0, skipped = 0, missing = 0, done = 0;
    onProgress?.call(0, total);
    if (photos.isEmpty) return const DriveUploadResult(uploadedPhotos: 0, skippedPhotos: 0, missingPhotos: 0);

    final photosFolder = await client.folder('fotos', parentId: seasonFolder);
    final weekFolders = <int, String>{};
    final weekContents = <int, Map<String, String>>{};
    for (final (:week, :photo) in photos) {
      final file = File(photo.localPath);
      if (!file.existsSync()) {
        missing++;
      } else {
        final folderId = weekFolders[week] ??= await client.folder(
          'Semana ${week.toString().padLeft(2, '0')}',
          parentId: photosFolder,
        );
        final names = weekContents[week] ??= await client.list(folderId);
        if (names.containsKey(photo.fileName)) {
          skipped++;
        } else {
          names[photo.fileName] = await client.uploadFile(
            file,
            name: photo.fileName,
            parentId: folderId,
            mimeType: mimeTypeFor(photo.fileName),
          );
          uploaded++;
        }
      }
      onProgress?.call(++done, total);
    }
    return DriveUploadResult(uploadedPhotos: uploaded, skippedPhotos: skipped, missingPhotos: missing);
  }

  Future<void> uploadBackup(File zip) async {
    final root = await client.folder(driveRootFolder);
    final folder = await client.folder('Respaldos', parentId: root);
    final name = zip.uri.pathSegments.last;
    await client.uploadFile(zip, name: name, parentId: folder, mimeType: mimeTypeFor(name));
  }
}
