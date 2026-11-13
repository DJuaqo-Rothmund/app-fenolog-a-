import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/backup_service.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';

import '../helpers.dart';

/// Un «teléfono» de prueba: base en memoria y carpeta propia.
class _Phone {
  _Phone(this.db, this.dir);
  final AppDatabase db;
  final Directory dir;

  late final photos = PhotoStore(p('docs'));
  late final backup = BackupService(db: db, photoStore: photos, tempDir: p('cache'));
  late final sampling = SamplingRepository(db, photos);
  late final projects = ProjectRepository(db);
  late final catalog = CatalogRepository(db);

  String p(String name) => '${dir.path}/$name';

  static Future<_Phone> create(Directory root, String name) async {
    final dir = await Directory('${root.path}/$name').create(recursive: true);
    return _Phone(await testDatabase(), dir);
  }

  /// Proyecto con una unidad, un registro y una foto.
  Future<Photo> seed({String name = 'Ensayo 2026'}) async {
    final crop = (await catalog.watchCrops().first).single;
    final scale = await catalog.defaultScale(crop.id);
    final projectId = await projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: name,
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = (await projects.watchCurrentSeason(projectId).first)!;
    final unit = await projects.createUnit(projectId: projectId, label: 'Heritage');
    final obs = await sampling.ensureObservation(season.id, unit, 1);
    final src = File(p('origen.jpg'));
    await src.writeAsBytes([0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);
    return sampling.addPhoto(
      observationId: obs,
      kind: PhotoKind.general,
      sourcePath: src.path,
      takenAt: DateTime(2026, 9, 8),
    );
  }
}

void main() {
  late Directory root;
  final open = <AppDatabase>[];

  setUp(() async {
    root = await Directory.systemTemp.createTemp('frambitacora_backup');
  });

  tearDown(() async {
    for (final db in open) {
      await db.close();
    }
    open.clear();
    await root.delete(recursive: true);
  });

  Future<_Phone> phone(String name) async {
    final ph = await _Phone.create(root, name);
    open.add(ph.db);
    return ph;
  }

  /// Escribe un .zip con los archivos dados (nombre → contenido).
  String writeZip(String name, Map<String, List<int>> files) {
    final path = '${root.path}/$name';
    final enc = ZipFileEncoder()..create(path);
    files.forEach((n, bytes) => enc.addArchiveFile(ArchiveFile.bytes(n, bytes)));
    enc.closeSync();
    return path;
  }

  group('rutas de fotos', () {
    test('convierte la ruta completa de la versión 1 en relativa', () {
      expect(
        relativePhotoPath('/data/user/0/cl.frambitacora/app_flutter/fotos/abc/20260908_FRB_X_G1.jpg'),
        'fotos/abc/20260908_FRB_X_G1.jpg',
      );
      expect(relativePhotoPath('fotos/abc/a.jpg'), 'fotos/abc/a.jpg');
      expect(relativePhotoPath(r'C:\datos\fotos\abc\a.jpg'), 'fotos/abc/a.jpg');
    });

    test('la migración 1 → 2 deja relativas las rutas guardadas', () async {
      final file = File('${root.path}/v1.sqlite');
      // Se crea la base y se marca como versión 1 con una ruta antigua.
      var db = AppDatabase(NativeDatabase(file));
      final ph = _Phone(db, root);
      await ph.catalog.watchCrops().first; // abre la base
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await db.customStatement(
        "INSERT INTO photos (id, observation_id, kind, seq, file_name, local_path, taken_at, created_at, updated_at) "
        "VALUES ('f1', 'o1', 'general', 1, 'a.jpg', '/data/user/0/app/fotos/s1/a.jpg', '2026-09-08', '2026-09-08', '2026-09-08')",
      );
      await db.customStatement('PRAGMA user_version = 1');
      await db.close();

      db = AppDatabase(NativeDatabase(file));
      final photo = await db.select(db.photos).getSingle();
      expect(photo.localPath, 'fotos/s1/a.jpg');
      await db.close();
    });
  });

  group('nombres permitidos dentro de una copia', () {
    test('acepta solo datos de control, base y fotos', () {
      expect(isSafeBackupEntry('manifest.json'), isTrue);
      expect(isSafeBackupEntry('frambitacora.sqlite'), isTrue);
      expect(isSafeBackupEntry('fotos/temporada/a.jpg'), isTrue);
      expect(isSafeBackupEntry('../fuera.txt'), isFalse);
      expect(isSafeBackupEntry('fotos/../../fuera.jpg'), isFalse);
      expect(isSafeBackupEntry('/etc/passwd'), isFalse);
      expect(isSafeBackupEntry(r'fotos\a.jpg'), isFalse);
      expect(isSafeBackupEntry('otra/cosa.jpg'), isFalse);
    });
  });

  group('crear copia', () {
    test('el .zip lleva datos de control, la base y las fotos', () async {
      final a = await phone('a');
      final photo = await a.seed();

      final zip = await a.backup.create(now: DateTime(2026, 11, 13, 15, 30));
      expect(zip, endsWith('FramBitacora_respaldo_20261113-1530.zip'));

      final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
      expect(archive.findFile('frambitacora.sqlite'), isNotNull);
      expect(archive.findFile(photo.localPath)!.readBytes(), [0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);

      final manifest = await a.backup.inspect(zip);
      expect(manifest.projects, 1);
      expect(manifest.observations, 1);
      expect(manifest.photos, 1);
      expect(manifest.schemaVersion, a.db.schemaVersion);
      expect(manifest.createdAt, DateTime(2026, 11, 13, 15, 30));
    });

    test('una copia nueva reemplaza la anterior en la caché', () async {
      final a = await phone('a');
      final first = await a.backup.create(now: DateTime(2026, 11, 13, 10));
      final second = await a.backup.create(now: DateTime(2026, 11, 13, 11));
      expect(File(first).existsSync(), isFalse);
      expect(File(second).existsSync(), isTrue);
    });
  });

  group('restaurar', () {
    test('en otro teléfono recupera datos y fotos', () async {
      final a = await phone('a');
      final photo = await a.seed();
      final zip = await a.backup.create();

      final b = await phone('b');
      await b.seed(name: 'Datos que se reemplazan');
      final changes = b.projects.watchProjects().map((l) => l.map((p) => p.name).toList());
      final seen = <List<String>>[];
      final sub = changes.listen(seen.add);

      final manifest = await b.backup.restore(zip);
      expect(manifest.photos, 1);

      final projects = await b.projects.watchProjects().first;
      expect(projects.single.name, 'Ensayo 2026');
      final restored = await b.db.select(b.db.photos).getSingle();
      expect(restored.id, photo.id);
      expect(b.photos.file(restored.localPath).readAsBytesSync(), [0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);
      // La foto del «teléfono b» que no estaba en la copia ya no existe.
      final files = b.photos.photosDir.listSync(recursive: true).whereType<File>();
      expect(files, hasLength(1));
      // No quedan carpetas de trabajo.
      expect(Directory(b.p('docs/.restauracion')).existsSync(), isFalse);
      expect(Directory(b.p('docs/.fotos_anteriores')).existsSync(), isFalse);

      // Las pantallas abiertas reciben los datos nuevos.
      await pumpEventQueue();
      expect(seen.last, ['Ensayo 2026']);
      await sub.cancel();
    });

    test('una copia de la versión 1 (rutas completas) queda con rutas relativas', () async {
      final a = await phone('a');
      final photo = await a.seed();
      // Simula una base antigua: ruta completa y versión 1.
      await a.db.customStatement("UPDATE photos SET local_path = '/data/user/0/app/${photo.localPath}'");
      await a.db.customStatement('PRAGMA user_version = 1');
      final zip = await a.backup.create();

      final b = await phone('b');
      await b.backup.restore(zip);
      final restored = await b.db.select(b.db.photos).getSingle();
      expect(restored.localPath, photo.localPath);
      expect(b.photos.file(restored.localPath).existsSync(), isTrue);
    });

    test('rechaza un archivo que no es copia y no toca los datos', () async {
      final b = await phone('b');
      await b.seed();
      final notBackup = writeZip('otro.zip', {'hola.txt': utf8.encode('hola')});
      final notZip = File('${root.path}/foto.zip')..writeAsBytesSync([1, 2, 3, 4]);

      await expectLater(b.backup.inspect(notBackup), throwsA(isA<BackupException>()));
      await expectLater(b.backup.restore(notBackup), throwsA(isA<BackupException>()));
      await expectLater(b.backup.inspect(notZip.path), throwsA(isA<BackupException>()));
      await expectLater(b.backup.restore(notZip.path), throwsA(isA<BackupException>()));

      expect(await b.projects.watchProjects().first, hasLength(1));
      expect(b.photos.photosDir.listSync(recursive: true).whereType<File>(), hasLength(1));
    });

    test('rechaza una copia de una versión más nueva de la app', () async {
      final b = await phone('b');
      final zip = writeZip('nueva.zip', {
        'manifest.json': utf8.encode(
          jsonEncode({
            'app': 'frambitacora',
            'format': 1,
            'schemaVersion': b.db.schemaVersion + 1,
            'createdAt': '2027-01-01T00:00:00.000',
            'counts': {'projects': 1, 'observations': 0, 'photos': 0},
          }),
        ),
        'frambitacora.sqlite': [0],
      });
      await expectLater(
        b.backup.inspect(zip),
        throwsA(isA<BackupException>().having((e) => e.message, 'mensaje', contains('más nueva'))),
      );
    });

    test('ignora entradas con rutas peligrosas', () async {
      final a = await phone('a');
      await a.seed();
      final good = ZipDecoder().decodeBytes(File(await a.backup.create()).readAsBytesSync());
      final files = {for (final f in good) f.name: f.readBytes()!.toList()};
      files['fotos/../../fuera.txt'] = utf8.encode('no');
      final zip = writeZip('manipulada.zip', files);

      final b = await phone('b');
      await b.backup.restore(zip);
      expect(File(b.p('fuera.txt')).existsSync(), isFalse);
      expect(File('${root.path}/fuera.txt').existsSync(), isFalse);
      expect(await b.projects.watchProjects().first, hasLength(1));
    });
  });
}
