import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/reports/pdf_reports.dart';
import 'package:frambitacora/reports/photo_shrink.dart';
import 'package:frambitacora/reports/report_models.dart';

/// Recursos del PDF leídos desde los archivos del proyecto.
ReportAssets testReportAssets() => ReportAssets(
  regular: ByteData.sublistView(File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync()),
  bold: ByteData.sublistView(File('assets/fonts/Roboto-Bold.ttf').readAsBytesSync()),
  logoSvg: File('assets/brand/symbol.svg').readAsStringSync(),
);

/// Foto JPEG de prueba de un solo color.
Uint8List testJpeg(int argb, {int w = 120, int h = 90}) {
  final rgba = Uint8List(w * h * 4);
  for (var i = 0; i < w * h; i++) {
    rgba[i * 4] = (argb >> 16) & 0xFF;
    rgba[i * 4 + 1] = (argb >> 8) & 0xFF;
    rgba[i * 4 + 2] = argb & 0xFF;
    rgba[i * 4 + 3] = 0xFF;
  }
  return encodeReportJpeg(rgba, w, h);
}

/// Cantidad de páginas de un PDF.
int pageCount(Uint8List pdf) => RegExp(r'/Type\s*/Page[^s]').allMatches(String.fromCharCodes(pdf)).length;

const _flower = ReportStage(code: '61', name: 'Inicio de floración', color: 0xFFF5F0DC, sortOrder: 30);
const _fruit = ReportStage(code: '71', name: 'Cuaja', color: 0xFF9DC183, sortOrder: 40);

final _header = ReportHeader(
  projectName: 'Ensayo nuevas variedades',
  kindLabel: 'Ensayo de variedades',
  cropName: 'Frambueso',
  seasonName: '2026-27',
  unitCount: 2,
  generatedAt: DateTime(2026, 11, 15, 9, 30),
);

void main() {
  test('matriz: semanas desde la 1 hasta la actual o la última con datos', () {
    expect(matrixWeeks(currentWeek: 4), [1, 2, 3, 4]);
    expect(matrixWeeks(currentWeek: 3, lastWeekWithData: 5), [1, 2, 3, 4, 5]);
    expect(matrixWeeks(currentWeek: 0), [1]);
    expect(chunkWeeks([1, 2, 3, 4, 5], 2), [
      [1, 2],
      [3, 4],
      [5],
    ]);
  });

  test('leyenda de la matriz: estados usados, en el orden de la escala', () {
    final m = MatrixReport(
      header: _header,
      weeks: const [1, 2],
      weekStarts: {1: DateTime(2026, 9, 7), 2: DateTime(2026, 9, 14)},
      rows: const [
        MatrixRow(label: 'A', stages: {1: _fruit, 2: _flower}),
        MatrixRow(label: 'B', stages: {2: _fruit}),
      ],
    );
    expect(m.legend.map((s) => s.code), ['61', '71']);
  });

  test('informe semanal: genera un PDF Carta con tabla y fotos', () async {
    final report = WeeklyReport(
      header: _header,
      week: 10,
      weekStart: DateTime(2026, 11, 9),
      isoWeek: 46,
      rows: [
        WeeklyUnitRow(
          label: 'Adelita',
          stage: _fruit,
          previous: _flower,
          photoCount: 2,
          notes: 'Primeros frutos cuajados en laterales bajos.',
          general: [testJpeg(0xFF5A8F4E)],
          detail: [testJpeg(0xFFC2185B)],
        ),
        const WeeklyUnitRow(label: 'Heritage'),
      ],
    );
    final pdf = await buildWeeklyPdf(report, testReportAssets());
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(pageCount(pdf), greaterThanOrEqualTo(1));
    expect(report.complete, 1);
  });

  test('matriz: muchas semanas se reparten en varias tablas', () async {
    final weeks = [for (var w = 1; w <= 30; w++) w];
    final report = MatrixReport(
      header: _header,
      weeks: weeks,
      weekStarts: {for (final w in weeks) w: DateTime(2026, 9, 7).add(Duration(days: 7 * (w - 1)))},
      notSampledWeeks: const {3},
      rows: [
        for (final g in ['T0', 'T1'])
          for (var r = 1; r <= 3; r++)
            MatrixRow(
              label: '$g R$r',
              group: g,
              subtitle: g == 'T0' ? 'Sin aplicación' : '40 kg N/ha',
              stages: {for (var w = 1; w <= 12; w++) w: w < 6 ? _flower : _fruit},
            ),
      ],
    );
    final pdf = await buildMatrixPdf(report, testReportAssets());
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(chunkWeeks(weeks, matrixWeeksPerPage), hasLength(2));
    final out = Platform.environment['REPORT_SAMPLE_DIR'];
    if (out != null) {
      File('$out/matriz.pdf').writeAsBytesSync(pdf);
      File('$out/semanal.pdf').writeAsBytesSync(
        await buildWeeklyPdf(
          WeeklyReport(
            header: _header,
            week: 10,
            weekStart: DateTime(2026, 11, 9),
            isoWeek: 46,
            rows: [
              WeeklyUnitRow(
                label: 'Adelita',
                stage: _fruit,
                previous: _flower,
                photoCount: 2,
                notes: 'Primeros frutos cuajados.',
                general: [testJpeg(0xFF5A8F4E, w: 400, h: 300)],
                detail: [testJpeg(0xFFC2185B, w: 400, h: 300)],
              ),
            ],
          ),
          testReportAssets(),
        ),
      );
    }
  });
}
