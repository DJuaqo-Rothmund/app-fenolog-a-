import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/measurement_repository.dart';
import 'package:frambitacora/data/pdf_reports.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/data/season_analysis.dart';
import 'package:frambitacora/data/season_data.dart';
import 'package:frambitacora/domain/measurement.dart';
import 'package:frambitacora/domain/photo_naming.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/domain/stats.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late SeasonData data;
  late List<PhenoStage> stages;

  setUpAll(() => initializeDateFormatting('es'));

  /// Ensayo de tratamientos: T1 y T2 × 3 repeticiones, semanas 1 a 3.
  /// T2 va una semana adelantado.
  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('frambitacora_reports');
    final catalog = CatalogRepository(db);
    final projects = ProjectRepository(db);
    final sampling = SamplingRepository(db, PhotoStore(baseDir: () async => tmp));
    final measurements = MeasurementRepository(db);
    final crop = (await catalog.watchCrops().first).single;
    final scale = await catalog.defaultScale(crop.id);
    stages = await catalog.watchStages(scale.id).first;
    final projectId = await projects.createProject(
      cropId: crop.id,
      scaleId: scale.id,
      kind: ProjectKind.treatmentTrial,
      name: 'Ensayo bioestimulante',
      seasonName: '2026-27',
      week1Start: DateTime.utc(2026, 9, 7),
    );
    final seasonId = (await projects.watchCurrentSeason(projectId).first)!.id;
    final brote = await measurements.createDef(
      projectId: projectId,
      name: 'Largo de brote',
      kind: MeasurementKind.number,
      scope: MeasurementScope.observation,
      unit: 'cm',
    );
    final codes = {
      'T1': ['00', '07', '10'],
      'T2': ['07', '10', '31'],
    };
    final src = File('${tmp.path}/src.jpg')..writeAsBytesSync(_tinyJpeg);
    for (final t in ['T1', 'T2']) {
      for (final rep in [1, 2, 3]) {
        final unit = await projects.createUnit(projectId: projectId, label: '$t R$rep', treatment: t, replicate: rep);
        for (final week in [1, 2, 3]) {
          final obs = await sampling.ensureObservation(seasonId, unit, week);
          await sampling.setStage(obs, stages.firstWhere((s) => s.code == codes[t]![week - 1]).id);
          final value = (t == 'T1' ? 10.0 : 14.0) + rep + week + rep * (t == 'T1' ? 0.3 : 0.1);
          await measurements.setObservationValue(obs, brote, (number: value, text: null));
          if (week == 3) {
            await sampling.addPhoto(observationId: obs, kind: PhotoKind.detail, sourcePath: src.path);
          }
        }
      }
    }
    data = await loadSeasonData(db, seasonId);
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('curvas por tratamiento promedian el índice de estadio', () {
    final curves = data.curves(GroupBy.treatment);
    expect(curves.map((c) => c.name), ['T1', 'T2']);
    double i(String code) => stages.indexWhere((s) => s.code == code).toDouble();
    expect(curves.first.points.map((p) => p.stageIndex), [i('00'), i('07'), i('10')]);
    expect(curves.last.points.first.week, 1);
  });

  test('semana en que se alcanza un estadio y su comparación', () {
    final s10 = stages.firstWhere((s) => s.code == '10');
    final t1 = data.units.firstWhere((u) => u.label == 'T1 R1');
    final t2 = data.units.firstWhere((u) => u.label == 'T2 R1');
    expect(data.weekReached(t1, s10), 3);
    expect(data.weekReached(t2, s10), 2);

    final samples = data.weekReachedSamples(s10, GroupBy.treatment);
    expect(samples, hasLength(6));
    expect(samples.first.block, 'R1', reason: 'las repeticiones son bloques');
  });

  test('comparar una medición en bloques', () {
    final def = data.numericObservationDefs.single;
    final r = compareGroups(data.measurementSamples(def, 2, GroupBy.treatment));
    expect(r.blocked, isTrue);
    expect(r.means.first.group, 'T2');
    expect(r.means.first.mean, closeTo(18.2, 1e-9));
    expect(r.significant, isTrue);
  });

  group('PDF', () {
    late PdfReports reports;
    setUp(() {
      ByteData font(String name) => ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync());
      reports = PdfReports(ReportFonts(font('Roboto-Regular.ttf'), font('Roboto-Bold.ttf')));
    });

    void expectPdf(Uint8List bytes) {
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(2000));
    }

    test('semanal con fotos', () async => expectPdf(await reports.weekly(data, 3)));
    test('temporada', () async => expectPdf(await reports.season(data, groupBy: GroupBy.treatment)));
    test('comparación', () async {
      final def = data.numericObservationDefs.single;
      final r = compareGroups(data.measurementSamples(def, 2, GroupBy.treatment));
      expectPdf(await reports.comparison(data, title: 'Largo de brote, semana 2', result: r));
    });
    test('ficha de variedad sin unidades no falla', () async {
      final v = Variety(
        id: 'v',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        cropId: data.crop.id,
        name: 'Heritage',
        code: '',
        notes: '',
        archived: false,
      );
      expectPdf(await reports.varietySheet(data, v));
    });
  });
}

/// JPEG válido de 1×1 píxel.
const _tinyJpeg = [
  0xFF,
  0xD8,
  0xFF,
  0xE0,
  0x00,
  0x10,
  0x4A,
  0x46,
  0x49,
  0x46,
  0x00,
  0x01,
  0x01,
  0x00,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0x00,
  0xFF,
  0xDB,
  0x00,
  0x43,
  0x00,
  0x08,
  0x06,
  0x06,
  0x07,
  0x06,
  0x05,
  0x08,
  0x07,
  0x07,
  0x07,
  0x09,
  0x09,
  0x08,
  0x0A,
  0x0C,
  0x14,
  0x0D,
  0x0C,
  0x0B,
  0x0B,
  0x0C,
  0x19,
  0x12,
  0x13,
  0x0F,
  0x14,
  0x1D,
  0x1A,
  0x1F,
  0x1E,
  0x1D,
  0x1A,
  0x1C,
  0x1C,
  0x20,
  0x24,
  0x2E,
  0x27,
  0x20,
  0x22,
  0x2C,
  0x23,
  0x1C,
  0x1C,
  0x28,
  0x37,
  0x29,
  0x2C,
  0x30,
  0x31,
  0x34,
  0x34,
  0x34,
  0x1F,
  0x27,
  0x39,
  0x3D,
  0x38,
  0x32,
  0x3C,
  0x2E,
  0x33,
  0x34,
  0x32,
  0xFF,
  0xC0,
  0x00,
  0x0B,
  0x08,
  0x00,
  0x01,
  0x00,
  0x01,
  0x01,
  0x01,
  0x11,
  0x00,
  0xFF,
  0xC4,
  0x00,
  0x14,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x09,
  0xFF,
  0xC4,
  0x00,
  0x14,
  0x10,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0xFF,
  0xDA,
  0x00,
  0x08,
  0x01,
  0x01,
  0x00,
  0x00,
  0x3F,
  0x00,
  0x2A,
  0x9F,
  0xFF,
  0xD9,
];
