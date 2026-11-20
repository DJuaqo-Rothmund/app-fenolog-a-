import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/app.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/features/drive/google_auth.dart';
import 'package:frambitacora/providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/drive_test.dart' show FakeDrive;
import '../helpers.dart';

class _FakeAuth implements GoogleAuth {
  int tokens = 0;
  int signOuts = 0;
  bool fail = false;

  @override
  Future<String> token() async {
    if (fail) throw GoogleAuthException('Se canceló la conexión con Google.');
    tokens++;
    return 'token';
  }

  @override
  Future<void> signOut() async => signOuts++;
}

void main() {
  late AppDatabase db;
  late Directory tmp;
  late _FakeAuth auth;
  late FakeDrive drive;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('drive_ui');
    auth = _FakeAuth();
    drive = FakeDrive();
  });

  tearDown(() => tmp.delete(recursive: true));

  Widget app() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      photoStoreProvider.overrideWithValue(PhotoStore('${tmp.path}/docs')),
      tempDirProvider.overrideWithValue('${tmp.path}/cache'),
      todayProvider.overrideWithValue(DateTime(2026, 11, 20)),
      googleAuthProvider.overrideWithValue(auth),
      driveApiProvider.overrideWithValue(drive),
    ],
    child: const FramBitacoraApp(),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
      if (i >= 4 &&
          find.byType(CircularProgressIndicator).evaluate().isEmpty &&
          find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
  }

  Future<void> openDrive(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1080 / 411;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.byTooltip('Configuración'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Google Drive'), 300, scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(find.text('Google Drive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google Drive'));
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  testWidgets('conectar con Google, sincronizar y cambiar de cuenta', (tester) async {
    await openDrive(tester);
    expect(find.text('Continuar con Google'), findsOneWidget);

    await tester.tap(find.text('Continuar con Google'));
    await settle(tester);
    expect(auth.tokens, 1);
    expect(find.text('Google Drive conectado · ana@ejemplo.cl'), findsOneWidget);
    expect(find.text('Cambiar cuenta de Google'), findsOneWidget);
    expect(find.text('Todas las fotos están en Drive'), findsOneWidget);

    await tester.tap(find.text('Sincronizar ahora'));
    await settle(tester);
    expect(find.textContaining('Listo: 0 fotos subidas'), findsOneWidget);
    expect(drive.uploads.single, startsWith('/FramBitácora/Respaldos/'));
    expect(find.textContaining('Última sincronización'), findsOneWidget);

    await tester.tap(find.text('Cambiar cuenta de Google'));
    await settle(tester);
    expect(auth.signOuts, 1);
    expect(auth.tokens, 2);

    await finish(tester);
  });

  testWidgets('si se cancela la conexión, lo dice y sigue sin cuenta', (tester) async {
    auth.fail = true;
    await openDrive(tester);
    await tester.tap(find.text('Continuar con Google'));
    await settle(tester);
    expect(find.text('Se canceló la conexión con Google.'), findsWidgets);
    expect(find.text('Continuar con Google'), findsOneWidget);
    await finish(tester);
  });
}
