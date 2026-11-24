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

// Paleta sobria, tipo cuaderno de campo: tinta casi negra, arena y verde oliva.
const _ink = PdfColor.fromInt(0xFF22221E);
const _soft = PdfColor.fromInt(0xFF4A4A43);
const _grey = PdfColor.fromInt(0xFF7A7A70);
const _sand = PdfColor.fromInt(0xFFEDE6D8);
const _sandPale = PdfColor.fromInt(0xFFF6F2EA);
const _border = PdfColor.fromInt(0xFFE0D8C8);
const _olive = PdfColor.fromInt(0xFF5B6B2E);

/// Arma el informe semanal en otro isolate (no traba la pantalla).
Future<Uint8List> buildWeeklyPdfInIsolate(WeeklyReport report, ReportAssets assets) =>
    Isolate.run(() => buildWeeklyPdf(report, assets));

/// Arma la matriz de la temporada en otro isolate.
Future<Uint8List> buildMatrixPdfInIsolate(MatrixReport report, ReportAssets assets) =>
    Isolate.run(() => buildMatrixPdf(report, assets));

Future<pw.ThemeData> _theme(ReportAssets a) async =>
    pw.ThemeData.withFont(base: pw.Font.ttf(a.regular), bold: pw.Font.ttf(a.bold));

String _fmt(DateTime d, String pattern) => DateFormat(pattern, 'es').format(d);

/// Texto blanco o negro según lo claro del color del estadio.
PdfColor _onStage(ReportStage s) {
  final c = PdfColor.fromInt(s.color);
  final lum = 0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue;
  return lum > 0.55 ? _ink : PdfColors.white;
}

/// Punto con el color del estadio (con borde, para que se vean los colores claros).
pw.Widget _dot(ReportStage s, {double size = 7}) => pw.Container(
  width: size,
  height: size,
  decoration: pw.BoxDecoration(
    shape: pw.BoxShape.circle,
    color: PdfColor.fromInt(s.color),
    border: pw.Border.all(color: _grey, width: 0.3),
  ),
);

/// Estado en una celda de tabla: punto de color, código y nombre.
pw.Widget _stageText(ReportStage? s) {
  if (s == null) return pw.Text('Sin estado', style: const pw.TextStyle(fontSize: 8.5, color: _grey));
  return pw.Row(
    children: [
      _dot(s),
      pw.SizedBox(width: 5),
      pw.Expanded(
        child: pw.RichText(
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 8.5, color: _ink),
            children: [
              pw.TextSpan(
                text: '${s.code} ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: s.name),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Píldora arena con el estado asignado.
pw.Widget _pill(ReportStage? s) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  decoration: const pw.BoxDecoration(color: _sand, borderRadius: pw.BorderRadius.all(pw.Radius.circular(10))),
  child: s == null
      ? pw.Text('Sin estado registrado', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))
      : pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            _dot(s, size: 8),
            pw.SizedBox(width: 5),
            pw.Text(
              'BBCH ${s.code} · ${s.name}',
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _ink),
            ),
          ],
        ),
);

/// Encabezado de la primera página: título grande, línea de contexto, datos
/// breves y una raya negra.
pw.Widget _title(String title, String context, String stats, List<String> details) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(
      title,
      style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold, color: _ink),
    ),
    pw.SizedBox(height: 3),
    pw.Text(context, style: const pw.TextStyle(fontSize: 10.5, color: _soft)),
    pw.SizedBox(height: 2),
    pw.Text(stats, style: const pw.TextStyle(fontSize: 8.5, color: _grey)),
    if (details.isNotEmpty) pw.Text(details.first, style: const pw.TextStyle(fontSize: 8, color: _grey)),
    if (details.length > 1)
      pw.Text(details.skip(1).join('   ·   '), style: const pw.TextStyle(fontSize: 8, color: _grey)),
    pw.SizedBox(height: 8),
    pw.Container(height: 1.2, color: _ink),
  ],
);

/// Desde la segunda página: el título en pequeño con una línea fina.
pw.Widget Function(pw.Context) _runningHeader(String title) => (ctx) {
  if (ctx.pageNumber == 1) return pw.SizedBox();
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.only(bottom: 4),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.8)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _grey),
    ),
  );
};

/// Pie de página: solo el número de página.
pw.Widget _footer(pw.Context ctx) => pw.Container(
  margin: const pw.EdgeInsets.only(top: 10),
  padding: const pw.EdgeInsets.only(top: 4),
  alignment: pw.Alignment.centerRight,
  decoration: const pw.BoxDecoration(
    border: pw.Border(top: pw.BorderSide(color: _border, width: 0.8)),
  ),
  child: pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: _grey)),
);

/// Título de sección con una línea fina debajo.
pw.Widget _section(String text, {String? note}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.SizedBox(height: 16),
    pw.Text(
      text,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _ink),
    ),
    pw.SizedBox(height: 3),
    pw.Container(height: 0.8, color: _border),
    if (note != null) ...[pw.SizedBox(height: 6), pw.Text(note, style: const pw.TextStyle(fontSize: 9, color: _soft))],
    pw.SizedBox(height: 8),
  ],
);

pw.Widget _headCell(String text, {pw.Alignment align = pw.Alignment.centerLeft}) => pw.Container(
  alignment: align,
  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _soft),
  ),
);

// ---------------------------------------------------------------------------
// Informe semanal

Future<Uint8List> buildWeeklyPdf(WeeklyReport r, ReportAssets a) async {
  // Nombres de meses en español (también hace falta dentro del isolate).
  await initializeDateFormatting('es');
  final h = r.header;
  final title = 'Informe semanal · Semana ${r.week}';
  final doc = pw.Document(title: '$title · ${h.projectName}', creator: 'FramBitácora');
  final withStage = r.rows.where((x) => x.stage != null).length;
  final photos = r.rows.fold(0, (n, x) => n + x.photoCount);
  final unitWord = h.kindLabel == 'Ensayo de variedades' ? 'variedades' : 'unidades';

  doc.addPage(
    pw.MultiPage(
      theme: await _theme(a),
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.fromLTRB(40, 34, 40, 26),
      header: _runningHeader('$title · ${h.projectName}'),
      footer: _footer,
      build: (ctx) => [
        _title(
          title,
          '${h.kindLabel} · ${h.projectName} · Semana del ${_fmt(r.weekStart, "d 'de' MMMM")} · '
              'Semana ${r.isoWeek}, año ${r.weekStart.year}',
          'Temporada ${h.seasonName}  ·  $withStage/${r.rows.length} $unitWord con estado BBCH  ·  '
              '$photos ${photos == 1 ? 'foto' : 'fotos'}',
          h.details,
        ),
        if (r.notSampled)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const pw.BoxDecoration(color: _sand, borderRadius: pw.BorderRadius.all(pw.Radius.circular(10))),
            child: pw.Text('Semana marcada como no muestreada', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        _section('Avance fenológico'),
        _weeklyTable(r),
        _section(
          'Registro fotográfico por unidad',
          note: 'Foto general de canopia y foto de detalle, con el estado fenológico asignado.',
        ),
        for (final u in r.rows) _unitCard(u),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _weeklyTable(WeeklyReport r) => pw.Table(
  border: const pw.TableBorder(
    horizontalInside: pw.BorderSide(color: _border, width: 0.6),
    bottom: pw.BorderSide(color: _border, width: 0.6),
  ),
  columnWidths: const {
    0: pw.FlexColumnWidth(2.3),
    1: pw.FlexColumnWidth(2.6),
    2: pw.FlexColumnWidth(2.6),
    3: pw.FlexColumnWidth(2),
    4: pw.FixedColumnWidth(36),
  },
  children: [
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _sand),
      children: [
        _headCell('Unidad'),
        _headCell('Semana anterior'),
        _headCell('Esta semana'),
        _headCell('Estadio principal'),
        _headCell('Fotos', align: pw.Alignment.center),
      ],
    ),
    for (final u in r.rows)
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(u.label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                if (u.subtitle.isNotEmpty) pw.Text(u.subtitle, style: const pw.TextStyle(fontSize: 7, color: _grey)),
              ],
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: _stageText(u.previous)),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: _stageText(u.stage)),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              u.stage == null || u.stage!.macroName.isEmpty ? '—' : u.stage!.macroName,
              style: pw.TextStyle(fontSize: 8.5, color: u.stage == null ? _grey : _ink),
            ),
          ),
          pw.Center(child: pw.Text('${u.photoCount}', style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
  ],
);

/// Tarjeta de una unidad: nombre y código, fotos (general y detalle), estado y notas.
/// Va dentro de un Stack para que no se parta entre dos páginas.
pw.Widget _unitCard(WeeklyUnitRow u) {
  final photos = [for (final p in u.general) ('General', p), for (final p in u.detail) ('Detalle', p)];
  final changed = u.previous != null && u.stage != null && u.previous!.code != u.stage!.code;
  return pw.Stack(
    children: [
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.fromLTRB(13, 9, 13, 11),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _border, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: u.label,
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink),
                        ),
                        if (u.subtitle.isNotEmpty)
                          pw.TextSpan(
                            text: '   ${u.subtitle}',
                            style: const pw.TextStyle(fontSize: 8.5, color: _grey),
                          ),
                      ],
                    ),
                  ),
                ),
                if (u.code.isNotEmpty)
                  pw.Text(
                    u.code,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _olive),
                  ),
              ],
            ),
            pw.SizedBox(height: 6),
            if (photos.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                decoration: const pw.BoxDecoration(
                  color: _sand,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text('Sin fotos', style: const pw.TextStyle(fontSize: 8.5, color: _grey)),
              )
            else
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final (i, (caption, bytes)) in photos.indexed) ...[
                    if (i > 0) pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            decoration: const pw.BoxDecoration(
                              color: _sandPale,
                              borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 4,
                              verticalRadius: 4,
                              child: pw.Image(
                                pw.MemoryImage(bytes),
                                height: photos.length > 2 ? 135 : 185,
                                fit: pw.BoxFit.cover,
                              ),
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
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                _pill(u.stage),
                if (changed) ...[
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'Semana anterior: ${u.previous!.code} · ${u.previous!.name}',
                    style: const pw.TextStyle(fontSize: 8, color: _grey),
                  ),
                ],
              ],
            ),
            if (u.notes.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text(u.notes, style: const pw.TextStyle(fontSize: 8.5, color: _soft)),
              ),
          ],
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Matriz de la temporada

/// Semanas por página en la matriz (hoja Carta horizontal).
const matrixWeeksPerPage = 22;

Future<Uint8List> buildMatrixPdf(MatrixReport r, ReportAssets a) async {
  await initializeDateFormatting('es');
  final h = r.header;
  final title = 'Matriz fenológica · Temporada ${h.seasonName}';
  final doc = pw.Document(title: '$title · ${h.projectName}', creator: 'FramBitácora');
  final chunks = chunkWeeks(r.weeks, matrixWeeksPerPage);
  final legend = r.legend;
  final from = _fmt(r.weekStarts[r.weeks.first]!, "d 'de' MMMM");
  final to = _fmt(r.weekStarts[r.weeks.last]!.add(const Duration(days: 6)), "d 'de' MMMM 'de' y");

  doc.addPage(
    pw.MultiPage(
      theme: await _theme(a),
      pageFormat: PdfPageFormat.letter.landscape,
      margin: const pw.EdgeInsets.fromLTRB(34, 28, 34, 22),
      header: _runningHeader('$title · ${h.projectName}'),
      footer: _footer,
      build: (ctx) => [
        _title(
          title,
          '${h.kindLabel} · ${h.projectName} · Semanas ${r.weeks.first} a ${r.weeks.last} ($from al $to)',
          '${h.unitCount} ${h.unitCount == 1 ? 'unidad' : 'unidades'}  ·  ${h.cropName}',
          h.details,
        ),
        for (final weeks in chunks) ...[
          if (chunks.length > 1) _section('Semanas ${weeks.first} a ${weeks.last}') else pw.SizedBox(height: 14),
          _matrixTable(r, weeks),
        ],
        if (legend.isNotEmpty) ...[
          _section('Estados fenológicos'),
          pw.Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final s in legend)
                pw.SizedBox(
                  width: 165,
                  child: pw.Row(
                    children: [
                      _matrixCell(s, notSampled: false, width: 22),
                      pw.SizedBox(width: 6),
                      pw.Expanded(child: pw.Text(s.name, style: const pw.TextStyle(fontSize: 8))),
                    ],
                  ),
                ),
            ],
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'NM = semana no muestreada  ·  Celda vacía = sin registro',
          style: const pw.TextStyle(fontSize: 7.5, color: _grey),
        ),
      ],
    ),
  );
  return doc.save();
}

/// Matriz de unas semanas. En los ensayos de tratamientos, cada tratamiento va
/// con su título a lo ancho y debajo sus repeticiones.
pw.Widget _matrixTable(MatrixReport r, List<int> weeks) {
  const cell = 26.0;
  const labelWidth = 140.0;
  final widths = {
    0: const pw.FixedColumnWidth(labelWidth),
    for (var i = 1; i <= weeks.length; i++) i: const pw.FixedColumnWidth(cell),
  };
  const border = pw.TableBorder(
    horizontalInside: pw.BorderSide(color: _border, width: 0.5),
    bottom: pw.BorderSide(color: _border, width: 0.5),
  );
  final headerStyle = pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _soft);

  pw.TableRow unitRow(MatrixRow row) => pw.TableRow(
    verticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(row.label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            if (row.subtitle.isNotEmpty && row.group == null)
              pw.Text(row.subtitle, style: const pw.TextStyle(fontSize: 6.5, color: _grey)),
          ],
        ),
      ),
      for (final w in weeks)
        pw.Padding(
          padding: const pw.EdgeInsets.all(1.5),
          child: _matrixCell(row.stages[w], notSampled: r.notSampledWeeks.contains(w), width: cell),
        ),
    ],
  );

  final head = pw.TableRow(
    decoration: const pw.BoxDecoration(color: _sand),
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
  );

  // Filas seguidas que comparten grupo (tratamiento).
  final groups = <(String?, String, List<MatrixRow>)>[];
  for (final row in r.rows) {
    if (groups.isEmpty || groups.last.$1 != row.group || row.group == null && groups.last.$1 != null) {
      groups.add((row.group, row.subtitle, [row]));
    } else {
      groups.last.$3.add(row);
    }
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Table(tableWidth: pw.TableWidth.min, columnWidths: widths, children: [head]),
      for (final (group, subtitle, rows) in groups) ...[
        if (group != null)
          pw.Container(
            width: labelWidth + cell * weeks.length,
            color: _sandPale,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: pw.Text(
              subtitle.isEmpty ? group : '$group · $subtitle',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _olive),
            ),
          ),
        pw.Table(
          tableWidth: pw.TableWidth.min,
          border: border,
          columnWidths: widths,
          children: [for (final row in rows) unitRow(row)],
        ),
      ],
    ],
  );
}

/// Celda de la matriz: cuadro redondeado con el color y el código del estadio.
pw.Widget _matrixCell(ReportStage? s, {required bool notSampled, required double width}) {
  if (s == null) {
    return pw.Container(
      height: 16,
      alignment: pw.Alignment.center,
      decoration: notSampled
          ? const pw.BoxDecoration(color: _sandPale, borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)))
          : null,
      child: notSampled ? pw.Text('NM', style: const pw.TextStyle(fontSize: 6, color: _grey)) : null,
    );
  }
  return pw.Container(
    height: 16,
    width: width,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(s.color),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      border: pw.Border.all(color: _border, width: 0.4),
    ),
    child: pw.Text(
      s.code,
      style: pw.TextStyle(fontSize: 7, color: _onStage(s), fontWeight: pw.FontWeight.bold),
    ),
  );
}
