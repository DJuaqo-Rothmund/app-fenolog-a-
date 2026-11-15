import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/crop_importer.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/crop_definition.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/domain/season_review.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late CatalogRepository catalog;
  late ProjectRepository projects;
  late SamplingRepository sampling;
  late Crop crop;
  late PhenoScale scale;

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('frambitacora_test');
    catalog = CatalogRepository(db);
    projects = ProjectRepository(db);
    sampling = SamplingRepository(db, PhotoStore(tmp.path));
    crop = (await catalog.watchCrops().first).single;
    scale = await catalog.defaultScale(crop.id);
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  Future<File> sourceImage() async {
    final f = File('${tmp.path}/origen_${DateTime.now().microsecondsSinceEpoch}.jpg');
    await f.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);
    return f;
  }

  Future<({String projectId, String seasonId})> newProject() async {
    final id = await projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.varietyTrial,
      name: 'Ensayo 2026',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final season = await projects.watchCurrentSeason(id).first;
    return (projectId: id, seasonId: season!.id);
  }

  group('importación de cultivos', () {
    test('carga la escala con sus macroestadios y estadios en orden', () async {
      expect(crop.code, 'rubus-idaeus');
      final stages = await catalog.watchStages(scale.id).first;
      final macros = await catalog.watchMacros(scale.id).first;
      expect(stages.first.code, '00');
      expect(stages.map((s) => s.sortOrder), List.generate(stages.length, (i) => i));
      expect(macros.map((m) => m.code), ['0', '1', '3', '5', '6', '7', '8', '9']);
    });

    test('es idempotente: importar dos veces no duplica nada', () async {
      await CropImporter(db).importDefinition(raspberryDefinition());
      expect(await db.select(db.crops).get(), hasLength(1));
      expect(await db.select(db.phenoScales).get(), hasLength(1));
      expect(await db.select(db.phenoStages).get(), hasLength(raspberryDefinition().scales.single.stages.length));
    });

    test('una versión mayor actualiza los textos sin borrar estadios', () async {
      final def = raspberryDefinition();
      final old = def.scales.single;
      final renamed = StageDef(code: '00', macro: '0', name: 'Reposo (v2)', description: '', color: 0xFF000000);
      final v2 = CropDefinition(
        code: def.code,
        shortCode: def.shortCode,
        name: def.name,
        scientificName: def.scientificName,
        seasonStartMonth: def.seasonStartMonth,
        seasonStartDay: def.seasonStartDay,
        scales: [
          ScaleDef(name: old.name, version: 2, isDefault: true, macros: old.macros, stages: [renamed]),
        ],
      );
      await CropImporter(db).importDefinition(v2);
      final stages = await catalog.watchStages(scale.id).first;
      expect(stages, hasLength(old.stages.length));
      expect(stages.firstWhere((s) => s.code == '00').name, 'Reposo (v2)');
    });
  });

  group('variedades', () {
    test('crear, editar y archivar', () async {
      final id = await catalog.createVariety(cropId: crop.id, name: ' Heritage ', code: 'HER');
      await catalog.updateVariety(id, name: 'Heritage', code: 'HE', notes: 'remontante');
      var list = await catalog.watchVarieties(crop.id).first;
      expect(list.single.name, 'Heritage');
      expect(list.single.notes, 'remontante');

      await catalog.setVarietyArchived(id, true);
      expect(await catalog.watchVarieties(crop.id).first, isEmpty);
      list = await catalog.watchVarieties(crop.id, includeArchived: true).first;
      expect(list.single.archived, isTrue);
    });
  });

  group('proyectos y unidades', () {
    test('crear un proyecto crea también su temporada', () async {
      final p = await newProject();
      final season = await projects.watchCurrentSeason(p.projectId).first;
      expect(season!.week1Start, DateTime.utc(2026, 9, 7));
      expect((await projects.watchProjects().first).single.kind, 'varietyTrial');
    });

    test('las unidades se ordenan en el orden en que se crean', () async {
      final p = await newProject();
      await projects.createUnit(projectId: p.projectId, label: 'Zeta');
      await projects.createUnit(projectId: p.projectId, label: 'Alfa');
      expect((await projects.watchUnits(p.projectId).first).map((u) => u.label), ['Zeta', 'Alfa']);
    });

    test('agregar variedades al ensayo no repite las que ya están', () async {
      final p = await newProject();
      final her = await catalog.createVariety(cropId: crop.id, name: 'Heritage');
      await catalog.createVariety(cropId: crop.id, name: 'Tulameen');
      final all = await catalog.watchVarieties(crop.id).first;

      await projects.addVarietyUnits(p.projectId, all.where((v) => v.id == her).toList());
      expect(await projects.addVarietyUnits(p.projectId, all), 1, reason: 'Heritage ya estaba');
      final units = await projects.watchUnits(p.projectId).first;
      expect(units.map((u) => u.label), ['Heritage', 'Tulameen']);
      expect(units.first.varietyId, her);
    });

    test('ensayo de tratamientos: crear, describir y modificar el diseño', () async {
      final p = await newProject();
      var r = await projects.configureTreatmentTrial(p.projectId, treatments: 2, replicates: 3, hasControl: true);
      expect(r.added, 9, reason: '(T0 + T1 + T2) × 3 repeticiones');
      var units = await projects.watchUnits(p.projectId).first;
      expect(units.take(4).map((u) => u.label), ['T0 R1', 'T1 R1', 'T2 R1', 'T0 R2']);
      var treatments = await projects.watchTreatments(p.projectId).first;
      expect(treatments.map((t) => t.code), ['T0', 'T1', 'T2']);
      expect(treatments.first.isControl, isTrue);
      expect(treatments.first.description, 'Testigo');

      await projects.setTreatmentDescription(treatments[1].id, ' 2 L/ha producto A ');

      // Un tratamiento y una repetición más: solo se agregan las que faltan.
      r = await projects.configureTreatmentTrial(p.projectId, treatments: 3, replicates: 4, hasControl: true);
      expect(r, (added: 7, removed: 0));
      units = await projects.watchUnits(p.projectId).first;
      expect(units, hasLength(16));
      expect(units.take(4).map((u) => u.label), ['T0 R1', 'T1 R1', 'T2 R1', 'T3 R1'], reason: 'orden de campo');
      treatments = await projects.watchTreatments(p.projectId).first;
      expect(treatments[1].description, '2 L/ha producto A', reason: 'la descripción se conserva');

      // Sin testigo y con 2 repeticiones: se quitan T0 y las repeticiones 3 y 4.
      r = await projects.configureTreatmentTrial(p.projectId, treatments: 3, replicates: 2, hasControl: false);
      expect(r, (added: 0, removed: 10));
      expect((await projects.watchTreatments(p.projectId).first).map((t) => t.code), ['T1', 'T2', 'T3']);
      expect((await projects.watchProject(p.projectId).first).replicates, 2);
    });

    test('eliminar una unidad la oculta', () async {
      final p = await newProject();
      final u = await projects.createUnit(projectId: p.projectId, label: 'A');
      await projects.deleteUnit(u);
      expect(await projects.watchUnits(p.projectId).first, isEmpty);
    });
  });

  group('registro semanal', () {
    test('un registro está completo con estado y una foto', () async {
      final p = await newProject();
      final unitA = await projects.createUnit(projectId: p.projectId, label: 'Heritage');
      await projects.createUnit(projectId: p.projectId, label: 'Tulameen');

      var rows = await sampling.watchWeek(projectId: p.projectId, seasonId: p.seasonId, week: 3).first;
      expect(rows, hasLength(2));
      expect(rows.where((r) => r.isComplete), isEmpty);

      final obs = await sampling.ensureObservation(p.seasonId, unitA, 3);
      expect(await sampling.ensureObservation(p.seasonId, unitA, 3), obs, reason: 'no se duplica');

      final stage = (await catalog.watchStages(scale.id).first).firstWhere((s) => s.code == '61');
      await sampling.setStage(obs, stage.id);
      rows = await sampling.watchWeek(projectId: p.projectId, seasonId: p.seasonId, week: 3).first;
      expect(rows.first.stageCode, '61');
      expect(rows.first.isComplete, isFalse);

      await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.detail,
        sourcePath: (await sourceImage()).path,
        takenAt: DateTime(2026, 9, 21),
      );
      rows = await sampling.watchWeek(projectId: p.projectId, seasonId: p.seasonId, week: 3).first;
      expect(rows.first.photoCount, 1);
      expect(rows.first.isComplete, isTrue);
      expect(rows.last.isComplete, isFalse);

      // Otra semana no se ve afectada.
      rows = await sampling.watchWeek(projectId: p.projectId, seasonId: p.seasonId, week: 4).first;
      expect(rows.where((r) => r.observationId != null), isEmpty);
    });

    test('las fotos reciben nombre uniforme y correlativo, y se pueden borrar', () async {
      final p = await newProject();
      final unit = await projects.createUnit(projectId: p.projectId, label: 'Heritage');
      final obs = await sampling.ensureObservation(p.seasonId, unit, 1);

      final date = DateTime(2026, 9, 8);
      final a = await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.general,
        sourcePath: (await sourceImage()).path,
        takenAt: date,
      );
      final b = await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.general,
        sourcePath: (await sourceImage()).path,
        takenAt: date,
      );
      final c = await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.detail,
        sourcePath: (await sourceImage()).path,
        takenAt: date,
      );

      expect(
        [a.fileName, b.fileName, c.fileName],
        ['20260908_FRB_HERITAGE_G1.jpg', '20260908_FRB_HERITAGE_G2.jpg', '20260908_FRB_HERITAGE_D1.jpg'],
      );
      expect(a.localPath, 'fotos/${p.seasonId}/20260908_FRB_HERITAGE_G1.jpg', reason: 'ruta relativa');
      expect(sampling.photoStore.file(a.localPath).existsSync(), isTrue);

      await sampling.deletePhoto(a);
      expect(sampling.photoStore.file(a.localPath).existsSync(), isFalse);
      expect(await sampling.watchPhotos(obs).first, hasLength(2));

      // Tras borrar, el correlativo no se reutiliza.
      final d = await sampling.addPhoto(
        observationId: obs,
        kind: PhotoKind.general,
        sourcePath: (await sourceImage()).path,
        takenAt: date,
      );
      expect(d.fileName, '20260908_FRB_HERITAGE_G3.jpg');
    });

    test('notas y ubicación', () async {
      final p = await newProject();
      final unit = await projects.createUnit(projectId: p.projectId, label: 'A');
      final obs = await sampling.ensureObservation(p.seasonId, unit, 2);
      await sampling.setNotes(obs, 'Primeras flores en el tercio superior');
      await sampling.setLocation(obs, lat: -40.57, lon: -73.13, accuracyM: 6);
      var o = await sampling.watchObservation(p.seasonId, unit, 2).first;
      expect(o!.notes, 'Primeras flores en el tercio superior');
      expect(o.lat, -40.57);

      await sampling.setLocation(obs);
      o = await sampling.watchObservation(p.seasonId, unit, 2).first;
      expect(o!.lat, isNull);
    });

    test('marcar y desmarcar una semana como no muestreada', () async {
      final p = await newProject();
      expect(await sampling.watchWeekNotSampled(p.seasonId, 5).first, isFalse);
      await sampling.setWeekNotSampled(p.seasonId, 5, true);
      expect(await sampling.watchWeekNotSampled(p.seasonId, 5).first, isTrue);
      await sampling.setWeekNotSampled(p.seasonId, 5, false);
      expect(await sampling.watchWeekNotSampled(p.seasonId, 5).first, isFalse);
      expect(await db.select(db.weekStatuses).get(), hasLength(1));
    });
  });

  group('revisión de la temporada', () {
    test('la grilla trae cada registro con estado y fotos, y marca retrocesos', () async {
      final p = await newProject();
      final a = await projects.createUnit(projectId: p.projectId, label: 'Heritage');
      final b = await projects.createUnit(projectId: p.projectId, label: 'Tulameen');
      final stages = await catalog.watchStages(scale.id).first;
      final late = stages.firstWhere((s) => s.code == '55');
      final early = stages.firstWhere((s) => s.code == '51');

      final o1 = await sampling.ensureObservation(p.seasonId, a, 6);
      await sampling.setStage(o1, late.id);
      await sampling.addPhoto(observationId: o1, kind: PhotoKind.general, sourcePath: (await sourceImage()).path);
      final o2 = await sampling.ensureObservation(p.seasonId, a, 7);
      await sampling.setStage(o2, early.id);
      await sampling.addPhoto(observationId: o2, kind: PhotoKind.general, sourcePath: (await sourceImage()).path);
      await sampling.ensureObservation(p.seasonId, b, 7); // registro vacío: no cuenta

      var grid = await sampling.watchSeasonGrid(projectId: p.projectId, seasonId: p.seasonId).first;
      expect(grid.units.map((u) => u.label), ['Heritage', 'Tulameen']);
      expect(grid.cells[a]!.keys, [6, 7]);
      expect(grid.cells[a]![7]!.stageCode, '51');
      expect(grid.cells[a]![7]!.photoCount, 1);
      expect(grid.cells.containsKey(b), isFalse);
      expect(grid.lastWeekWithData, 7);
      expect(grid.alerts.single.kind, AlertKind.regression);

      // Al corregir el estado, la alerta desaparece.
      await sampling.setStage(o2, late.id);
      grid = await sampling.watchSeasonGrid(projectId: p.projectId, seasonId: p.seasonId).first;
      expect(grid.alerts, isEmpty);
    });
  });
}
