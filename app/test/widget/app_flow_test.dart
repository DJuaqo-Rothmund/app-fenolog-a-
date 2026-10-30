import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/app.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = await testDatabase();
  });

  /// Desmonta la app y deja que drift cierre sus consultas antes de terminar.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  Widget app() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db), todayProvider.overrideWithValue(DateTime(2026, 10, 30))],
    child: const FramBitacoraApp(),
  );

  /// Las consultas de drift corren fuera del reloj falso de las pruebas.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  /// Desde la portada: entra al frambueso sin sincronizar.
  Future<void> enterLocal(WidgetTester tester) async {
    await tester.tap(find.text('Continuar de forma local'));
    await settle(tester);
  }

  testWidgets('portada: elegir cultivo y cómo trabajar', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text('FramBitácora'), findsOneWidget);
    expect(find.text('Frambueso'), findsOneWidget);
    expect(find.text('Rubus idaeus'), findsOneWidget);
    expect(find.text('0 proyectos'), findsOneWidget);
    expect(find.text('Sincronizar con mi correo'), findsOneWidget);

    // Sin sesión, sincronizar lleva a iniciar sesión con el correo.
    await tester.tap(find.text('Sincronizar con mi correo'));
    await settle(tester);
    expect(find.text('Dirección del servidor'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    await enterLocal(tester);
    expect(find.text('Frambueso'), findsOneWidget, reason: 'título de la lista de proyectos');
    final prefs = await tester.runAsync(() => db.select(db.syncMeta).get());
    expect(prefs!.map((m) => m.key), contains('pref_last_crop'));

    await finish(tester);
  });

  testWidgets('sin proyectos se muestra la invitación a crear uno', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);
    await enterLocal(tester);
    expect(find.textContaining('Aún no hay proyectos'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('crear un proyecto desde el formulario', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);
    await enterLocal(tester);

    await tester.tap(find.text('Proyecto'));
    await settle(tester);
    expect(find.text('Nuevo proyecto'), findsOneWidget);
    expect(find.text('2026-27'), findsOneWidget, reason: 'temporada sugerida según la fecha');

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Ensayo Los Ríos');
    await tester.tap(find.text('Predio'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Crear proyecto'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Crear proyecto'));
    await settle(tester);

    expect(find.text('Ensayo Los Ríos'), findsOneWidget);
    final saved = await tester.runAsync(() => db.select(db.projects).getSingle());
    expect(saved!.kind, ProjectKind.farm.name);

    await finish(tester);
  });

  testWidgets('el proyecto muestra la semana actual y el avance', (tester) async {
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
              name: 'Ensayo',
            ),
          );
      await db
          .into(db.seasons)
          .insert(SeasonsCompanion.insert(projectId: 'p1', name: '2026-27', week1Start: DateTime.utc(2026, 9, 7)));
      await db.into(db.units).insert(UnitsCompanion.insert(projectId: 'p1', label: 'Heritage'));
    });

    await tester.pumpWidget(app());
    await settle(tester);
    await enterLocal(tester);
    await tester.tap(find.text('Ensayo'));
    await settle(tester);

    // 30-oct-2026 cae en la semana 8 si la semana 1 empieza el 7-sep.
    expect(find.text('Semana 8'), findsOneWidget);
    expect(find.text('Heritage'), findsOneWidget);
    expect(find.text('0 de 1 registros completos'), findsOneWidget);

    await tester.tap(find.byTooltip('Semana anterior'));
    await settle(tester);
    expect(find.text('Semana 7'), findsOneWidget);
    expect(find.text('Ir a la semana actual'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('crear una medición y registrarla en la semana', (tester) async {
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
              name: 'Ensayo',
            ),
          );
      await db
          .into(db.seasons)
          .insert(SeasonsCompanion.insert(projectId: 'p1', name: '2026-27', week1Start: DateTime.utc(2026, 9, 7)));
      await db.into(db.units).insert(UnitsCompanion.insert(projectId: 'p1', label: 'Heritage'));
    });

    await tester.pumpWidget(app());
    await settle(tester);
    await enterLocal(tester);
    await tester.tap(find.text('Ensayo'));
    await settle(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await settle(tester);
    await tester.tap(find.text('Mediciones'));
    await settle(tester);
    expect(find.textContaining('Aún no hay mediciones'), findsOneWidget);

    await tester.tap(find.text('Medición'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Largo de brote');
    await tester.enterText(find.widgetWithText(TextFormField, 'Unidad (cm, n.º, kg/ha…)'), 'cm');
    await tester.enterText(find.widgetWithText(TextFormField, 'Máximo'), '300');
    await tester.tap(find.text('Guardar'));
    await settle(tester);
    expect(find.text('Largo de brote (cm)'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tester.tap(find.text('Heritage'));
    await settle(tester);
    expect(find.text('Mediciones'), findsOneWidget);

    final field = find.widgetWithText(TextField, 'Largo de brote (cm)');
    await tester.enterText(field, '400');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('Máximo 300'), findsOneWidget);

    await tester.enterText(field, '12,5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    final values = await tester.runAsync(() => db.select(db.measurementValues).get());
    expect(values!.single.valueNum, 12.5);

    await finish(tester);
  });
}
