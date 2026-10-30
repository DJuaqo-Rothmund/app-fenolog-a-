import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/measurement.dart';
import '../domain/season_weeks.dart';
import '../domain/stats.dart';
import 'database.dart';
import 'season_analysis.dart';
import 'season_data.dart';

/// Colores de series distinguibles también por personas daltónicas
/// (paleta Okabe-Ito, sin el amarillo que no se lee sobre blanco).
const seriesColors = [0xFF0072B2, 0xFFE69F00, 0xFF009E73, 0xFFD55E00, 0xFFCC79A7, 0xFF56B4E9, 0xFF000000];

/// Fuentes de los informes (con tildes y eñes).
class ReportFonts {
  const ReportFonts(this.regular, this.bold);
  final ByteData regular;
  final ByteData bold;

  pw.ThemeData get theme => pw.ThemeData.withFont(base: pw.Font.ttf(regular), bold: pw.Font.ttf(bold));
}

final _date = DateFormat('d-MM-yyyy', 'es');
final _now = DateFormat("d-MM-yyyy 'a las' HH:mm", 'es');

/// Informes PDF de una temporada.
class PdfReports {
  PdfReports(this.fonts, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;
  final ReportFonts fonts;
  final DateTime Function() _clock;

  pw.Document _doc() => pw.Document(theme: fonts.theme, creator: 'FramBitácora');

  pw.Widget _header(SeasonData d, String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text('${d.project.name} · ${d.crop.name} · Temporada ${d.season.name}'),
      pw.SizedBox(height: 8),
    ],
  );

  pw.Widget _footer(pw.Context c) => pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      'FramBitácora · generado el ${_now.format(_clock())} · página ${c.pageNumber} de ${c.pagesCount}',
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
    ),
  );

  pw.MultiPage _page(List<pw.Widget> Function(pw.Context) build, {bool landscape = false}) => pw.MultiPage(
    pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    footer: _footer,
    build: build,
  );

  static pw.Widget _table(List<String> headers, List<List<String>> rows, {Map<int, pw.TableColumnWidth>? widths}) =>
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellAlignment: pw.Alignment.centerLeft,
        columnWidths: widths,
      );

  static pw.Widget _section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
  );

  /// Círculo de color con el código del estadio.
  pw.Widget _stageCell(PhenoStage? s, {String? fallback}) {
    if (s == null) return pw.Center(child: pw.Text(fallback ?? '', style: const pw.TextStyle(fontSize: 8)));
    final color = PdfColor.fromInt(s.color);
    final dark = color.luminance < 0.45;
    return pw.Container(
      alignment: pw.Alignment.center,
      color: color,
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(s.code, style: pw.TextStyle(fontSize: 8, color: dark ? PdfColors.white : PdfColors.black)),
    );
  }

  /// Matriz unidad × semana con el estadio coloreado.
  pw.Widget _matrix(SeasonData d) {
    final weeks = d.weeks;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {0: const pw.FixedColumnWidth(90)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Text('Unidad', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
            for (final w in weeks)
              pw.Center(
                child: pw.Text('S$w', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
          ],
        ),
        for (final u in d.units)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text(u.label, style: const pw.TextStyle(fontSize: 8)),
              ),
              for (final w in weeks)
                _stageCell(d.record(u.id, w)?.stage, fallback: d.notSampledWeeks.contains(w) ? 'NM' : null),
            ],
          ),
      ],
    );
  }

  /// Curva fenológica: semana en X, estadio en Y.
  pw.Widget _curveChart(SeasonData d, GroupBy by) {
    final curves = d.curves(by);
    final weeks = d.weeks;
    if (curves.isEmpty || weeks.isEmpty || d.stages.isEmpty) return pw.Text('Aún no hay estadios registrados.');
    final used = {
      for (final c in curves)
        for (final p in c.points) p.stageIndex.round(),
    };
    final minI = used.reduce((a, b) => a < b ? a : b);
    final maxI = used.reduce((a, b) => a > b ? a : b);
    final yTicks = <int>[for (var i = minI; i <= maxI; i++) i];
    // Con muchas marcas el eje se vuelve ilegible: se muestra una de cada n.
    final step = (yTicks.length / 12).ceil().clamp(1, 100);
    final xFrom = weeks.first, xTo = weeks.last == weeks.first ? weeks.first + 1 : weeks.last;
    return pw.SizedBox(
      height: 260,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(
            [for (var w = xFrom; w <= xTo; w++) w],
            format: (v) => 'S$v',
            textStyle: const pw.TextStyle(fontSize: 7),
          ),
          yAxis: pw.FixedAxis(
            [for (var i = 0; i < yTicks.length; i += step) yTicks[i]],
            format: (v) => d.stages[v.toInt()].code,
            textStyle: const pw.TextStyle(fontSize: 7),
            divisions: true,
          ),
        ),
        datasets: [
          for (final (i, c) in curves.indexed)
            pw.LineDataSet(
              legend: c.name,
              color: PdfColor.fromInt(seriesColors[i % seriesColors.length]),
              pointSize: 2,
              lineWidth: 1.5,
              data: [for (final p in c.points) pw.PointChartValue(p.week.toDouble(), p.stageIndex)],
            ),
        ],
        right: curves.length > 1 ? pw.ChartLegend(textStyle: const pw.TextStyle(fontSize: 8)) : null,
      ),
    );
  }

  /// Informe de una semana: estado de cada unidad, notas, mediciones y
  /// (si [withPhotos]) la primera foto de detalle o general.
  Future<Uint8List> weekly(SeasonData d, int week, {bool withPhotos = true}) async {
    final doc = _doc();
    final start = d.weekStart(week);
    final defs = d.observationDefs;
    final rows = [for (final u in d.units) (unit: u, record: d.record(u.id, week))];
    final complete = rows.where((r) => r.record?.isComplete ?? false).length;

    final photos = <String, pw.ImageProvider>{};
    if (withPhotos) {
      for (final r in rows) {
        final record = r.record;
        if (record == null || record.photos.isEmpty) continue;
        final photo = record.photos.firstWhere((p) => p.kind == 'detail', orElse: () => record.photos.first);
        final f = File(photo.localPath);
        if (f.existsSync()) photos[r.unit.id] = pw.MemoryImage(await f.readAsBytes());
      }
    }

    doc.addPage(
      _page(
        (c) => [
          _header(d, 'Informe semanal · Semana $week'),
          pw.Text(
            'Desde el ${_date.format(start)} (semana ${isoWeek(start).week} del año). '
            '${d.notSampledWeeks.contains(week) ? 'Semana marcada como NO muestreada. ' : ''}'
            'Registros completos: $complete de ${rows.length}.',
          ),
          _section('Estado por unidad'),
          _table(
            [
              'Unidad',
              'Estadio',
              'Fotos',
              for (final m in defs) m.unit.isEmpty ? m.name : '${m.name} (${m.unit})',
              'Notas',
            ],
            [
              for (final r in rows)
                [
                  r.unit.label,
                  r.record?.stage == null ? '—' : '${r.record!.stage!.code} · ${r.record!.stage!.name}',
                  '${r.record?.photos.length ?? 0}',
                  for (final m in defs) SeasonData.valueText(r.record?.values[m.id]),
                  r.record?.observation.notes ?? '',
                ],
            ],
          ),
          if (photos.isNotEmpty) ...[
            _section('Fotos'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in rows)
                  if (photos[r.unit.id] case final img?)
                    pw.SizedBox(
                      width: 160,
                      child: pw.Column(
                        children: [
                          pw.Image(img, height: 120, fit: pw.BoxFit.cover),
                          pw.Text(
                            '${r.unit.label} · ${r.record?.stage?.code ?? ''}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }

  /// Informe de la temporada: curva, matriz, promedios de mediciones y
  /// parámetros por variedad.
  Future<Uint8List> season(SeasonData d, {required GroupBy groupBy}) async {
    final doc = _doc();
    final numeric = d.numericObservationDefs;
    final weeks = d.weeks;
    doc.addPage(
      _page(
        landscape: true,
        (c) => [
          _header(d, 'Informe de temporada'),
          pw.Text(
            'Semana 1 desde el ${_date.format(d.season.week1Start)}. Unidades: ${d.units.length}. '
            'Registros: ${d.records.length} (${d.records.where((r) => r.isComplete).length} completos). '
            'Semanas no muestreadas: ${d.notSampledWeeks.isEmpty ? 'ninguna' : (d.notSampledWeeks.toList()..sort()).join(', ')}.',
          ),
          _section('Curva fenológica (${groupBy.label.toLowerCase()})'),
          _curveChart(d, groupBy),
          _section('Matriz de estadios'),
          _matrix(d),
          for (final m in numeric) ...[
            _section('${m.name}${m.unit.isEmpty ? '' : ' (${m.unit})'}: promedio por semana'),
            _measurementByWeek(d, m, weeks, groupBy),
          ],
          if (d.varietyDefs.isNotEmpty && d.usedVarieties.isNotEmpty) ...[
            _section('Parámetros por variedad'),
            _table(
              ['Variedad', for (final m in d.varietyDefs) m.unit.isEmpty ? m.name : '${m.name} (${m.unit})'],
              [
                for (final v in d.usedVarieties)
                  [v.name, for (final m in d.varietyDefs) SeasonData.valueText(d.varietyValue(v.id, m.id))],
              ],
            ),
          ],
          _section('Escala'),
          pw.Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final s in d.stages.where((s) => d.records.any((r) => r.stage?.id == s.id)))
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.SizedBox(width: 22, child: _stageCell(s)),
                    pw.SizedBox(width: 4),
                    pw.Text(s.name, style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _measurementByWeek(SeasonData d, MeasurementDef m, List<int> weeks, GroupBy by) {
    final groups = <String>{for (final u in d.units) d.groupOf(u, by)}.toList();
    String cell(String g, int w) {
      final values = [
        for (final r in d.records)
          if (r.week == w && d.groupOf(r.unit, by) == g && r.values[m.id]?.valueNum != null) r.values[m.id]!.valueNum!,
      ];
      return values.isEmpty
          ? ''
          : formatNumber(double.parse((values.reduce((a, b) => a + b) / values.length).toStringAsFixed(2)));
    }

    return _table(
      ['Grupo', for (final w in weeks) 'S$w'],
      [
        for (final g in groups) [g, for (final w in weeks) cell(g, w)],
      ],
    );
  }

  /// Ficha de una variedad: estadio de cada unidad por semana, semana en que
  /// alcanzó cada macroestadio y parámetros.
  Future<Uint8List> varietySheet(SeasonData d, Variety v) async {
    final doc = _doc();
    final units = d.units.where((u) => u.varietyId == v.id).toList();
    final macros = <String, PhenoStage>{};
    for (final s in d.stages) {
      macros.putIfAbsent(s.macroCode, () => s);
    }
    doc.addPage(
      _page(
        (c) => [
          _header(d, 'Ficha de variedad · ${v.name}'),
          if (v.code.isNotEmpty || v.notes.isNotEmpty)
            pw.Text([if (v.code.isNotEmpty) 'Código ${v.code}', v.notes].where((s) => s.isNotEmpty).join(' · ')),
          _section('Inicio de cada fase'),
          _table(
            ['Fase (primer estadio)', for (final u in units) u.label],
            [
              for (final s in macros.values)
                [
                  '${s.macroCode} · ${s.code} ${s.name}',
                  for (final u in units)
                    if (d.weekReached(u, s) case final w?) 'S$w (${_date.format(d.weekStart(w))})' else '',
                ],
            ],
          ),
          _section('Registro semanal'),
          _table(
            ['Semana', for (final u in units) u.label],
            [
              for (final w in d.weeks)
                [
                  'S$w · ${_date.format(d.weekStart(w))}',
                  for (final u in units) d.record(u.id, w)?.stage?.code ?? (d.notSampledWeeks.contains(w) ? 'NM' : ''),
                ],
            ],
          ),
          if (d.varietyDefs.isNotEmpty) ...[
            _section('Parámetros de la temporada'),
            _table(
              ['Parámetro', 'Valor'],
              [
                for (final m in d.varietyDefs)
                  [m.unit.isEmpty ? m.name : '${m.name} (${m.unit})', SeasonData.valueText(d.varietyValue(v.id, m.id))],
              ],
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }

  /// Resultado de una comparación estadística.
  Future<Uint8List> comparison(SeasonData d, {required String title, required ComparisonResult result}) async {
    final doc = _doc();
    String n(double? x, [int dec = 3]) =>
        x == null || x.isNaN ? '—' : formatNumber(double.parse(x.toStringAsFixed(dec)));
    String p(double? x) => x == null ? '—' : (x < 0.0001 ? '< 0,0001' : n(x, 4));
    doc.addPage(
      _page(
        (c) => [
          _header(d, 'Comparación · $title'),
          pw.Text(
            '${result.blocked ? 'ANOVA en bloques completos al azar (repeticiones como bloques)' : 'ANOVA de una vía'}. '
            'Comparación de medias con LSD de Fisher, α = ${n(result.alpha, 2)}. '
            'CV = ${n(result.cv, 1)} %.',
          ),
          _section('Análisis de varianza'),
          _table(
            ['Fuente', 'GL', 'SC', 'CM', 'F', 'p'],
            [
              for (final r in result.table)
                [r.source, '${r.df}', n(r.ss), r.source == 'Total' ? '' : n(r.ms), n(r.f, 2), p(r.p)],
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            result.significant
                ? 'Hay diferencias significativas entre grupos (p < ${n(result.alpha, 2)}).'
                : 'No hay diferencias significativas entre grupos (p ≥ ${n(result.alpha, 2)}).',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          _section('Medias'),
          _table(
            ['Grupo', 'n', 'Media', 'Desv. estándar', 'Grupo LSD'],
            [
              for (final m in result.means) [m.group, '${m.n}', n(m.mean, 2), n(m.sd, 2), m.letters],
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${result.lsd == null ? 'Grupos con distinto número de datos: LSD calculada para cada par. ' : 'LSD = ${n(result.lsd, 3)}. '}'
            'Medias con una letra en común no difieren significativamente.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
