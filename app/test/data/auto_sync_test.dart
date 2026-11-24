import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/features/drive/auto_sync.dart';
import 'package:frambitacora/features/drive/google_auth.dart';
import 'package:frambitacora/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../fake_drive.dart';
import '../helpers.dart';

/// Inicio de sesión que anota si se le permitió abrir la ventana de Google.
class _Auth implements GoogleAuth {
  final asked = <bool>[];

  @override
  Future<String> token({bool interactive = true}) async {
    asked.add(interactive);
    if (!interactive) throw GoogleAuthException('Toca «Sincronizar ahora».', needsUser: true);
    throw GoogleAuthException('Se canceló la conexión con Google.');
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  late AppDatabase db;
  late Directory tmp;

  setUp(() async {
    db = await testDatabase();
    tmp = await Directory.systemTemp.createTemp('auto_sync');
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  ProviderContainer container(List<Override> extra) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(PhotoStore('${tmp.path}/docs')),
        tempDirProvider.overrideWithValue('${tmp.path}/cache'),
        ...extra,
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('la automática no abre la ventana de Google y deja el aviso', () async {
    final auth = _Auth();
    final c = container([
      googleAuthProvider.overrideWithValue(auth),
      httpClientProvider.overrideWithValue(MockClient((_) async => http.Response(jsonEncode({}), 500))),
    ]);
    final coordinator = c.read(syncCoordinatorProvider.notifier);

    expect(await coordinator.run(automatic: true), isNull, reason: 'en silencio, sin lanzar el error');
    expect(auth.asked, [false]);
    expect(c.read(syncCoordinatorProvider).problem, 'Toca «Sincronizar ahora».');
    expect(c.read(syncCoordinatorProvider).running, isFalse);

    // La manual sí puede abrir la ventana, y muestra el error.
    await expectLater(coordinator.run(), throwsA(isA<GoogleAuthException>()));
    expect(auth.asked, [false, true]);
    expect(c.read(promptPolicyProvider).allowPrompt, isTrue);
  });

  test('nunca corren dos sincronizaciones a la vez', () async {
    final drive = FakeDrive();
    final c = container([driveApiProvider.overrideWithValue(drive)]);
    final coordinator = c.read(syncCoordinatorProvider.notifier);

    final first = coordinator.run(automatic: true);
    expect(c.read(syncCoordinatorProvider).running, isTrue);
    expect(await coordinator.run(), isNull, reason: 'la segunda no empieza');
    expect(await first, isNotNull);
    expect(c.read(syncCoordinatorProvider).running, isFalse);
    expect(c.read(syncCoordinatorProvider).lastAuto, isNotNull);
    expect(drive.paths.where((p) => p.startsWith('/FramBitácora/datos/')), hasLength(1));
  });

  test('reglas: solo con Drive conectado, encendida y separadas al menos un minuto', () {
    const rules = AutoSyncRules();
    final now = DateTime(2026, 11, 24, 12);
    expect(rules.shouldRun(enabled: true, connected: true, now: now), isTrue);
    expect(rules.shouldRun(enabled: false, connected: true, now: now), isFalse);
    expect(rules.shouldRun(enabled: true, connected: false, now: now), isFalse);
    expect(
      rules.shouldRun(enabled: true, connected: true, now: now, last: now.subtract(const Duration(seconds: 30))),
      isFalse,
    );
    expect(
      rules.shouldRun(enabled: true, connected: true, now: now, last: now.subtract(const Duration(minutes: 2))),
      isTrue,
    );
  });

  test('sin preferencias (pruebas) viene apagada; con preferencias, encendida', () {
    final c = container([]);
    expect(c.read(autoSyncEnabledProvider), isFalse);
  });
}
