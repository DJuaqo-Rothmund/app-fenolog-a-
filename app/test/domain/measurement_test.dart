import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/measurement.dart';

void main() {
  group('parseMeasurement', () {
    test('acepta coma o punto decimal', () {
      expect(parseMeasurement('12,5', kind: MeasurementKind.number).value?.number, 12.5);
      expect(parseMeasurement('12.5', kind: MeasurementKind.number).value?.number, 12.5);
    });

    test('vacío borra el valor sin error', () {
      final r = parseMeasurement('  ', kind: MeasurementKind.number);
      expect(r.value, isNull);
      expect(r.error, isNull);
    });

    test('valida enteros, mínimo y máximo', () {
      expect(parseMeasurement('3,5', kind: MeasurementKind.integer).error, 'Debe ser un número entero');
      expect(parseMeasurement('abc', kind: MeasurementKind.number).error, 'Debe ser un número');
      expect(parseMeasurement('-1', kind: MeasurementKind.number, min: 0).error, 'Mínimo 0');
      expect(parseMeasurement('101', kind: MeasurementKind.number, max: 100).error, 'Máximo 100');
      expect(parseMeasurement('7', kind: MeasurementKind.integer, min: 0, max: 10).value?.number, 7);
    });

    test('las opciones deben estar en la lista', () {
      final choices = parseChoices('Sana\n\n Con daño \n');
      expect(choices, ['Sana', 'Con daño']);
      expect(parseMeasurement('Con daño', kind: MeasurementKind.choice, choices: choices).value?.text, 'Con daño');
      expect(parseMeasurement('Otra', kind: MeasurementKind.choice, choices: choices).error, isNotNull);
    });

    test('el texto se guarda tal cual, sin espacios al borde', () {
      expect(parseMeasurement(' hojas rojizas ', kind: MeasurementKind.text).value?.text, 'hojas rojizas');
    });
  });

  test('formatNumber quita decimales innecesarios y usa coma', () {
    expect(formatNumber(12), '12');
    expect(formatNumber(3.5), '3,5');
    expect(formatNumber(0.125), '0,125');
  });
}
