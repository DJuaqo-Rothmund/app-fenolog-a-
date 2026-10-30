import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/backup.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/csv_importer.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/excel_export.dart';
import 'package:frambitacora/data/measurement_repository.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/data/season_data.dart';
import 'package:frambitacora/data/season_tables.dart';
import 'package:frambitacora/domain/measurement.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late CatalogRepository catalog;
  late ProjectRepository projects;
  late SamplingRepository sampling;
  late MeasurementRepository measurements;
  late String projectId;
  late String seasonId;
  late String heritageUnit;
  late String brote;

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('frambitacora_export');
    catalog = CatalogRepository(db);
    projects = ProjectRepository(db);
    sampling = SamplingRepository(db, PhotoStore(baseDir: () async => tmp));
    measurements = MeasurementRepository(db);

    final crop = (await catalog.watchCrops().first).single;
    final scale = await catalog.defaultScale(crop.id);
    projectId = await projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: 'Ensayo 2026',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    seasonId = (await projects.watchCurrentSeason(projectId).first)!.id;
    final heritage = await catalog.createVariety(cropId: crop.id, name: 'Heritage');
    heritageUnit = await projects.createUnit(projectId: projectId, label: 'Heritage', varietyId: heritage);
    await projects.createUnit(projectId: projectId, label: 'Tulameen');
    brote = await measurements.createDef(
      projectId: projectId,
      name: 'Largo de brote',
      kind: MeasurementKind.number,
      scope: MeasurementScope.observation,
      unit: 'cm',
    );
    final rend = await measurements.createDef(
      projectId: projectId,
      name: 'Rendimiento',
      kind: MeasurementKind.number,
      scope: MeasurementScope.varietySeason,
    );
    await measurements.setVarietyValue(
      seasonId: seasonId,
      varietyId: heritage,
      defId: rend,
      value: (number: 12000, text: null),
    );

    final stage = (await catalog.watchStages(scale.id).first).firstWhere((s) => s.code == '61');
    final obs = await sampling.ensureObservation(seasonId, heritageUnit, 3);
    await sampling.setStage(obs, stage.id);
    await sampling.setNotes(obs, 'flores; abiertas');
    await measurements.setObservationValue(obs, brote, (number: 12.5, text: null));
    final src = File('${tmp.path}/src.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xD9]);
    await sampling.addPhoto(
      observationId: obs,
      kind: PhotoKind.detail,
      sourcePath: src.path,
      takenAt: DateTime(2026, 9, 21),
    );
    await sampling.setWeekNotSampled(seasonId, 4, true);
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('las tablas de la temporada reúnen registros, matriz y parámetros', () async {
    final d = await loadSeasonData(db, seasonId);
    final records = recordsTable(d);
    expect(records.first.last, 'Largo de brote (cm)');
    final row = records[1];
    expect(row[0], 3);
    expect(row[3], 'Heritage');
    expect(row[9], '61');
    expect(row[11], 1);
    expect(row[12], 'Sí');
    expect(row.last, 12.5);

    final matrix = stageMatrixTable(d);
    expect(matrix.first, ['Unidad', 'Variedad', 'S3', 'S4']);
    expect(matrix[1], ['Heritage', 'Heritage', '61', 'NM']);
    expect(matrix[2], ['Tulameen', null, null, 'NM']);

    expect(varietyParamsTable(d)[1], ['Heritage', 12000.0]);
  });

  test('el Excel tiene las hojas esperadas', () async {
    final bytes = buildSeasonWorkbook(await loadSeasonData(db, seasonId));
    final excel = Excel.decodeBytes(bytes);
    expect(excel.tables.keys, containsAll(['Registros', 'Matriz de estadios', 'Parámetros por variedad', 'Escala']));
    expect(excel.tables.keys, isNot(contains('Sheet1')));
    final registros = excel.tables['Registros']!;
    expect(registros.maxRows, 2);
    expect(registros.rows[1][3]!.value.toString(), 'Heritage');
  });

  test('CSV exportado se vuelve a importar en otra temporada', () async {
    final csv = toCsv(recordsTable(await loadSeasonData(db, seasonId)));
    expect(csv, contains('"flores; abiertas"'));
    expect(csv, contains('12,5'));

    final other = await projects.createSeason(
      projectId: projectId,
      name: '2025-26',
      week1Start: DateTime.utc(2025, 9, 8),
    );
    final summary = await SeasonCsvImporter(db, projects, sampling, measurements).import(other, csv);
    expect(summary.errors, isEmpty);
    expect(summary.imported, 1);
    expect(summary.createdUnits, isEmpty);

    final d = await loadSeasonData(db, other);
    final r = d.records.single;
    expect(r.unit.id, heritageUnit);
    expect(r.week, 3);
    expect(r.stage!.code, '61');
    expect(r.observation.notes, 'flores; abiertas');
    expect(r.values[brote]!.valueNum, 12.5);
  });

  test('la importación crea unidades nuevas y avisa estadios desconocidos', () async {
    final summary = await SeasonCsvImporter(
      db,
      projects,
      sampling,
      measurements,
    ).import(seasonId, 'Semana;Unidad;Estadio;Largo de brote\n5;Nueva;99X;abc\n6;Heritage;Inicio de floración;\n');
    expect(summary.imported, 2);
    expect(summary.createdUnits, ['Nueva']);
    expect(summary.errors, hasLength(2));
    final d = await loadSeasonData(db, seasonId);
    expect(d.record(heritageUnit, 6)!.stage!.code, isNotNull, reason: 'busca el estadio también por nombre');
  });

  test('respaldo: crear, restaurar y corregir rutas de fotos', () async {
    final base = Directory('${tmp.path}/app')..createSync();
    // Las fotos de las pruebas viven en tmp/fotos; el respaldo toma base/fotos.
    Directory('${tmp.path}/fotos').renameSync('${base.path}/fotos');
    final service = BackupService(() async => base);
    final out = Directory('${tmp.path}/salida')..createSync();

    final zip = await service.create(db, outDir: out, now: DateTime(2026, 10, 30, 9, 5));
    expect(zip.path, endsWith('FramBitacora_respaldo_20261030_0905.zip'));
    final names = ZipDecoder().decodeBytes(zip.readAsBytesSync()).files.map((f) => f.name);
    expect(names, containsAll(['respaldo.json', 'frambitacora.sqlite']));
    expect(names.where((n) => n.startsWith('fotos/') && n.endsWith('_D1.jpg')), hasLength(1));

    // Otro "teléfono": carpeta distinta.
    final otherBase = Directory('${tmp.path}/otro')..createSync();
    final other = BackupService(() async => otherBase);
    await other.stageRestore(zip.path);
    expect(await other.applyPendingRestore(), isTrue);
    expect(await other.applyPendingRestore(), isFalse);

    final restored = AppDatabase(NativeDatabase(File('${otherBase.path}/frambitacora.sqlite')));
    expect(await other.relocatePhotos(restored), 1);
    final photo = (await restored.select(restored.photos).get()).single;
    expect(photo.localPath, startsWith(otherBase.path));
    expect(File(photo.localPath).existsSync(), isTrue);
    expect(await restored.select(restored.measurementValues).get(), hasLength(2));
    await restored.close();
  });

  test('un archivo que no es respaldo se rechaza', () async {
    final base = Directory('${tmp.path}/app')..createSync();
    final bad = File('${tmp.path}/malo.zip')
      ..writeAsBytesSync(ZipEncoder().encode(Archive()..addFile(ArchiveFile('x.txt', 1, [1])))!);
    await expectLater(BackupService(() async => base).stageRestore(bad.path), throwsA(isA<BackupException>()));
    expect(Directory('${base.path}/restaurar_pendiente').existsSync(), isFalse);
  });
}
