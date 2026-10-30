import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/drive_client.dart';
import 'package:frambitacora/data/drive_sync.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/data/season_data.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers.dart';

/// Drive falso en memoria: carpetas y archivos con nombre, padre y contenido.
class FakeDrive {
  final files = <String, ({String name, String parent, String mime, List<int> bytes})>{};
  final pendingUploads = <String, ({String? id, String name, String? parent, String mime})>{};
  var nextId = 0;
  var uploads = 0;

  String add(String name, String parent, String mime, [List<int> bytes = const []]) {
    final id = 'id${nextId++}';
    files[id] = (name: name, parent: parent, mime: mime, bytes: bytes);
    return id;
  }

  List<String> childrenNames(String parent) => [
    for (final f in files.values)
      if (f.parent == parent) f.name,
  ];

  String? idOf(String name, String parent) =>
      files.entries.where((e) => e.value.name == name && e.value.parent == parent).firstOrNull?.key;

  late final client = MockClient.streaming((request, body) async {
    final bytes = await body.toBytes();
    final url = request.url;
    expect(request.headers['Authorization'], 'Bearer token-1');
    http.StreamedResponse json(Object data, [int status = 200, Map<String, String> headers = const {}]) =>
        http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(data))), status, headers: headers);

    if (request.method == 'GET' && url.path == '/drive/v3/files') {
      final q = url.queryParameters['q']!;
      final parent = RegExp(r"^'([^']+)' in parents").firstMatch(q)![1]!;
      final foldersOnly = q.contains('mimeType');
      return json({
        'files': [
          for (final e in files.entries)
            if (e.value.parent == parent && (!foldersOnly || e.value.mime == DriveClient.folderMime))
              {'id': e.key, 'name': e.value.name},
        ],
      });
    }
    if (request.method == 'POST' && url.path == '/drive/v3/files') {
      final meta = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return json({
        'id': add(meta['name'] as String, (meta['parents'] as List).single as String, meta['mimeType'] as String),
      });
    }
    if (url.path.startsWith('/upload/drive/v3/files') && url.queryParameters['uploadType'] == 'resumable') {
      final meta = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final session = 'up${pendingUploads.length}';
      pendingUploads[session] = (
        id: request.method == 'PATCH' ? url.pathSegments.last : null,
        name: meta['name'] as String,
        parent: (meta['parents'] as List?)?.single as String?,
        mime: request.headers['X-Upload-Content-Type']!,
      );
      return json({}, 200, {'location': 'https://upload.example/$session'});
    }
    if (request.method == 'PUT' && url.host == 'upload.example') {
      final up = pendingUploads[url.pathSegments.last]!;
      uploads++;
      if (up.id != null) {
        final old = files[up.id]!;
        files[up.id!] = (name: up.name, parent: old.parent, mime: up.mime, bytes: bytes);
        return json({'id': up.id});
      }
      return json({'id': add(up.name, up.parent!, up.mime, bytes)});
    }
    return json({'error': 'no esperado ${request.method} $url'}, 404);
  });
}

void main() {
  late Directory tmp;
  late FakeDrive drive;
  late DriveClient client;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('frambitacora_drive');
    drive = FakeDrive();
    client = DriveClient(drive.client, () async => 'token-1');
  });

  tearDown(() => tmp.delete(recursive: true));

  test('folder reutiliza la carpeta si ya existe', () async {
    final a = await client.folder('FramBitácora');
    final b = await client.folder('FramBitácora');
    expect(a, b);
    expect(drive.files, hasLength(1));
  });

  test('uploadFile sube y reemplaza contenido', () async {
    final folder = await client.folder('X');
    final f = File('${tmp.path}/a.xlsx')..writeAsBytesSync([1, 2, 3]);
    final id = await client.uploadFile(f, name: 'a.xlsx', parentId: folder, mimeType: mimeTypeFor('a.xlsx'));
    expect(drive.files[id]!.bytes, [1, 2, 3]);

    f.writeAsBytesSync([9]);
    final again = await client.uploadFile(f, name: 'a.xlsx', parentId: folder, mimeType: 'x', replaceId: id);
    expect(again, id);
    expect(drive.files[id]!.bytes, [9]);
    expect(drive.childrenNames(folder), ['a.xlsx']);
  });

  test('un error de Drive se informa en español', () async {
    final failing = DriveClient(MockClient((_) async => http.Response('nope', 401)), () async => 't');
    await expectLater(
      failing.folder('X'),
      throwsA(isA<DriveException>().having((e) => e.message, 'mensaje', contains('la sesión de Google expiró'))),
    );
  });

  test('uploadSeason ordena por proyecto, temporada y semana, sin repetir fotos', () async {
    final db = await testDatabase();
    addTearDown(db.close);
    final catalog = CatalogRepository(db);
    final projects = ProjectRepository(db);
    final sampling = SamplingRepository(db, PhotoStore(baseDir: () async => tmp));
    final crop = (await catalog.watchCrops().first).single;
    final projectId = await projects.createProject(
      cropId: crop.id,
      scaleId: (await catalog.defaultScale(crop.id)).id,
      kind: ProjectKind.varietyTrial,
      name: 'Ensayo 2026',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final seasonId = (await projects.watchCurrentSeason(projectId).first)!.id;
    final unit = await projects.createUnit(projectId: projectId, label: 'Heritage');
    final src = File('${tmp.path}/src.jpg')..writeAsBytesSync([0xFF, 0xD8]);
    for (final week in [1, 2]) {
      final obs = await sampling.ensureObservation(seasonId, unit, week);
      await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.general,
        sourcePath: src.path,
        takenAt: DateTime(2026, 9, week * 7 + 1),
      );
    }
    final excel = File('${tmp.path}/libro.xlsx')..writeAsBytesSync([1]);
    final sync = DriveSync(client);
    final progress = <int>[];

    final first = await sync.uploadSeason(
      await loadSeasonData(db, seasonId),
      workbook: excel,
      onProgress: (done, _) => progress.add(done),
    );
    expect(first.uploadedPhotos, 2);
    expect(progress, [0, 1, 2]);

    final root = drive.idOf('FramBitácora', 'root')!;
    final season = drive.idOf('2026-27', drive.idOf('Ensayo 2026', root)!)!;
    expect(drive.childrenNames(season), containsAll(['Ensayo_2026_2026-27.xlsx', 'fotos']));
    final fotos = drive.idOf('fotos', season)!;
    expect(drive.childrenNames(fotos), ['Semana 01', 'Semana 02']);
    expect(drive.childrenNames(drive.idOf('Semana 01', fotos)!), ['20260908_FRB_HERITAGE_G1.jpg']);

    final uploadsBefore = drive.uploads;
    final second = await sync.uploadSeason(await loadSeasonData(db, seasonId), workbook: excel);
    expect(second.uploadedPhotos, 0);
    expect(second.skippedPhotos, 2);
    expect(drive.uploads - uploadsBefore, 1, reason: 'solo se reemplaza el Excel');
    expect(drive.childrenNames(season).where((n) => n.endsWith('.xlsx')), hasLength(1));
  });
}
