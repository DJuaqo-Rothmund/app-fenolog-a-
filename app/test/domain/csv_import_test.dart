import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/csv_import.dart';

void main() {
  group('parseCsv', () {
    test('detecta punto y coma y respeta comillas', () {
      final rows = parseCsv('﻿Semana;Unidad;Notas\r\n1;Heritage;"flor; abierta"\r\n2;"Tula ""T""";\r\n\r\n');
      expect(rows, [
        ['Semana', 'Unidad', 'Notas'],
        ['1', 'Heritage', 'flor; abierta'],
        ['2', 'Tula "T"', ''],
      ]);
    });

    test('detecta coma y tabulador', () {
      expect(parseCsv('a,b\n1,2').last, ['1', '2']);
      expect(parseCsv('a\tb\n1\t2').last, ['1', '2']);
    });

    test('acepta saltos de línea dentro de comillas', () {
      expect(parseCsv('a;b\n"uno\ndos";3').last, ['uno\ndos', '3']);
    });
  });

  test('normalizeHeader quita tildes, mayúsculas y espacios', () {
    expect(normalizeHeader('  Código  Estadio '), 'codigo estadio');
    expect(normalizeHeader('Repetición'), 'repeticion');
  });

  group('readSeasonCsv', () {
    final week1 = DateTime.utc(2026, 9, 7);

    test('lee la hoja «Registros» exportada', () {
      final r = readSeasonCsv(
        'Semana;Desde;Semana ISO;Unidad;Variedad;Código estadio;Estadio;Fotos;Notas;Largo de brote (cm);Otra\n'
        '3;2026-09-21;39;Heritage;Heritage;61;Inicio de floración;2;primeras flores;12,5;x\n',
        measurementNames: ['Largo de brote'],
        week1Start: week1,
      );
      expect(r.errors, isEmpty);
      expect(r.ignoredColumns, ['Otra']);
      final rec = r.records.single;
      expect(rec.week, 3);
      expect(rec.unit, 'Heritage');
      expect(rec.stageCode, '61');
      expect(rec.notes, 'primeras flores');
      expect(rec.measurements, {'Largo de brote': '12,5'});
    });

    test('calcula la semana desde la fecha', () {
      final r = readSeasonCsv(
        'Fecha;Unidad;BBCH\n23/09/2026;T1 R1;55\n2026-09-07;T1 R2;\n',
        measurementNames: const [],
        week1Start: week1,
      );
      expect(r.records.map((x) => x.week), [3, 1]);
      expect(r.records.last.stageCode, isNull);
    });

    test('informa filas con problemas y columnas faltantes', () {
      final r = readSeasonCsv('Semana;Unidad\nabc;A\n2;\n4;B\n', measurementNames: const [], week1Start: week1);
      expect(r.records.single.unit, 'B');
      expect(r.errors, ['Fila 2: semana o fecha no válida.', 'Fila 3: falta la unidad.']);

      expect(readSeasonCsv('Unidad\nA', measurementNames: const [], week1Start: week1).errors, [
        'Falta la columna «Semana» o «Fecha».',
      ]);
    });
  });
}
