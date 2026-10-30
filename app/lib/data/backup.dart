import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import 'database.dart';

/// Nombre del archivo de la base dentro de la carpeta de la app (lo define
/// `driftDatabase(name: 'frambitacora')`).
const databaseFileName = 'frambitacora.sqlite';
const _manifestName = 'respaldo.json';
const _pendingDir = 'restaurar_pendiente';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Copia de seguridad completa: base de datos y fotos en un solo .zip.
///
/// Restaurar se hace en dos pasos porque la base está abierta mientras la app
/// funciona: [stageRestore] deja el respaldo listo y [applyPendingRestore] lo
/// instala en el siguiente arranque, antes de abrir la base.
class BackupService {
  BackupService(this.baseDir);

  /// Carpeta de documentos de la app (donde están la base y `fotos/`).
  final Future<Directory> Function() baseDir;

  /// Crea el respaldo en [outDir] y devuelve el archivo .zip.
  Future<File> create(AppDatabase db, {required Directory outDir, DateTime? now}) async {
    final base = await baseDir();
    final at = now ?? DateTime.now();
    final stamp = '${at.year}${_pad2(at.month)}${_pad2(at.day)}_${_pad2(at.hour)}${_pad2(at.minute)}';
    final work = await Directory(p.join(outDir.path, 'respaldo_$stamp')).create(recursive: true);
    final dbCopy = File(p.join(work.path, databaseFileName));
    if (await dbCopy.exists()) await dbCopy.delete();
    // Copia coherente de la base aunque esté abierta.
    await db.customStatement('VACUUM INTO ?', [dbCopy.path]);
    final manifest = File(p.join(work.path, _manifestName));
    await manifest.writeAsString(
      jsonEncode({'app': 'frambitacora', 'schemaVersion': db.schemaVersion, 'createdAt': at.toIso8601String()}),
    );

    final zipPath = p.join(outDir.path, 'FramBitacora_respaldo_$stamp.zip');
    final photosDir = p.join(base.path, 'fotos');
    await Isolate.run(() {
      final encoder = ZipFileEncoder()..create(zipPath);
      encoder.addFile(File(p.join(work.path, _manifestName)), _manifestName);
      encoder.addFile(File(p.join(work.path, databaseFileName)), databaseFileName);
      final photos = Directory(photosDir);
      if (photos.existsSync()) {
        for (final f in photos.listSync(recursive: true).whereType<File>()) {
          encoder.addFile(f, p.posix.joinAll(['fotos', ...p.split(p.relative(f.path, from: photosDir))]));
        }
      }
      encoder.close();
    });
    await work.delete(recursive: true);
    return File(zipPath);
  }

  /// Revisa y descomprime el respaldo para instalarlo en el próximo arranque.
  Future<void> stageRestore(String zipPath) async {
    final base = await baseDir();
    final pending = Directory(p.join(base.path, _pendingDir));
    if (await pending.exists()) await pending.delete(recursive: true);
    try {
      await Isolate.run(() => extractFileToDisk(zipPath, pending.path));
    } catch (e) {
      if (await pending.exists()) await pending.delete(recursive: true);
      throw BackupException('El archivo no es un respaldo válido ($e).');
    }
    final manifest = File(p.join(pending.path, _manifestName));
    final dbFile = File(p.join(pending.path, databaseFileName));
    var valid = await manifest.exists() && await dbFile.exists();
    if (valid) {
      final data = jsonDecode(await manifest.readAsString());
      valid = data is Map && data['app'] == 'frambitacora';
    }
    if (!valid) {
      await pending.delete(recursive: true);
      throw BackupException('El archivo no es un respaldo de FramBitácora.');
    }
  }

  /// Si hay un respaldo pendiente, reemplaza la base y las fotos. Llamar antes
  /// de abrir la base. Devuelve verdadero si se restauró algo.
  Future<bool> applyPendingRestore() async {
    final base = await baseDir();
    final pending = Directory(p.join(base.path, _pendingDir));
    if (!await pending.exists()) return false;

    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File(p.join(base.path, '$databaseFileName$suffix'));
      if (await f.exists()) await f.delete();
    }
    await File(p.join(pending.path, databaseFileName)).rename(p.join(base.path, databaseFileName));

    final photos = Directory(p.join(base.path, 'fotos'));
    if (await photos.exists()) await photos.delete(recursive: true);
    final newPhotos = Directory(p.join(pending.path, 'fotos'));
    if (await newPhotos.exists()) await newPhotos.rename(photos.path);

    await pending.delete(recursive: true);
    return true;
  }

  /// Corrige la ruta de las fotos cuando el respaldo viene de otro teléfono
  /// (la carpeta de la app puede ser distinta).
  Future<int> relocatePhotos(AppDatabase db) async {
    final base = await baseDir();
    var fixed = 0;
    for (final photo in await db.select(db.photos).get()) {
      if (File(photo.localPath).existsSync()) continue;
      final parts = p.split(photo.localPath);
      final i = parts.lastIndexOf('fotos');
      if (i < 0) continue;
      final candidate = p.joinAll([base.path, ...parts.sublist(i)]);
      if (!File(candidate).existsSync()) continue;
      await (db.update(
        db.photos,
      )..where((x) => x.id.equals(photo.id))).write(PhotosCompanion(localPath: Value(candidate)));
      fixed++;
    }
    return fixed;
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');
}
