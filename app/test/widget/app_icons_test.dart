import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/features/app_icons.dart';

void main() {
  test('cada ícono propio y cada imagen de marca tiene su archivo SVG', () {
    for (final icon in AppIcons.values) {
      final f = File('assets/icons/${icon.name}.svg');
      expect(f.existsSync(), isTrue, reason: f.path);
      expect(f.readAsStringSync(), contains('viewBox="0 0 24 24"'), reason: f.path);
    }
    for (final name in [
      'logo',
      'empty_projects',
      'launcher_foreground',
      'launcher_background',
      'launcher_monochrome',
    ]) {
      expect(File('assets/brand/$name.svg').existsSync(), isTrue, reason: name);
    }
  });

  testWidgets('AppIcon toma el tamaño del entorno', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IconTheme(
          data: IconThemeData(size: 30, color: Colors.red),
          child: Center(child: AppIcon(AppIcons.camera)),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppIcon)), const Size(30, 30));
  });
}
