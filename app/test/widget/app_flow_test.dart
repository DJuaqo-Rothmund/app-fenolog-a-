import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/app.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/features/projects/project_form_screen.dart';
import 'package:frambitacora/features/settings/project_settings_screen.dart';
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
  /// Pantalla del tamaño de un teléfono (411 × 891, en vertical).
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
    ],
    child: const FramBitacoraApp(),
  );

  /// Las consultas de drift corren fuera del reloj falso de las pruebas.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('sin proyectos se muestra la invitación a crear uno', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text('FramBitácora'), findsOneWidget);
    expect(find.textContaining('Aún no hay proyectos'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('crear un proyecto desde el formulario', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(app());
    await settle(tester);

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

    // Tras crear, se abre su configuración para agregar unidades.
    expect(find.text('Ensayo Los Ríos'), findsWidgets);
    expect(find.text('Unidades (0)'), findsOneWidget);
    final saved = await tester.runAsync(() => db.select(db.projects).getSingle());
    expect(saved!.kind, ProjectKind.farm.name);

    await finish(tester);
  });

  testWidgets('el proyecto muestra la semana actual y el avance', (tester) async {
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

  /// Cierra los avisos flotantes, deja [finder] completo en pantalla y lo toca.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).removeCurrentSnackBar();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  /// Lista de la configuración del proyecto.
  Finder settingsList() =>
      find.descendant(of: find.byType(ProjectSettingsScreen), matching: find.byType(Scrollable)).first;

  /// Lista del formulario de proyecto (Configuración queda debajo, también con lista).
  Finder formList() => find.descendant(of: find.byType(ProjectFormScreen), matching: find.byType(Scrollable)).first;

  testWidgets('desde Configuración se arma un ensayo de variedades completo', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.byTooltip('Configuración'));
    await settle(tester);
    expect(find.text('Variedades'), findsOneWidget);
    expect(find.text('Copia de seguridad'), findsOneWidget);

    // Nuevo proyecto (ensayo de variedades, el tipo por defecto).
    await tester.tap(find.text('Nuevo proyecto'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Nuevas variedades');
    await tester.scrollUntilVisible(find.text('Crear proyecto'), 200, scrollable: formList());
    await tester.drag(formList(), const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear proyecto'));
    await settle(tester);

    // Queda en la configuración del proyecto, lista para agregar variedades.
    expect(find.text('Unidades (0)'), findsOneWidget);
    await tester.tap(find.text('Agregar variedades'));
    await settle(tester);
    await tester.tap(find.text('Nueva'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Heritage');
    await tester.tap(find.text('Guardar'));
    await settle(tester);
    await tester.tap(find.text('Agregar 1'));
    await settle(tester);
    expect(find.text('Unidades (1)'), findsOneWidget);
    expect(find.text('Heritage'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Listo, ir al proyecto'),
      200,
      scrollable: find.descendant(of: find.byType(ProjectSettingsScreen), matching: find.byType(Scrollable)).first,
    );
    await tapVisible(tester, find.text('Listo, ir al proyecto'));
    await settle(tester);
    expect(find.text('Semana 8'), findsOneWidget);
    expect(find.text('Heritage'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('el registro muestra cajitas de fotos con botones pequeños y notas', (tester) async {
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
    await tester.tap(find.text('Ensayo'));
    await settle(tester);
    await tester.tap(find.text('Heritage'));
    await settle(tester);

    expect(find.byTooltip('Tomar foto'), findsNWidgets(3));
    expect(find.byTooltip('Elegir de la galería'), findsNWidgets(3));
    expect(find.text('Sin fotos'), findsNWidgets(3));
    await tester.scrollUntilVisible(find.text('Notas'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.widgetWithText(TextField, 'Observaciones técnicas'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('ensayo de tratamientos: diseño al crearlo, descripción y cambios en Configuración', (tester) async {
    phoneScreen(tester);
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.text('Proyecto'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Dosis de nitrógeno');
    await tester.tap(find.text('Ensayo de tratamientos'));
    await tester.pump();

    // Diseño: 2 tratamientos + testigo × 3 repeticiones.
    await tester.scrollUntilVisible(find.byTooltip('menos tratamientos'), 100, scrollable: formList());
    await tester.drag(formList(), const Offset(0, -150));
    await tester.pumpAndSettle();
    for (final tip in ['menos tratamientos', 'menos tratamientos', 'menos repeticiones']) {
      await tester.tap(find.byTooltip(tip));
      await tester.pump();
    }
    expect(find.text('T0 (testigo) + T1…T2 × 3 repeticiones = 9 unidades'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Crear proyecto'), 200, scrollable: formList());
    await tester.drag(formList(), const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear proyecto'));
    await settle(tester);

    expect(find.text('T0 (testigo) + T1…T2 × 3 repeticiones = 9 unidades'), findsOneWidget);
    expect(find.text('Testigo'), findsWidgets);

    // Describir T1.
    await tester.scrollUntilVisible(find.text('T1'), 150, scrollable: settingsList());
    await tapVisible(tester, find.text('T1'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '2 L/ha producto A');
    await tester.tap(find.text('Guardar'));
    await settle(tester);
    expect(find.text('2 L/ha producto A'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Unidades (9)'), 200, scrollable: settingsList());
    await tester.scrollUntilVisible(
      find.text('T0 (testigo) + T1…T2 × 3 repeticiones = 9 unidades'),
      -200,
      scrollable: settingsList(),
    );

    // Cambiar el diseño: sin testigo, con la confirmación de que se quitan unidades.
    await tapVisible(tester, find.text('T0 (testigo) + T1…T2 × 3 repeticiones = 9 unidades'));
    await settle(tester);
    await tester.tap(find.text('¿Tiene testigo (T0)?'));
    await tester.pump();
    await tester.tap(find.text('Aplicar'));
    await settle(tester);
    expect(find.text('Quitar unidades'), findsOneWidget);
    await tester.tap(find.text('Aplicar'));
    await settle(tester);
    expect(find.text('T1…T2 × 3 repeticiones = 6 unidades'), findsOneWidget);
    final units = await tester.runAsync(() => db.select(db.units).get());
    expect(units!.where((u) => u.deletedAt == null).map((u) => u.treatment).toSet(), {'T1', 'T2'});

    await finish(tester);
  });

  testWidgets('avance de la temporada: muestra el error, abre el registro y se actualiza al corregir', (tester) async {
    phoneScreen(tester);
    late String fixId, rightStage;
    await tester.runAsync(() async {
      final crop = await db.select(db.crops).getSingle();
      final scale = await db.select(db.phenoScales).getSingle();
      final stages = await db.select(db.phenoStages).get();
      String stage(String code) => stages.firstWhere((s) => s.code == code).id;
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
          .insert(
            SeasonsCompanion.insert(
              id: const Value('s1'),
              projectId: 'p1',
              name: '2026-27',
              week1Start: DateTime.utc(2026, 9, 7),
            ),
          );
      await db.into(db.units).insert(UnitsCompanion.insert(id: const Value('u1'), projectId: 'p1', label: 'Heritage'));
      Future<String> obs(int week, String code) async {
        final o = await db
            .into(db.observations)
            .insertReturning(
              ObservationsCompanion.insert(seasonId: 's1', unitId: 'u1', weekNumber: week, stageId: Value(stage(code))),
            );
        await db
            .into(db.photos)
            .insert(
              PhotosCompanion.insert(
                observationId: o.id,
                kind: 'general',
                seq: 1,
                fileName: 'f$week.jpg',
                localPath: 'fotos/f$week.jpg',
                takenAt: DateTime(2026, 10, 1),
              ),
            );
        return o.id;
      }

      await obs(6, '55');
      fixId = await obs(7, '51');
      rightStage = stage('57');
    });
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.text('Ensayo'));
    await settle(tester);
    await tester.tap(find.byTooltip('Avance de la temporada'));
    await settle(tester);

    expect(find.text('1 posible error para revisar'), findsOneWidget);
    expect(find.text('Heritage · S7: el estado 51 es anterior al de S6 (55)'), findsOneWidget);

    // Desde la alerta se abre el registro de esa semana.
    await tapVisible(tester, find.text('Heritage · S7: el estado 51 es anterior al de S6 (55)'));
    await settle(tester);
    expect(find.text('Semana 7 · desde el lun 19 de oct'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(tester);

    // Al corregir el estado, la revisión se actualiza sola.
    await tester.runAsync(
      () => (db.update(
        db.observations,
      )..where((o) => o.id.equals(fixId))).write(ObservationsCompanion(stageId: Value(rightStage))),
    );
    await settle(tester);
    expect(find.text('Sin posibles errores: lista para el informe'), findsOneWidget);

    await finish(tester);
  });

  testWidgets('guía de fotos: desde el registro abre la pestaña del tipo de foto', (tester) async {
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
    await tester.tap(find.text('Ensayo'));
    await settle(tester);
    await tester.tap(find.text('Heritage'));
    await settle(tester);

    // La segunda ayuda es la de las fotos de detalle.
    await tapVisible(tester, find.byTooltip('Cómo tomar esta foto').at(1));
    await settle(tester);
    expect(find.text('Guía de fotos'), findsOneWidget);
    expect(find.text('Foto de detalle: el estado fenológico'), findsOneWidget);
    expect(find.text('A 10–20 cm y enfocado'), findsOneWidget);

    await tester.tap(find.text('General'));
    await settle(tester);
    expect(find.text('Foto general: la canopia'), findsOneWidget);

    await finish(tester);
  });
}
