import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/backup_service.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/drive/drive_client.dart';
import 'package:frambitacora/data/drive/drive_sync.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers.dart';

/// Drive en memoria: carpetas y archivos por ruta.
class FakeDrive implements DriveApi {
  final folders = <String, String>{'root': ''}; // id → ruta
  final files = <String, Set<String>>{}; // id carpeta → nombres
  final uploads = <String>[]; // rutas completas subidas

  @override
  Future<({String email, String name})> about() async => (email: 'ana@ejemplo.cl', name: 'Ana');

  @override
  Future<String> folder(String name, {String parentId = 'root'}) async {
    final path = '${folders[parentId]}/$name';
    final found = folders.entries.where((e) => e.value == path).firstOrNull;
    if (found != null) return found.key;
    final id = 'f${folders.length}';
    folders[id] = path;
    return id;
  }

  @override
  Future<Set<String>> names(String parentId) async => {...?files[parentId]};

  @override
  Future<String> upload(File file, {required String name, required String parentId, required String mime}) async {
    files.putIfAbsent(parentId, () => {}).add(name);
    uploads.add('${folders[parentId]}/$name');
    return 'file${uploads.length}';
  }
}

void main() {
  group('cliente de Drive', () {
    test('busca la carpeta y, si no existe, la crea', () async {
      final calls = <String>[];
      final client = DriveClient(
        MockClient((r) async {
          calls.add('${r.method} ${r.url.path}');
          if (r.method == 'GET') {
            final q = r.url.queryParameters['q']!;
            final files = q.contains("name = 'Existe'")
                ? [
                    {'id': 'abc', 'name': 'Existe'},
                  ]
                : [];
            return http.Response(jsonEncode({'files': files}), 200);
          }
          expect(jsonDecode(r.body)['parents'], ['root']);
          return http.Response(jsonEncode({'id': 'nueva'}), 200);
        }),
        () async => 'token',
      );
      expect(await client.folder('Existe'), 'abc');
      expect(await client.folder('No existe'), 'nueva');
      expect(calls.where((c) => c.startsWith('POST')), hasLength(1));
    });

    test('sube un archivo en dos pasos (dirección de subida y luego el contenido)', () async {
      final tmp = await Directory.systemTemp.createTemp('drive');
      addTearDown(() => tmp.delete(recursive: true));
      final f = File('${tmp.path}/a.jpg')..writeAsBytesSync([1, 2, 3, 4]);
      final client = DriveClient(
        MockClient.streaming((r, body) async {
          final bytes = await body.expand((x) => x).toList();
          if (r.method == 'POST') {
            expect(r.url.queryParameters['uploadType'], 'resumable');
            expect(r.headers['X-Upload-Content-Length'], '4');
            expect(r.headers['Authorization'], 'Bearer token');
            return http.StreamedResponse(const Stream.empty(), 200, headers: {'location': 'https://subida/123'});
          }
          expect(r.method, 'PUT');
          expect(r.url.toString(), 'https://subida/123');
          expect(bytes, [1, 2, 3, 4]);
          return http.StreamedResponse(Stream.value(utf8.encode('{"id":"x1"}')), 200);
        }),
        () async => 'token',
      );
      expect(await client.upload(f, name: 'a.jpg', parentId: 'p', mime: 'image/jpeg'), 'x1');
    });

    test('un error de permiso se explica en palabras simples', () async {
      final client = DriveClient(MockClient((_) async => http.Response('{}', 401)), () async => 't');
      await expectLater(
        client.about(),
        throwsA(isA<DriveException>().having((e) => e.message, 'mensaje', contains('la sesión de Google expiró'))),
      );
    });
  });

  group('sincronización con Drive', () {
    late AppDatabase db;
    late Directory tmp;
    late PhotoStore photos;
    late FakeDrive drive;
    late DriveSync sync;

    setUp(() async {
      db = await testDatabase();
      tmp = await Directory.systemTemp.createTemp('drive_sync');
      photos = PhotoStore('${tmp.path}/docs');
      drive = FakeDrive();
      sync = DriveSync(
        db: db,
        photoStore: photos,
        drive: drive,
        backup: BackupService(db: db, photoStore: photos, tempDir: '${tmp.path}/cache'),
      );
      final catalog = CatalogRepository(db);
      final projects = ProjectRepository(db);
      final sampling = SamplingRepository(db, photos);
      final crop = (await catalog.watchCrops().first).single;
      final scale = await catalog.defaultScale(crop.id);
      final pid = await projects.createProject(
        cropId: crop.id,
        scaleId: scale.id,
        kind: ProjectKind.varietyTrial,
        name: 'Ensayo',
        seasonName: '2026-27',
        week1Start: DateTime.utc(2026, 9, 7),
      );
      final season = (await projects.watchCurrentSeason(pid).first)!;
      final unit = await projects.createUnit(projectId: pid, label: 'Heritage');
      final src = File('${tmp.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
      for (final week in [7, 8]) {
        final obs = await sampling.ensureObservation(season.id, unit, week);
        await sampling.addPhoto(
          observationId: obs,
          kind: PhotoKind.general,
          sourcePath: src.path,
          takenAt: DateTime(2026, 10, 20 + week),
        );
      }
    });

    tearDown(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });

    test('sube las fotos por proyecto, temporada y semana, y el respaldo', () async {
      expect(await sync.watchPending().first, 2);
      final r = await sync.sync();
      expect(r.uploaded, 2);
      expect(drive.uploads.where((u) => u.endsWith('.jpg')), [
        '/FramBitácora/Ensayo/2026-27/Semana 07/20261027_FRB_HERITAGE_G1.jpg',
        '/FramBitácora/Ensayo/2026-27/Semana 08/20261028_FRB_HERITAGE_G1.jpg',
      ]);
      expect(drive.uploads.last, startsWith('/FramBitácora/Respaldos/FramBitacora_respaldo_'));
      expect(r.backupName, endsWith('.zip'));
      expect(await sync.watchPending().first, 0);
    });

    test('no repite fotos ya subidas y, al cambiar de cuenta, vuelven a quedar pendientes', () async {
      await sync.sync(includeBackup: false);
      final again = await sync.sync(includeBackup: false);
      expect(again.uploaded, 0);
      expect(drive.uploads, hasLength(2));

      await sync.resetUploads();
      expect(await sync.watchPending().first, 2);
      // En la misma cuenta, las fotos que ya están en la carpeta solo se marcan.
      final r = await sync.sync(includeBackup: false);
      expect(r.uploaded, 0);
      expect(r.alreadyThere, 2);
    });
  });
}
