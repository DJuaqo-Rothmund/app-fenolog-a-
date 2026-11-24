import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/backup_service.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/drive/data_sync.dart';
import 'package:frambitacora/data/drive/drive_sync.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';

import '../fake_drive.dart';
import '../helpers.dart';

/// Un equipo (teléfono o web) con su propia base y carpeta de fotos.
class Device {
  Device(this.name, this.db, this.photos, this.store, this.drive);
  final String name;
  final AppDatabase db;
  final PhotoStore photos;
  final MemorySyncStateStore store;
  final FakeDrive drive;

  late final catalog = CatalogRepository(db);
  late final projects = ProjectRepository(db);
  late final sampling = SamplingRepository(db, photos);
  late final sync = DriveSync(
    db: db,
    photoStore: photos,
    drive: drive,
    backup: BackupService(db: db, photoStore: photos, tempDir: '${photos.rootPath}-cache'),
    data: DataSync(db: db, drive: drive, store: store),
  );

  Future<DriveSyncResult> run() => sync.sync(includeBackup: false);

  Future<String> stageId(String code) async =>
      (await (db.select(db.phenoStages)..where((s) => s.code.equals(code))).getSingle()).id;

  Future<Observation> observation(String id) => (db.select(db.observations)..where((o) => o.id.equals(id))).getSingle();

  Future<List<Observation>> observations() => db.select(db.observations).get();
}

/// Espera un instante para que dos cambios no tengan la misma fecha.
Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  late Directory tmp;
  late FakeDrive drive;
  late Device phone, web;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('frambitacora_sync');
    drive = FakeDrive();
    Future<Device> device(String name) async =>
        Device(name, await testDatabase(), PhotoStore('${tmp.path}/$name'), MemorySyncStateStore(name), drive);
    phone = await device('telefono');
    web = await device('web');
  });

  tearDown(() async {
    await phone.db.close();
    await web.db.close();
    await tmp.delete(recursive: true);
  });

  /// Proyecto con una variedad en el teléfono y su registro de la semana 3.
  Future<({String project, String season, String unit, String obs})> fieldWork() async {
    final crop = await phone.db.select(phone.db.crops).getSingle();
    final scale = await phone.catalog.defaultScale(crop.id);
    final project = await phone.projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: 'Nuevas variedades',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = (await phone.projects.watchCurrentSeason(project).first)!.id;
    final unit = await phone.projects.createUnit(projectId: project, label: 'Regina');
    final obs = await phone.sampling.ensureObservation(season, unit, 3);
    await phone.sampling.setStage(obs, await phone.stageId('11'));
    await phone.sampling.setNotes(obs, 'brotación pareja');
    final src = File('${tmp.path}/foto.jpg')..writeAsBytesSync([7, 7, 7]);
    await phone.sampling.addPhoto(
      observationId: obs,
      kind: PhotoKind.general,
      sourcePath: src.path,
      takenAt: DateTime(2026, 9, 22),
    );
    return (project: project, season: season, unit: unit, obs: obs);
  }

  test('lo del teléfono llega a la web, con su estado y su foto', () async {
    final f = await fieldWork();
    final up = await phone.run();
    expect(up.uploaded, 1);
    expect(up.sent, greaterThan(0));
    expect(drive.paths.where((p) => p.startsWith('/FramBitácora/datos/telefono/')), hasLength(1));

    final down = await web.run();
    expect(down.received, greaterThan(0));
    expect(down.downloaded, 1);
    final project = await web.projects.watchProject(f.project).first;
    expect(project.name, 'Nuevas variedades');
    final obs = await web.observation(f.obs);
    expect(obs.notes, 'brotación pareja');
    expect(obs.stageId, await web.stageId('11'), reason: 'el estadio apunta al catálogo de la web');
    final photo = await web.db.select(web.db.photos).getSingle();
    expect(web.photos.file(photo.localPath).readAsBytesSync(), [7, 7, 7]);
    expect(await web.db.select(web.db.crops).get(), hasLength(1), reason: 'el catálogo no se duplica');
    expect(
      await web.db.select(web.db.phenoStages).get(),
      hasLength(await phone.db.select(phone.db.phenoStages).get().then((s) => s.length)),
    );

    // Sin cambios nuevos, nada más viaja (y la web no reenvía lo que recibió).
    final again = await web.run();
    expect(again.received, 0);
    expect(again.downloaded, 0);
    expect(again.sent, 0);
    final back = await phone.run();
    expect(back.received, lessThan(10), reason: 'solo ajustes del catálogo, no un reenvío completo');
  });

  test('una corrección hecha en la web llega al teléfono', () async {
    final f = await fieldWork();
    await phone.run();
    await web.run();
    await tick();

    await web.sampling.setStage(f.obs, await web.stageId('13'));
    await web.sampling.setNotes(f.obs, 'corregido en la web');
    await web.run();
    final r = await phone.run();
    expect(r.received, greaterThanOrEqualTo(1));
    final obs = await phone.observation(f.obs);
    expect(obs.notes, 'corregido en la web');
    expect(obs.stageId, await phone.stageId('13'));
  });

  test('si el mismo registro cambió en los dos lados, queda el cambio más reciente', () async {
    final f = await fieldWork();
    await phone.run();
    await web.run();

    await tick();
    await phone.sampling.setNotes(f.obs, 'primero (teléfono)');
    await tick();
    await web.sampling.setNotes(f.obs, 'después (web)');

    // El orden de sincronización no importa.
    await web.run();
    await phone.run();
    await web.run();
    expect((await phone.observation(f.obs)).notes, 'después (web)');
    expect((await web.observation(f.obs)).notes, 'después (web)');
  });

  test('si los dos equipos crean el registro de la misma semana, se unen en uno', () async {
    final f = await fieldWork();
    await phone.run();
    await web.run();

    // Sin conexión, ambos registran la semana 4 de la misma unidad.
    final mine = await phone.sampling.ensureObservation(f.season, f.unit, 4);
    await phone.sampling.setNotes(mine, 'desde el teléfono');
    final src = File('${tmp.path}/b.jpg')..writeAsBytesSync([1, 2]);
    await phone.sampling.addPhoto(observationId: mine, kind: PhotoKind.detail, sourcePath: src.path);
    await tick();
    final theirs = await web.sampling.ensureObservation(f.season, f.unit, 4);
    await web.sampling.setStage(theirs, await web.stageId('15'));
    expect(mine, isNot(theirs));

    for (var i = 0; i < 2; i++) {
      await phone.run();
      await web.run();
    }

    for (final d in [phone, web]) {
      final week4 = (await d.observations()).where((o) => o.weekNumber == 4).toList();
      expect(week4, hasLength(1), reason: d.name);
      expect(week4.single.id, mine.compareTo(theirs) < 0 ? mine : theirs, reason: 'mismo id en ${d.name}');
      expect(week4.single.stageId, await d.stageId('15'), reason: d.name);
      final photos = await (d.db.select(d.db.photos)..where((p) => p.observationId.equals(week4.single.id))).get();
      expect(photos, hasLength(1), reason: 'la foto del teléfono sigue unida al registro en ${d.name}');
    }
    final photo = await (web.db.select(web.db.photos)..where((p) => p.kind.equals('detail'))).getSingle();
    expect(web.photos.file(photo.localPath).readAsBytesSync(), [1, 2]);
  });

  test('un borrado viaja como borrado (no desaparece el historial)', () async {
    final f = await fieldWork();
    await phone.run();
    await web.run();
    await tick();
    await web.projects.deleteUnit(f.unit);
    await web.run();
    await phone.run();
    expect(await phone.projects.watchUnits(f.project).first, isEmpty);
    expect(await phone.observations(), hasLength(1), reason: 'los registros se conservan');
  });

  test('tras restaurar una copia, se vuelve a enviar todo', () async {
    await fieldWork();
    await phone.run();
    final before = (await phone.store.load()).lastPush;
    expect(before, isNotNull);
    await phone.store.afterRestore();
    expect((await phone.store.load()).lastPush, isNull);
    final r = await phone.run();
    expect(r.sent, greaterThan(10));
  });

  test('los archivos de cambios se ordenan por fecha', () {
    final a = DataSync.changeFileName(DateTime.utc(2026, 11, 24, 9, 5, 3));
    final b = DataSync.changeFileName(DateTime.utc(2026, 11, 24, 10, 0));
    expect(a, startsWith('20261124T090503Z-'));
    expect(a.compareTo(b), lessThan(0));
    // Dentro del mismo segundo, los microsegundos van con ceros: 91234 < 744421.
    final early = DataSync.changeFileName(DateTime.utc(2026, 11, 24, 9, 5, 3, 91, 234));
    final late = DataSync.changeFileName(DateTime.utc(2026, 11, 24, 9, 5, 3, 744, 421));
    expect(early, '20261124T090503Z-091234.json');
    expect(early.compareTo(late), lessThan(0));
  });
}
