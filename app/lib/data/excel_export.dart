import 'package:excel/excel.dart';

import '../domain/measurement.dart';
import 'season_data.dart';
import 'season_tables.dart' as t;

/// Libro Excel de una temporada: registros, matriz de estadios, parámetros
/// por variedad y escala.
List<int> buildSeasonWorkbook(SeasonData d) {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet()!;
  final sheets = <String, t.SheetTable>{
    'Registros': t.recordsTable(d),
    'Matriz de estadios': t.stageMatrixTable(d),
    if (d.varietyDefs.isNotEmpty) 'Parámetros por variedad': t.varietyParamsTable(d),
    'Escala': t.scaleTable(d),
  };
  for (final MapEntry(key: name, value: table) in sheets.entries) {
    final sheet = excel[name];
    for (final (i, row) in table.indexed) {
      sheet.appendRow([for (final cell in row) _cell(cell)]);
      if (i == 0) {
        for (var c = 0; c < row.length; c++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).cellStyle = CellStyle(bold: true);
        }
      }
    }
  }
  excel.setDefaultSheet('Registros');
  excel.delete(defaultSheet);
  return excel.encode()!;
}

CellValue? _cell(Object? v) => switch (v) {
  null => null,
  int i => IntCellValue(i),
  double n => DoubleCellValue(n),
  DateTime dt => DateCellValue(year: dt.year, month: dt.month, day: dt.day),
  _ => TextCellValue(v.toString()),
};

/// CSV con punto y coma y coma decimal (lo que espera Excel en español).
String toCsv(t.SheetTable table) {
  String cell(Object? v) {
    final s = switch (v) {
      null => '',
      double n => formatNumber(n),
      DateTime dt => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
      _ => v.toString(),
    };
    return s.contains(RegExp('[;"\n\r]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  return '${table.map((row) => row.map(cell).join(';')).join('\r\n')}\r\n';
}
