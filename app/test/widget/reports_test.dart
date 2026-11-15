import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/app.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/features/reports/reports_screen.dart';
import 'package:frambitacora/providers.dart';
import 'package:frambitacora/reports/pdf_reports.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  Uint8List? shown;
  String? shownName;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = await testDatabase();
    shown = null;
  });

  void phoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1080 / 411;
    addTearDown(tester.view.reset);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  Widget app() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      photoStoreProvider.overrideWithValue(PhotoStore(Directory.systemTemp.path)),
      tempDirProvider.overrideWithValue(Directory.systemTemp.path),
      todayProvider.overrideWithValue(DateTime(2026, 10, 30)),
      photoShrinkerProvider.overrideWithValue((f) async => null),
      reportAssetsProvider.overrideWith(
        (ref) async => ReportAssets(
          regular: ByteData.sublistView(File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync()),
          bold: ByteData.sublistView(File('assets/fonts/Roboto-Bold.ttf').readAsBytesSync()),
          logoSvg: File('assets/brand/symbol.svg').readAsStringSync(),
        ),
      ),
      // En las pruebas no hay visor de PDF del sistema: se muestra el tamaño del archivo.
      pdfViewerProvider.overrideWithValue((pdf, name) {
        shown = pdf;
        shownName = name;
        return Center(child: Text('PDF listo: $name'));
      }),
    ],
    child: const FramBitacoraApp(),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
      if (i >= 4 && find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  testWidgets('desde un proyecto se genera el informe semanal y la matriz', (tester) async {
    phoneScreen(tester);
    await tester.runAsync(() async {
      final crop = await db.select(db.crops).getSingle();
      final scale = await db.select(db.phenoScales).getSingle();
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: const Value('p1'),
              cropId: crop.id,
              scaleId: scale.id,
              kind: ProjectKind.varietyTrial.name,
              name: 'Ensayo nuevas variedades',
            ),
          );
      await db
          .into(db.seasons)
          .insert(SeasonsCompanion.insert(projectId: 'p1', name: '2026-27', week1Start: DateTime.utc(2026, 9, 7)));
      await db.into(db.units).insert(UnitsCompanion.insert(projectId: 'p1', label: 'Heritage'));
    });
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.text('Ensayo nuevas variedades'));
    await settle(tester);

    await tester.tap(find.byTooltip('Informes'));
    await settle(tester);
    expect(find.text('Informe semanal · Semana 8'), findsOneWidget);
    await tester.tap(find.text('Generar informe semanal'));
    await settle(tester);
    expect(find.text('PDF listo: Informe_semanal_Ensayo_nuevas_variedades_S8.pdf'), findsOneWidget);
    expect(String.fromCharCodes(shown!.take(5)), '%PDF-');

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(tester);
    await tester.tap(find.byTooltip('Informes'));
    await settle(tester);
    await tester.tap(find.text('Generar matriz'));
    await settle(tester);
    expect(shownName, 'Matriz_Ensayo_nuevas_variedades_2026-27.pdf');
    expect(String.fromCharCodes(shown!.take(5)), '%PDF-');

    await finish(tester);
  });

  test('nombre de archivo sin tildes ni espacios', () {
    expect(
      reportFileName('Informe_semanal', 'Ensayo Ñuble – riego', 'S10'),
      'Informe_semanal_Ensayo_Nuble_riego_S10.pdf',
    );
  });
}
