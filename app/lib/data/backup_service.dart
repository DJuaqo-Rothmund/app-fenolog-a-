import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'database.dart';
import 'photo_store.dart';

/// Identificador que llevan todas las copias de FramBitácora.
const backupAppId = 'frambitacora';

/// Versión del formato del archivo de copia (no confundir con la versión del
/// esquema de la base). Sube solo si cambia la estructura del `.zip`.
const backupFormat = 1;

const _manifestName = 'manifest.json';
const _databaseName = 'frambitacora.sqlite';

/// Error comprensible para mostrar en pantalla.
class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Datos de control que viajan dentro de la copia (`manifest.json`).
class BackupManifest {
  const BackupManifest({
    required this.schemaVersion,
    required this.createdAt,
    required this.projects,
    required this.observations,
    required this.photos,
    this.format = backupFormat,
  });

  final int format;
  final int schemaVersion;
  final DateTime createdAt;
  final int projects;
  final int observations;
  final int photos;

  Map<String, Object?> toJson() => {
    'app': backupAppId,
    'format': format,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toIso8601String(),
    'counts': {'projects': projects, 'observations': observations, 'photos': photos},
  };

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    if (json['app'] != backupAppId) {
      throw BackupException('El archivo no es una copia de FramBitácora.');
    }
    try {
      final counts = (json['counts'] as Map?) ?? const {};
      return BackupManifest(
        format: json['format']! as int,
        schemaVersion: json['schemaVersion']! as int,
        createdAt: DateTime.parse(json['createdAt']! as String),
        projects: (counts['projects'] as int?) ?? 0,
        observations: (counts['observations'] as int?) ?? 0,
        photos: (counts['photos'] as int?) ?? 0,
      );
    } catch (_) {
      throw BackupException('La copia está dañada: sus datos de control no se pueden leer.');
    }
  }
}

/// Crea y restaura copias de seguridad completas: un `.zip` con
/// `manifest.json`, una copia de la base (`frambitacora.sqlite`) y la carpeta
/// `fotos/` tal cual.
class BackupService {
  BackupService({required this.db, required this.photoStore, required this.tempDir});

  final AppDatabase db;
  final PhotoStore photoStore;

  /// Carpeta donde se arma el `.zip` antes de compartirlo (caché de la app).
  final String tempDir;

  Directory get _outDir => Directory(p.join(tempDir, 'respaldos'));

  /// Nombre del archivo, p. ej. `FramBitacora_respaldo_20261113-1530.zip`.
  static String fileName(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'FramBitacora_respaldo_${at.year}${two(at.month)}${two(at.day)}-${two(at.hour)}${two(at.minute)}.zip';
  }

  /// Crea la copia y devuelve la ruta del `.zip`. Borra las copias anteriores
  /// que quedaron en la caché, para no ocupar espacio dos veces.
  Future<String> create({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final out = _outDir;
    if (await out.exists()) await out.delete(recursive: true);
    await out.create(recursive: true);

    // Copia consistente de la base, aunque la app la esté usando.
    final dbCopy = p.join(out.path, _databaseName);
    await db.customStatement("VACUUM INTO '${dbCopy.replaceAll("'", "''")}'");

    Future<int> count(String table, [String where = '']) async {
      final r = await db.customSelect('SELECT COUNT(*) AS n FROM $table WHERE deleted_at IS NULL $where').getSingle();
      return r.read<int>('n');
    }

    final manifest = BackupManifest(
      schemaVersion: db.schemaVersion,
      createdAt: at,
      projects: await count('projects'),
      observations: await count('observations'),
      photos: await count('photos'),
    );

    final zipPath = p.join(out.path, fileName(at));
    final manifestJson = const JsonEncoder.withIndent('  ').convert(manifest.toJson());
    final photosDir = photoStore.photosDir.path;
    // Comprimir cientos de fotos toma tiempo: se hace fuera del hilo de la pantalla.
    await _writeZipInIsolate(zipPath, manifestJson, dbCopy, photosDir);
    await File(dbCopy).delete();
    return zipPath;
  }

  /// Lee solo los datos de control de una copia, para mostrarlos antes de
  /// restaurar. Lanza [BackupException] si el archivo no sirve.
  Future<BackupManifest> inspect(String zipPath) async {
    final json = await _readManifestInIsolate(zipPath);
    final manifest = BackupManifest.fromJson(json);
    _checkCompatible(manifest);
    return manifest;
  }

  /// Reemplaza **todos** los datos y fotos del teléfono por los de la copia.
  ///
  /// Pasos: 1) extraer la copia a una carpeta de trabajo; 2) abrir la base de la
  /// copia con la app, lo que la actualiza si viene de una versión anterior;
  /// 3) copiar sus tablas a la base en uso dentro de una transacción (si algo
  /// falla, no cambia nada); 4) cambiar la carpeta de fotos.
  Future<BackupManifest> restore(String zipPath) async {
    final staging = Directory(p.join(photoStore.rootPath, '.restauracion'));
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    try {
      await _extractZipInIsolate(zipPath, staging.path);

      final manifestFile = File(p.join(staging.path, _manifestName));
      final dbFile = File(p.join(staging.path, _databaseName));
      if (!await manifestFile.exists() || !await dbFile.exists()) {
        throw BackupException('El archivo no es una copia de FramBitácora.');
      }
      final manifest = BackupManifest.fromJson(jsonDecode(await manifestFile.readAsString()) as Map<String, Object?>);
      _checkCompatible(manifest);

      await _upgradeBackupDatabase(dbFile);
      await _copyTablesFrom(dbFile.path);
      await _swapPhotos(Directory(p.join(staging.path, photosFolder)));
      return manifest;
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  void _checkCompatible(BackupManifest m) {
    if (m.format > backupFormat || m.schemaVersion > db.schemaVersion) {
      throw BackupException(
        'La copia viene de una versión más nueva de la app. Actualiza FramBitácora e inténtalo otra vez.',
      );
    }
  }

  /// Abre la base de la copia con las migraciones de la app y revisa que no esté dañada.
  Future<void> _upgradeBackupDatabase(File file) async {
    // Es otra base (otro archivo), abierta un momento: el aviso de drift sobre
    // varias bases abiertas no aplica.
    final previous = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final backupDb = AppDatabase(NativeDatabase(file));
    try {
      final check = await backupDb.customSelect('PRAGMA quick_check').getSingle();
      if (check.data.values.first != 'ok') throw BackupException('La base de datos de la copia está dañada.');
    } on BackupException {
      rethrow;
    } catch (_) {
      throw BackupException('La base de datos de la copia está dañada o no se puede abrir.');
    } finally {
      await backupDb.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = previous;
    }
  }

  Future<void> _copyTablesFrom(String backupPath) async {
    // ATTACH no se permite dentro de una transacción; la copia sí va en una.
    await db.customStatement('ATTACH DATABASE ? AS respaldo', [backupPath]);
    try {
      final tables = db.allTables.toList();
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        for (final t in tables.reversed) {
          await db.customStatement('DELETE FROM main.${t.actualTableName}');
        }
        for (final t in tables) {
          final cols = t.$columns.map((c) => '"${c.name}"').join(', ');
          await db.customStatement(
            'INSERT INTO main.${t.actualTableName} ($cols) SELECT $cols FROM respaldo.${t.actualTableName}',
          );
        }
      });
    } finally {
      await db.customStatement('DETACH DATABASE respaldo');
    }
    // Avisa a las pantallas abiertas que los datos cambiaron.
    db.markTablesUpdated(db.allTables);
  }

  Future<void> _swapPhotos(Directory restored) async {
    final current = photoStore.photosDir;
    final old = Directory(p.join(photoStore.rootPath, '.fotos_anteriores'));
    if (await old.exists()) await old.delete(recursive: true);
    if (await current.exists()) await current.rename(old.path);
    if (await restored.exists()) {
      await restored.rename(current.path);
    } else {
      await current.create(recursive: true);
    }
    if (await old.exists()) await old.delete(recursive: true);
  }
}

// ---------------------------------------------------------------------------
// Funciones que corren en un isolate aparte (solo reciben rutas).

// Las tareas se arman en funciones de nivel superior: una función anónima creada
// dentro de un método de [BackupService] arrastraría la base de datos abierta,
// que no se puede enviar a otro isolate.
Future<void> _writeZipInIsolate(String zipPath, String manifestJson, String dbPath, String photosDir) =>
    Isolate.run(() => _writeZip(zipPath, manifestJson, dbPath, photosDir));

Future<Map<String, Object?>> _readManifestInIsolate(String zipPath) => Isolate.run(() => _readManifest(zipPath));

Future<void> _extractZipInIsolate(String zipPath, String outDir) => Isolate.run(() => _extractZip(zipPath, outDir));

void _writeZip(String zipPath, String manifestJson, String dbPath, String photosDir) {
  final enc = ZipFileEncoder()..create(zipPath);
  try {
    final manifestBytes = utf8.encode(manifestJson);
    enc.addArchiveFile(ArchiveFile.bytes(_manifestName, manifestBytes));
    // La base se comprime bien; las fotos JPG ya vienen comprimidas y se guardan tal cual.
    enc.addFileSync(File(dbPath), _databaseName, 6);
    final dir = Directory(photosDir);
    if (dir.existsSync()) {
      final files = dir.listSync(recursive: true).whereType<File>().toList()..sort((a, b) => a.path.compareTo(b.path));
      for (final f in files) {
        final rel = p.relative(f.path, from: dir.path).replaceAll(r'\', '/');
        enc.addFileSync(f, '$photosFolder/$rel', ZipFileEncoder.store);
      }
    }
  } finally {
    enc.closeSync();
  }
}

Map<String, Object?> _readManifest(String zipPath) {
  final input = _openZipInput(zipPath);
  try {
    final archive = _decode(input);
    final entry = archive.findFile(_manifestName);
    if (entry == null) throw BackupException('El archivo no es una copia de FramBitácora.');
    try {
      return jsonDecode(utf8.decode(entry.readBytes()!)) as Map<String, Object?>;
    } catch (_) {
      throw BackupException('La copia está dañada: sus datos de control no se pueden leer.');
    }
  } finally {
    input.closeSync();
  }
}

/// Extrae solo los archivos esperados y rechaza nombres peligrosos
/// (rutas absolutas o con `..`), para que una copia manipulada no pueda
/// escribir fuera de la carpeta de trabajo.
void _extractZip(String zipPath, String outDir) {
  final input = _openZipInput(zipPath);
  try {
    final archive = _decode(input);
    for (final entry in archive) {
      if (!entry.isFile || entry.isSymbolicLink) continue;
      final name = entry.name;
      if (!isSafeBackupEntry(name)) continue;
      final target = File(p.joinAll([outDir, ...name.split('/')]));
      target.parent.createSync(recursive: true);
      final out = OutputFileStream(target.path);
      try {
        entry.writeContent(out);
      } finally {
        out.closeSync();
      }
    }
  } on BackupException {
    rethrow;
  } on FileSystemException catch (e) {
    throw BackupException('No se pudo extraer la copia (¿falta espacio en el teléfono?): ${e.message}');
  } catch (_) {
    throw BackupException('La copia está dañada o incompleta.');
  } finally {
    input.closeSync();
  }
}

InputFileStream _openZipInput(String zipPath) {
  try {
    return InputFileStream(zipPath);
  } catch (_) {
    throw BackupException('No se pudo abrir el archivo de copia.');
  }
}

Archive _decode(InputFileStream input) {
  try {
    return ZipDecoder().decodeStream(input);
  } catch (_) {
    throw BackupException('El archivo no es un .zip válido.');
  }
}

/// Nombres permitidos dentro de una copia: los datos de control, la base y
/// archivos dentro de `fotos/` sin rutas absolutas ni `..`.
bool isSafeBackupEntry(String name) {
  if (name == _manifestName || name == _databaseName) return true;
  if (!name.startsWith('$photosFolder/') || name.contains(r'\')) return false;
  final parts = name.split('/');
  return parts.length >= 2 && parts.every((s) => s.isNotEmpty && s != '.' && s != '..' && !s.contains(':'));
}
