import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/crop_definition.dart';

/// Pasa por JSON para tener los mismos tipos que al leer un archivo.
Map<String, dynamic> minimal() => jsonDecode(
  jsonEncode({
    'format': 1,
    'code': 'demo',
    'shortCode': 'DEM',
    'name': 'Demo',
    'seasonStart': {'month': 9, 'day': 7},
    'scales': [
      {
        'name': 'Escala demo',
        'version': 1,
        'default': true,
        'macros': [
          {'code': '0', 'name': 'Yemas'},
        ],
        'stages': [
          {'code': '00', 'macro': '0', 'name': 'Reposo', 'color': '#6D4C41'},
        ],
      },
    ],
  }),
) as Map<String, dynamic>;

void main() {
  test('la definición del frambueso incluida en la app es válida', () {
    final json = jsonDecode(File('assets/crops/rubus-idaeus.json').readAsStringSync()) as Map<String, dynamic>;
    final crop = CropDefinition.fromJson(json);
    expect(crop.name, 'Frambueso');
    expect(crop.seasonStartMonth, 9);
    final scale = crop.scales.single;
    expect(scale.isDefault, isTrue);
    expect(scale.stages.length, greaterThan(30));
    // Los códigos BBCH de dos dígitos van en orden creciente.
    final codes = scale.stages.map((s) => int.parse(s.code)).toList();
    expect(codes, [...codes]..sort());
  });

  test('definición mínima', () {
    final crop = CropDefinition.fromJson(minimal());
    expect(crop.scales.single.stages.single.color, 0xFF6D4C41);
  });

  test('rechaza estadios repetidos', () {
    final json = minimal();
    final stages = (json['scales'] as List).first['stages'] as List;
    stages.add(Map<String, dynamic>.of(stages.first as Map<String, dynamic>));
    expect(() => CropDefinition.fromJson(json), throwsA(isA<CropDefinitionError>()));
  });

  test('rechaza macroestadios desconocidos', () {
    final json = minimal();
    ((json['scales'] as List).first['stages'] as List).first['macro'] = '7';
    expect(() => CropDefinition.fromJson(json), throwsA(isA<CropDefinitionError>()));
  });

  test('rechaza colores mal escritos y formatos desconocidos', () {
    final json = minimal();
    ((json['scales'] as List).first['stages'] as List).first['color'] = 'rojo';
    expect(() => CropDefinition.fromJson(json), throwsA(isA<CropDefinitionError>()));
    expect(() => CropDefinition.fromJson(minimal()..['format'] = 2), throwsA(isA<CropDefinitionError>()));
  });

  test('rechaza campos faltantes', () {
    expect(() => CropDefinition.fromJson(minimal()..remove('shortCode')), throwsA(isA<CropDefinitionError>()));
  });
}
