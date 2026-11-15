import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/features/help/photo_guide_screen.dart';

void main() {
  test('la guía de detalle cubre cada macroestadio de la escala del frambueso, con el mismo nombre', () {
    final crop = jsonDecode(File('assets/crops/rubus-idaeus.json').readAsStringSync()) as Map<String, dynamic>;
    final macros = [
      for (final m in ((crop['scales'] as List).first as Map<String, dynamic>)['macros'] as List)
        (code: m['code'] as String, name: m['name'] as String),
    ];
    expect(detailByStage.map((s) => (code: s.code, name: s.stage)), macros);
  });
}
