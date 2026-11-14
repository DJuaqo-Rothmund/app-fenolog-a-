import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/app.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/features/backup/backup_screen.dart';
import 'package:frambitacora/providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

/// Reemplaza «Compartir» y el selector de archivos del sistema.
class _FakeActions extends BackupFileActions {
  final shared = <String>[];
  String? toPick;

  @override
  Future<void> share(String path) async => shared.add(path);

  @override
  Future<String?> pickBackup(String tempDir) async => toPick;
}

void main() {
  late AppDatabase db;
  late Directory tmp;
  late _FakeActions actions;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('frambitacora_backup_ui');
    actions = _FakeActions();
  });

  tearDown(() => tmp.delete(recursive: true));

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
      photoStoreProvider.overrideWithValue(PhotoStore('${tmp.path}/docs')),
      tempDirProvider.overrideWithValue('${tmp.path}/cache'),
      backupFileActionsProvider.overrideWithValue(actions),
      todayProvider.overrideWithValue(DateTime(2026, 10, 30)),
    ],
    child: const FramBitacoraApp(),
  );

  /// Drift y la compresión corren fuera del reloj falso de las pruebas. Mientras
  /// trabaja, la pantalla muestra un indicador animado, así que se espera a que
  /// desaparezca antes de dejar que todo se asiente.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
      if (i >= 4 && find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<void> openBackupScreen(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Configuración'));
    await settle(tester);
    await tester.tap(find.text('Copia de seguridad'));
    await settle(tester);
  }

  testWidgets('crear una copia la ofrece para compartir y restaurarla recupera los datos', (tester) async {
    phoneScreen(tester);
    await tester.runAsync(() async {
      final crop = await db.select(db.crops).getSingle();
      final scale = await db.select(db.phenoScales).getSingle();
      await ProjectRepository(db).createProject(
        cropId: crop.id,
        scaleId: scale.id,
        kind: ProjectKind.farm,
        name: 'Predio Sur',
        seasonName: '2026-27',
        week1Start: DateTime.utc(2026, 9, 7),
      );
    });
    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text('Predio Sur'), findsOneWidget);

    await openBackupScreen(tester);
    await tester.tap(find.text('Crear copia y compartir'));
    await settle(tester);
    expect(actions.shared, hasLength(1));
    expect(File(actions.shared.single).existsSync(), isTrue);
    expect(find.textContaining('FramBitacora_respaldo_'), findsOneWidget);

    // Se cambia el nombre del proyecto y luego se restaura la copia.
    await tester.runAsync(() => db.customStatement("UPDATE projects SET name = 'Cambiado'"));
    actions.toPick = actions.shared.single;
    await tester.tap(find.text('Elegir copia para restaurar'));
    await settle(tester);
    expect(find.text('¿Restaurar esta copia?'), findsOneWidget);
    expect(find.textContaining('1 proyectos'), findsOneWidget);

    await tester.tap(find.text('Reemplazar todo'));
    await settle(tester);
    expect(find.text('FramBitácora'), findsOneWidget, reason: 'vuelve a la pantalla de inicio');
    expect(find.text('Predio Sur'), findsOneWidget);
    expect(find.text('Cambiado'), findsNothing);

    await finish(tester);
  });

  testWidgets('un archivo que no es copia muestra un aviso y no cambia nada', (tester) async {
    phoneScreen(tester);
    final bad = File('${tmp.path}/malo.zip')..writeAsBytesSync([1, 2, 3]);
    actions.toPick = bad.path;
    await tester.pumpWidget(app());
    await settle(tester);
    await openBackupScreen(tester);

    await tester.tap(find.text('Elegir copia para restaurar'));
    await settle(tester);
    expect(find.text('El archivo no es una copia de FramBitácora.'), findsWidgets);
    expect(find.text('¿Restaurar esta copia?'), findsNothing);

    await finish(tester);
  });
}
