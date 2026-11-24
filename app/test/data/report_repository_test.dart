import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/report_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late CatalogRepository catalog;
  late ProjectRepository projects;
  late SamplingRepository sampling;
  late ReportRepository reports;
  late List<PhenoStage> stages;
  late Crop crop;
  late PhenoScale scale;

  /// La reducción de fotos de prueba devuelve el archivo tal cual.
  Future<Uint8List?> shrink(Uint8List original) async => original;

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('frambitacora_informes');
    final photos = PhotoStore(tmp.path);
    catalog = CatalogRepository(db);
    projects = ProjectRepository(db);
    sampling = SamplingRepository(db, photos);
    reports = ReportRepository(db, photos);
    crop = (await catalog.watchCrops().first).single;
    scale = await catalog.defaultScale(crop.id);
    stages = await catalog.watchStages(scale.id).first;
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  Future<({String project, String season})> project(ProjectKind kind) async {
    final id = await projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: kind,
      name: 'Ensayo',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    return (project: id, season: (await projects.watchCurrentSeason(id).first)!.id);
  }

  Future<void> photo(String obs, PhotoKind kind, List<int> bytes) async {
    final src = File('${tmp.path}/src_${DateTime.now().microsecondsSinceEpoch}.jpg')..writeAsBytesSync(bytes);
    await sampling.addPhoto(observationId: obs, kind: kind, sourcePath: src.path, takenAt: DateTime(2026, 11, 10));
  }

  test('informe semanal: estado actual y anterior, notas y una foto de cada tipo', () async {
    final p = await project(ProjectKind.varietyTrial);
    final variety = await catalog.createVariety(cropId: crop.id, name: 'Heritage', code: 'HER');
    final heritage = await projects.createUnit(projectId: p.project, label: 'Heritage', varietyId: variety);
    await projects.createUnit(projectId: p.project, label: 'Tulameen');
    final flower = stages.firstWhere((s) => s.code.startsWith('6'));
    final fruit = stages.firstWhere((s) => s.code.startsWith('7'));

    final prev = await sampling.ensureObservation(p.season, heritage, 9);
    await sampling.setStage(prev, flower.id);
    final obs = await sampling.ensureObservation(p.season, heritage, 10);
    await sampling.setStage(obs, fruit.id);
    await sampling.setNotes(obs, '  Cuaja pareja  ');
    await photo(obs, PhotoKind.general, [1]);
    await photo(obs, PhotoKind.general, [2]);
    await photo(obs, PhotoKind.detail, [3]);

    final r = await reports.weekly(projectId: p.project, seasonId: p.season, week: 10, shrink: shrink);
    expect(r.week, 10);
    expect(r.weekStart, DateTime.utc(2026, 11, 9));
    expect(r.header.seasonName, '2026-27');
    expect(r.header.unitCount, 2);
    expect(r.rows.map((x) => x.label), ['Heritage', 'Tulameen']);
    final h = r.rows.first;
    expect(h.stage!.code, fruit.code);
    expect(h.previous!.code, flower.code);
    expect(h.stage!.macroName, 'Desarrollo del fruto', reason: 'macroestadio para «Estadio principal»');
    expect(h.code, 'HER');
    expect(h.notes, 'Cuaja pareja');
    expect(h.photoCount, 3);
    expect(h.general.map((b) => b.first), [1], reason: 'una foto general por defecto');
    expect(h.detail.map((b) => b.first), [3]);
    expect(r.complete, 1);
    expect(r.rows.last.stage, isNull);

    final two = await reports.weekly(
      projectId: p.project,
      seasonId: p.season,
      week: 10,
      shrink: shrink,
      maxPhotosPerKind: 2,
    );
    expect(two.rows.first.general, hasLength(2));
    final none = await reports.weekly(
      projectId: p.project,
      seasonId: p.season,
      week: 10,
      shrink: shrink,
      includePhotos: false,
    );
    expect(none.rows.first.general, isEmpty);
    expect(none.rows.first.photoCount, 3, reason: 'la tabla sigue contando las fotos');
  });

  test('matriz: agrupa por tratamiento, con su descripción y semanas no muestreadas', () async {
    final p = await project(ProjectKind.treatmentTrial);
    await projects.configureTreatmentTrial(p.project, treatments: 1, replicates: 2, hasControl: true);
    final ts = await projects.watchTreatments(p.project).first;
    await projects.setTreatmentDescription(ts[1].id, '40 kg N/ha');
    final units = await projects.watchUnits(p.project).first; // T0 R1, T1 R1, T0 R2, T1 R2
    final flower = stages.firstWhere((s) => s.code.startsWith('6'));
    final o = await sampling.ensureObservation(p.season, units[1].id, 5);
    await sampling.setStage(o, flower.id);
    await sampling.setWeekNotSampled(p.season, 2, true);

    final m = await reports.matrix(projectId: p.project, seasonId: p.season, currentWeek: 3);
    expect(m.weeks, [1, 2, 3, 4, 5], reason: 'hasta la última semana con datos');
    expect(m.notSampledWeeks, {2});
    expect(m.rows.map((r) => r.label), ['T0 R1', 'T0 R2', 'T1 R1', 'T1 R2']);
    expect(m.rows.map((r) => r.group), ['T0', 'T0', 'T1', 'T1']);
    expect(m.rows[2].subtitle, '40 kg N/ha');
    expect(m.rows[2].stages[5]!.code, flower.code);
    expect(m.header.details.first, contains('incluye testigo T0'));
    expect(m.header.details, contains('T1: 40 kg N/ha'));
    expect(m.legend.single.code, flower.code);
  });
}
