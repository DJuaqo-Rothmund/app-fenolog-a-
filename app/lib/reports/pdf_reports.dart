import 'dart:isolate';
import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_models.dart';

/// Recursos que necesita el PDF: fuentes (con tildes y ñ) y el logo.
class ReportAssets {
  const ReportAssets({required this.regular, required this.bold, required this.logoSvg});
  final ByteData regular;
  final ByteData bold;
  final String logoSvg;
}

// Colores de la marca.
const _leaf = PdfColor.fromInt(0xFF2F6B3A);
const _leafPale = PdfColor.fromInt(0xFFE6F2E2);
const _cream = PdfColor.fromInt(0xFFFFF8EC);
const _berry = PdfColor.fromInt(0xFFC2185B);
const _grey = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFD9E3D5);

/// Arma el informe semanal en otro isolate (no traba la pantalla).
Future<Uint8List> buildWeeklyPdfInIsolate(WeeklyReport report, ReportAssets assets) =>
    Isolate.run(() => buildWeeklyPdf(report, assets));

/// Arma la matriz de la temporada en otro isolate.
Future<Uint8List> buildMatrixPdfInIsolate(MatrixReport report, ReportAssets assets) =>
    Isolate.run(() => buildMatrixPdf(report, assets));

Future<pw.ThemeData> _theme(ReportAssets a) async {
  return pw.ThemeData.withFont(base: pw.Font.ttf(a.regular), bold: pw.Font.ttf(a.bold));
}

String _fmt(DateTime d, String pattern) => DateFormat(pattern, 'es').format(d);

PdfColor _stageColor(ReportStage s) => PdfColor.fromInt(s.color);

/// Texto blanco o negro según lo claro del color del estadio.
PdfColor _onStage(ReportStage s) {
  final c = PdfColor.fromInt(s.color);
  final lum = 0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue;
  return lum > 0.55 ? PdfColors.black : PdfColors.white;
}

/// Círculo con el color y el código del estadio.
pw.Widget _badge(ReportStage? s, {double size = 22}) {
  if (s == null) {
    return pw.Container(
      width: size,
      height: size,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: _grey, width: 0.8),
      ),
      child: pw.Text(
        '–',
        style: pw.TextStyle(color: _grey, fontSize: size * 0.4),
      ),
    );
  }
  return pw.Container(
    width: size,
    height: size,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: _stageColor(s)),
    child: pw.Text(
      s.code,
      style: pw.TextStyle(color: _onStage(s), fontSize: size * 0.36, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _stageCell(ReportStage? s) => pw.Row(
  children: [
    _badge(s),
    pw.SizedBox(width: 6),
    pw.Expanded(
      child: pw.Text(s?.name ?? 'Sin registro', style: pw.TextStyle(fontSize: 8.5, color: s == null ? _grey : null)),
    ),
  ],
);

/// Encabezado común: logo, título, ensayo y temporada.
pw.Widget _title(ReportAssets a, ReportHeader h, String title, String right, String rightSub) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.center,
  children: [
    pw.SizedBox(width: 44, height: 44, child: pw.SvgImage(svg: a.logoSvg)),
    pw.SizedBox(width: 12),
    pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 9, color: _leaf, letterSpacing: 1.2)),
          pw.Text(h.projectName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          right,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _leaf),
        ),
        pw.Text(rightSub, style: const pw.TextStyle(fontSize: 9, color: _grey)),
      ],
    ),
  ],
);

/// Franja con la información general del ensayo.
pw.Widget _info(ReportHeader h, List<String> extra) {
  final main = [
    'Temporada ${h.seasonName}',
    h.kindLabel,
    h.cropName,
    '${h.unitCount} ${h.unitCount == 1 ? 'unidad' : 'unidades'}',
    ...extra,
  ];
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: const pw.BoxDecoration(color: _leafPale, borderRadius: pw.BorderRadius.all(pw.Radius.circular(8))),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(main.join('   ·   '), style: const pw.TextStyle(fontSize: 9.5)),
        for (final d in h.details) pw.Text(d, style: const pw.TextStyle(fontSize: 8.5, color: _grey)),
      ],
    ),
  );
}

/// Pie de página: solo el número de página, centrado.
pw.Widget _footer(pw.Context ctx) => pw.Container(
  margin: const pw.EdgeInsets.only(top: 8),
  alignment: pw.Alignment.center,
  child: pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: _grey)),
);

pw.Widget _section(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _leaf),
  ),
);

// ---------------------------------------------------------------------------
// Informe semanal

Future<Uint8List> buildWeeklyPdf(WeeklyReport r, ReportAssets a) async {
  // Nombres de meses en español (también hace falta dentro del isolate).
  await initializeDateFormatting('es');
  final doc = pw.Document(
    title: 'Informe semanal · ${r.header.projectName} · Semana ${r.week}',
    creator: 'FramBitácora',
  );
  final end = r.weekStart.add(const Duration(days: 6));
  final range = '${_fmt(r.weekStart, "d 'de' MMM")} al ${_fmt(end, "d 'de' MMM 'de' y")}';
  final withPhotos = r.rows.where((x) => x.general.isNotEmpty || x.detail.isNotEmpty).toList();

  doc.addPage(
    pw.MultiPage(
      theme: await _theme(a),
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 28),
      footer: _footer,
      build: (ctx) => [
        _title(a, r.header, 'Informe semanal', 'Semana ${r.week}', '$range · semana ${r.isoWeek} del año'),
        pw.SizedBox(height: 12),
        _info(r.header, ['Avance: ${r.complete} de ${r.rows.length} registros completos']),
        if (r.notSampled)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            padding: const pw.EdgeInsets.all(8),
            color: _cream,
            child: pw.Text(
              'Semana marcada como no muestreada.',
              style: pw.TextStyle(color: _berry, fontWeight: pw.FontWeight.bold),
            ),
          ),
        _section('Avance fenológico'),
        pw.Table(
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line, width: 0.6)),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.2),
            1: pw.FlexColumnWidth(2.4),
            2: pw.FlexColumnWidth(2.4),
            3: pw.FixedColumnWidth(36),
            4: pw.FlexColumnWidth(2.6),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _leafPale),
              children: [
                for (final h in ['Unidad', 'Semana anterior', 'Esta semana', 'Fotos', 'Notas'])
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: pw.Text(h, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  ),
              ],
            ),
            for (final u in r.rows)
              pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(u.label, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                        if (u.subtitle.isNotEmpty)
                          pw.Text(u.subtitle, style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
                      ],
                    ),
                  ),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: _stageCell(u.previous)),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: _stageCell(u.stage)),
                  pw.Center(child: pw.Text('${u.photoCount}', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(u.notes, style: const pw.TextStyle(fontSize: 8)),
                  ),
                ],
              ),
          ],
        ),
        if (withPhotos.isNotEmpty) _section('Fotos de la semana'),
        for (final u in withPhotos) _unitPhotos(u),
      ],
    ),
  );
  return doc.save();
}

/// Bloque de una unidad: estado, notas y sus fotos general y de detalle lado a lado.
pw.Widget _unitPhotos(WeeklyUnitRow u) {
  final photos = [for (final p in u.general) ('General', p), for (final p in u.detail) ('Detalle', p)];
  // Un Stack no se puede partir entre páginas: cada unidad queda entera en una hoja.
  return pw.Stack(children: [_unitBlock(u, photos)]);
}

pw.Widget _unitBlock(WeeklyUnitRow u, List<(String, Uint8List)> photos) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.8),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            _badge(u.stage, size: 26),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    u.subtitle.isEmpty ? u.label : '${u.label} · ${u.subtitle}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(u.stage?.name ?? 'Sin estado', style: const pw.TextStyle(fontSize: 8.5, color: _grey)),
                ],
              ),
            ),
          ],
        ),
        if (u.notes.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(u.notes, style: const pw.TextStyle(fontSize: 8.5)),
          ),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final (i, (caption, bytes)) in photos.indexed) ...[
              if (i > 0) pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.ClipRRect(
                      horizontalRadius: 6,
                      verticalRadius: 6,
                      child: pw.Image(
                        pw.MemoryImage(bytes),
                        height: photos.length > 2 ? 140 : 190,
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(caption, style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Matriz de la temporada

/// Semanas por página en la matriz (hoja Carta horizontal).
const matrixWeeksPerPage = 22;

Future<Uint8List> buildMatrixPdf(MatrixReport r, ReportAssets a) async {
  await initializeDateFormatting('es');
  final doc = pw.Document(title: 'Matriz fenológica · ${r.header.projectName}', creator: 'FramBitácora');
  final theme = await _theme(a);
  final chunks = chunkWeeks(r.weeks, matrixWeeksPerPage);
  final legend = r.legend;

  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.letter.landscape,
      margin: const pw.EdgeInsets.fromLTRB(30, 28, 30, 24),
      footer: _footer,
      build: (ctx) => [
        _title(
          a,
          r.header,
          'Matriz fenológica de la temporada',
          'Semanas ${r.weeks.first}–${r.weeks.last}',
          '${_fmt(r.weekStarts[r.weeks.first]!, "d 'de' MMM")} al '
              '${_fmt(r.weekStarts[r.weeks.last]!.add(const Duration(days: 6)), "d 'de' MMM 'de' y")}',
        ),
        pw.SizedBox(height: 10),
        _info(r.header, const []),
        for (final (i, weeks) in chunks.indexed) ...[
          if (chunks.length > 1) _section('Semanas ${weeks.first} a ${weeks.last}') else pw.SizedBox(height: 12),
          _matrixTable(r, weeks),
          if (i < chunks.length - 1) pw.SizedBox(height: 6),
        ],
        if (legend.isNotEmpty) ...[
          _section('Estados fenológicos'),
          pw.Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final s in legend)
                pw.SizedBox(
                  width: 170,
                  child: pw.Row(
                    children: [
                      _badge(s, size: 18),
                      pw.SizedBox(width: 5),
                      pw.Expanded(child: pw.Text(s.name, style: const pw.TextStyle(fontSize: 8))),
                    ],
                  ),
                ),
            ],
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'NM = semana no muestreada.  Celda vacía = sin registro.',
          style: const pw.TextStyle(fontSize: 7.5, color: _grey),
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _matrixTable(MatrixReport r, List<int> weeks) {
  const cell = 26.0;
  final headerStyle = pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold);
  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _leafPale),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text('Unidad', style: headerStyle),
        ),
        for (final w in weeks)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Column(
              children: [
                pw.Text('S$w', style: headerStyle),
                pw.Text(_fmt(r.weekStarts[w]!, 'd/M'), style: const pw.TextStyle(fontSize: 6, color: _grey)),
              ],
            ),
          ),
      ],
    ),
  ];
  String? lastGroup;
  for (final row in r.rows) {
    if (row.group != null && row.group != lastGroup) {
      lastGroup = row.group;
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _cream),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: pw.Text(
                row.subtitle.isEmpty ? row.group! : '${row.group} · ${row.subtitle}',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _leaf),
              ),
            ),
            for (final _ in weeks) pw.SizedBox(),
          ],
        ),
      );
    }
    rows.add(
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(row.label, style: const pw.TextStyle(fontSize: 8)),
                if (row.subtitle.isNotEmpty && row.group == null)
                  pw.Text(row.subtitle, style: const pw.TextStyle(fontSize: 6.5, color: _grey)),
              ],
            ),
          ),
          for (final w in weeks) _matrixCell(row.stages[w], notSampled: r.notSampledWeeks.contains(w), size: cell),
        ],
      ),
    );
  }
  return pw.Table(
    tableWidth: pw.TableWidth.min,
    border: pw.TableBorder.all(color: _line, width: 0.5),
    columnWidths: {
      0: const pw.FixedColumnWidth(130),
      for (var i = 1; i <= weeks.length; i++) i: const pw.FixedColumnWidth(cell),
    },
    children: rows,
  );
}

pw.Widget _matrixCell(ReportStage? s, {required bool notSampled, required double size}) {
  if (s == null) {
    return pw.Container(
      height: 18,
      alignment: pw.Alignment.center,
      color: notSampled ? const PdfColor.fromInt(0xFFEDEDED) : null,
      child: notSampled ? pw.Text('NM', style: const pw.TextStyle(fontSize: 6, color: _grey)) : null,
    );
  }
  return pw.Container(
    height: 18,
    alignment: pw.Alignment.center,
    color: _stageColor(s),
    child: pw.Text(
      s.code,
      style: pw.TextStyle(fontSize: 7, color: _onStage(s), fontWeight: pw.FontWeight.bold),
    ),
  );
}
