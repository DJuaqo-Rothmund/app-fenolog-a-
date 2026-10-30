import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/measurement_repository.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/data/sync/sync_api.dart';
import 'package:frambitacora/data/sync/sync_engine.dart';
import 'package:frambitacora/domain/measurement.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../helpers.dart';

/// Un teléfono de prueba: su base, sus fotos y su motor de sincronización.
class Phone {
  Phone._(this.db, this.dir, this.engine);
  final AppDatabase db;
  final Directory dir;
  final SyncEngine engine;

  late final catalog = CatalogRepository(db);
  late final projects = ProjectRepository(db);
  late final sampling = SamplingRepository(db, PhotoStore(baseDir: () async => dir));
  late final measurements = MeasurementRepository(db);

  static Future<Phone> create(http.Client client) async {
    final db = await testDatabase();
    final dir = await Directory.systemTemp.createTemp('telefono');
    return Phone._(db, dir, SyncEngine(db, PhotoStore(baseDir: () async => dir), client: client));
  }

  Future<void> dispose() async {
    await db.close();
    await dir.delete(recursive: true);
  }
}

/// Conecta el cliente HTTP de la app directamente con el servidor (sin red).
http.Client clientFor(shelf.Handler handler) => MockClient((req) async {
  final res = await handler(shelf.Request(req.method, req.url, body: req.bodyBytes, headers: req.headers));
  final bytes = await res.read().expand((c) => c).toList();
  return http.Response.bytes(bytes, res.statusCode, headers: res.headers);
});

Future<Pool<void>?> testPool() async {
  final env = Platform.environment;
  final pool = Pool<void>.withEndpoints([
    Endpoint(
      host: env['TEST_DB_HOST'] ?? 'localhost',
      port: int.parse(env['TEST_DB_PORT'] ?? '5433'),
      database: env['TEST_DB_NAME'] ?? 'frambitacora_test',
      username: env['TEST_DB_USER'] ?? 'postgres',
    ),
  ], settings: const PoolSettings(sslMode: SslMode.disable));
  try {
    await pool.execute('SELECT 1');
    return pool;
  } catch (_) {
    await pool.close();
    return null;
  }
}

void main() {
  Pool<void>? pool;
  late Directory serverPhotos;
  late http.Client client;
  late Phone a, b;
  const url = 'http://servidor.test';

  setUpAll(() async => pool = await testPool());

  setUp(() async {
    if (pool == null) return;
    await pool!.execute('DROP TABLE IF EXISTS tokens, users, sync_rows, photo_files');
    await pool!.execute('DROP SEQUENCE IF EXISTS sync_seq');
    serverPhotos = await Directory.systemTemp.createTemp('servidor_fotos');
    final server = SyncServer(pool!, photosDir: serverPhotos);
    await server.init(ownerEmail: 'duenno@campo.cl', ownerPassword: 'clave-segura');
    client = clientFor(server.handler);
    a = await Phone.create(client);
    b = await Phone.create(client);
    for (final p in [a, b]) {
      await p.engine.login(serverUrl: url, email: 'duenno@campo.cl', password: 'clave-segura');
    }
  });

  tearDown(() async {
    if (pool == null) return;
    await a.dispose();
    await b.dispose();
    await serverPhotos.delete(recursive: true);
  });

  tearDownAll(() async => pool?.close());

  bool skip() {
    if (pool == null) markTestSkipped('Sin PostgreSQL de pruebas (ver docs/06-servidor.md).');
    return pool == null;
  }

  test('un proyecto creado en A aparece completo en B, con foto y mediciones', () async {
    if (skip()) return;
    final crop = (await a.catalog.watchCrops().first).single;
    final scale = await a.catalog.defaultScale(crop.id);
    final projectId = await a.projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: 'Ensayo compartido',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = (await a.projects.watchCurrentSeason(projectId).first)!;
    final variety = await a.catalog.createVariety(cropId: crop.id, name: 'Heritage');
    final unit = await a.projects.createUnit(projectId: projectId, label: 'Heritage', varietyId: variety);
    final obs = await a.sampling.ensureObservation(season.id, unit, 3);
    final stage = (await a.catalog.watchStages(scale.id).first).firstWhere((s) => s.code == '61');
    await a.sampling.setStage(obs, stage.id);
    final def = await a.measurements.createDef(
      projectId: projectId,
      name: 'Flores',
      kind: MeasurementKind.integer,
      scope: MeasurementScope.observation,
    );
    await a.measurements.setObservationValue(obs, def, (number: 7, text: null));
    final src = File('${a.dir.path}/origen.jpg')..writeAsBytesSync([0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);
    await a.sampling.addPhoto(observationId: obs, kind: PhotoKind.detail, sourcePath: src.path);

    final ra = await a.engine.sync();
    expect(ra.pushed, greaterThan(40), reason: 'catálogo + proyecto');
    expect(ra.photosUp, 1);
    expect(await a.engine.watchPending().first, 0);

    final rb = await b.engine.sync();
    expect(rb.photosDown, 1);
    final project = (await b.projects.watchProjects().first).single;
    expect(project.name, 'Ensayo compartido');
    final rows = await b.sampling.watchWeek(projectId: project.id, seasonId: season.id, week: 3).first;
    expect(rows.single.stageCode, '61');
    expect(rows.single.isComplete, isTrue);
    expect((await b.measurements.watchObservationValues(obs).first)[def]!.valueNum, 7);
    final photo = (await b.sampling.watchPhotos(obs).first).single;
    expect(File(photo.localPath).readAsBytesSync(), [0xFF, 0xD8, 1, 2, 3, 0xFF, 0xD9]);
    expect(photo.localPath, startsWith(b.dir.path));

    // Lo recibido no se reenvía.
    expect(await b.engine.watchPending().first, 0);
    expect((await b.db.select(b.db.crops).get()), hasLength(1), reason: 'el frambueso no se duplica');
  });

  test('la edición más reciente gana y se propaga en ambos sentidos', () async {
    if (skip()) return;
    final crop = (await a.catalog.watchCrops().first).single;
    final v = await a.catalog.createVariety(cropId: crop.id, name: 'Heritage');
    await a.engine.sync();
    await b.engine.sync();

    await a.catalog.updateVariety(v, name: 'Heritage (A)', code: '', notes: '');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await b.catalog.updateVariety(v, name: 'Heritage (B, más reciente)', code: '', notes: '');

    await a.engine.sync();
    await b.engine.sync(); // B envía su versión, más nueva; la de A no la pisa.
    await a.engine.sync();
    for (final p in [a, b]) {
      expect((await p.catalog.watchVarieties(crop.id).first).single.name, 'Heritage (B, más reciente)');
    }
  });

  test('dos teléfonos registran la misma unidad y semana: un solo registro', () async {
    if (skip()) return;
    final crop = (await a.catalog.watchCrops().first).single;
    final scale = await a.catalog.defaultScale(crop.id);
    final projectId = await a.projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.farm,
      name: 'Predio',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = (await a.projects.watchCurrentSeason(projectId).first)!;
    final unit = await a.projects.createUnit(projectId: projectId, label: 'Sector 1');
    await a.engine.sync();
    await b.engine.sync();

    final stages = await a.catalog.watchStages(scale.id).first;
    final oa = await a.sampling.ensureObservation(season.id, unit, 5);
    await a.sampling.setNotes(oa, 'nota de A');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final ob = await b.sampling.ensureObservation(season.id, unit, 5);
    await b.sampling.setStage(ob, stages[3].id);
    expect(ob, oa, reason: 'mismo id en ambos teléfonos');

    await a.engine.sync();
    await b.engine.sync();
    await a.engine.sync();
    final obs = await a.db.select(a.db.observations).get();
    expect(obs, hasLength(1));
    expect(obs.single.stageId, stages[3].id);
  });

  test('un lector recibe pero no envía', () async {
    if (skip()) return;
    final owner = SyncApi(client, url, token: (await a.engine.session())!.token);
    await owner.addUser(email: 'lector@campo.cl', name: 'Lector', role: 'viewer', password: 'lector-123');
    await b.engine.logout();
    await b.engine.login(serverUrl: url, email: 'lector@campo.cl', password: 'lector-123');

    final crop = (await a.catalog.watchCrops().first).single;
    await a.catalog.createVariety(cropId: crop.id, name: 'De A');
    await b.catalog.createVariety(cropId: crop.id, name: 'De B');
    await a.engine.sync();
    final rb = await b.engine.sync();
    expect(rb.readOnly, isTrue);
    expect(rb.pushed, 0);
    await a.engine.sync();
    expect((await a.catalog.watchVarieties(crop.id).first).map((v) => v.name), ['De A']);
    expect((await b.catalog.watchVarieties(crop.id).first).map((v) => v.name), containsAll(['De A', 'De B']));
  });

  test('sin sesión o con clave mala, errores en español', () async {
    if (skip()) return;
    await a.engine.logout();
    await expectLater(a.engine.sync(), throwsA(isA<SyncException>()));
    await expectLater(
      a.engine.login(serverUrl: url, email: 'duenno@campo.cl', password: 'mala'),
      throwsA(isA<SyncException>().having((e) => e.message, 'mensaje', 'Correo o contraseña incorrectos.')),
    );
  });
}
