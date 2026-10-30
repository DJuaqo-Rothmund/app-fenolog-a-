/// Lectura de planillas CSV de temporadas anteriores.
///
/// Columnas reconocidas (sin importar mayúsculas ni tildes):
/// - `Semana` (número de semana de temporada) o `Fecha` (aaaa-mm-dd o dd-mm-aaaa).
/// - `Unidad` (obligatoria).
/// - `Código estadio` o `Estadio` o `BBCH`.
/// - `Notas`.
/// - Cualquier otra columna cuyo nombre coincida con una medición semanal
///   del proyecto (con o sin la unidad entre paréntesis).
/// Es el mismo formato de la hoja «Registros» exportada.
library;

import 'season_weeks.dart';

/// Separa un texto CSV en filas. Detecta `;`, `,` o tabulador como separador
/// y respeta comillas dobles.
List<List<String>> parseCsv(String text) {
  if (text.startsWith('﻿')) text = text.substring(1);
  final firstLine = text.split(RegExp(r'\r?\n')).first;
  final sep = [';', '\t', ','].reduce((a, b) => firstLine.split(a).length >= firstLine.split(b).length ? a : b);

  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == sep) {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      if (row.any((s) => s.trim().isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  row.add(cell.toString());
  if (row.any((s) => s.trim().isNotEmpty)) rows.add(row);
  return rows;
}

/// Minúsculas, sin tildes ni espacios sobrantes: «Código Estadio » → «codigo estadio».
String normalizeHeader(String s) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  final lower = s.trim().toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    buf.write(i >= 0 ? to[i] : ch);
  }
  return buf.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Una fila válida de la planilla.
class CsvRecord {
  const CsvRecord({
    required this.line,
    required this.week,
    required this.unit,
    this.stageCode,
    this.notes,
    this.measurements = const {},
  });
  final int line;
  final int week;
  final String unit;
  final String? stageCode;
  final String? notes;

  /// Texto crudo por nombre de medición (tal como aparece en el proyecto).
  final Map<String, String> measurements;
}

class CsvImportResult {
  const CsvImportResult({required this.records, required this.errors, required this.ignoredColumns});
  final List<CsvRecord> records;

  /// Mensajes por fila con problemas («Fila 4: …»).
  final List<String> errors;
  final List<String> ignoredColumns;
}

const _weekHeaders = {'semana', 'semana temporada', 'n semana', 'week'};
const _dateHeaders = {'fecha', 'desde', 'date'};
const _unitHeaders = {'unidad', 'unit', 'parcela'};
const _stageHeaders = {'codigo estadio', 'estadio', 'bbch', 'codigo', 'stage'};
const _notesHeaders = {'notas', 'nota', 'observaciones', 'notes'};

/// Columnas de la exportación que no se importan (se calculan solas).
const _derivedHeaders = {
  'semana iso',
  'variedad',
  'tratamiento',
  'repeticion',
  'equipo de riego',
  'sector',
  'fotos',
  'completo',
  'latitud',
  'longitud',
};

/// Interpreta la planilla. [measurementNames] son los nombres de las
/// mediciones semanales del proyecto; [week1Start] permite usar fechas en vez
/// de semanas.
CsvImportResult readSeasonCsv(String text, {required List<String> measurementNames, required DateTime week1Start}) {
  final rows = parseCsv(text);
  if (rows.isEmpty) return const CsvImportResult(records: [], errors: ['El archivo está vacío.'], ignoredColumns: []);

  final headers = [for (final h in rows.first) normalizeHeader(h)];
  int? find(Set<String> names) {
    final i = headers.indexWhere(names.contains);
    return i < 0 ? null : i;
  }

  final weekCol = find(_weekHeaders);
  final dateCol = find(_dateHeaders);
  final unitCol = find(_unitHeaders);
  // «Estadio» puede ser el nombre; se prefiere la columna de código si existe.
  final stageCol = find({'codigo estadio', 'bbch', 'codigo'}) ?? find(_stageHeaders);
  final notesCol = find(_notesHeaders);

  final errors = <String>[];
  if (unitCol == null) errors.add('Falta la columna «Unidad».');
  if (weekCol == null && dateCol == null) errors.add('Falta la columna «Semana» o «Fecha».');
  if (errors.isNotEmpty) return CsvImportResult(records: const [], errors: errors, ignoredColumns: const []);

  final measurementCols = <int, String>{};
  final ignored = <String>[];
  final known = {
    weekCol,
    dateCol,
    unitCol,
    stageCol,
    notesCol,
    ...[
      for (final (i, h) in headers.indexed)
        if (_stageHeaders.contains(h)) i,
    ],
  };
  for (final (i, h) in headers.indexed) {
    if (known.contains(i) || _derivedHeaders.contains(h) || h.isEmpty) continue;
    final match = measurementNames.where((m) {
      final n = normalizeHeader(m);
      return h == n || h.startsWith('$n (');
    }).firstOrNull;
    if (match != null) {
      measurementCols[i] = match;
    } else {
      ignored.add(rows.first[i].trim());
    }
  }

  String at(List<String> row, int? col) => col == null || col >= row.length ? '' : row[col].trim();

  final records = <CsvRecord>[];
  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    final line = r + 1;
    final unit = at(row, unitCol);
    if (unit.isEmpty) {
      errors.add('Fila $line: falta la unidad.');
      continue;
    }
    int? week;
    final weekText = at(row, weekCol);
    if (weekText.isNotEmpty) {
      week = int.tryParse(weekText);
    } else {
      final date = parseDate(at(row, dateCol));
      if (date != null) week = seasonWeekFor(date, week1Start);
    }
    if (week == null || week < 1) {
      errors.add('Fila $line: semana o fecha no válida.');
      continue;
    }
    final stage = at(row, stageCol);
    final notes = at(row, notesCol);
    records.add(
      CsvRecord(
        line: line,
        week: week,
        unit: unit,
        stageCode: stage.isEmpty ? null : stage,
        notes: notes.isEmpty ? null : notes,
        measurements: {
          for (final MapEntry(key: col, value: name) in measurementCols.entries)
            if (at(row, col).isNotEmpty) name: at(row, col),
        },
      ),
    );
  }
  return CsvImportResult(records: records, errors: errors, ignoredColumns: ignored);
}

/// Acepta `aaaa-mm-dd`, `dd-mm-aaaa` y `dd/mm/aaaa`.
DateTime? parseDate(String s) {
  final iso = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(s);
  if (iso != null) {
    return DateTime.utc(int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!));
  }
  final dmy = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})').firstMatch(s);
  if (dmy != null) {
    return DateTime.utc(int.parse(dmy[3]!), int.parse(dmy[2]!), int.parse(dmy[1]!));
  }
  return null;
}
