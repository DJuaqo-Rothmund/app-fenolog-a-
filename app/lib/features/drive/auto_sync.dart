import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drive/drive_sync.dart';
import '../../providers.dart';
import 'google_auth.dart';

/// Estado de la sincronización (manual o automática).
class SyncStatus {
  const SyncStatus({this.running = false, this.problem, this.lastAuto});

  /// Hay una sincronización en curso.
  final bool running;

  /// Último problema de la sincronización automática (p. ej. hay que volver a
  /// conectar con Google). `null` si la última salió bien.
  final String? problem;

  /// Cuándo terminó la última sincronización automática.
  final DateTime? lastAuto;

  SyncStatus copyWith({bool? running, String? problem, bool clearProblem = false, DateTime? lastAuto}) => SyncStatus(
    running: running ?? this.running,
    problem: clearProblem ? null : problem ?? this.problem,
    lastAuto: lastAuto ?? this.lastAuto,
  );
}

/// Ordena las sincronizaciones: nunca corren dos a la vez, y la automática no
/// abre ventanas de Google ni muestra errores (los deja en [SyncStatus.problem]).
class SyncCoordinator extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();

  /// Sincroniza. Con [automatic], en silencio: devuelve `null` si no se pudo
  /// (sin internet, sesión de Google vencida…) en vez de lanzar el error.
  /// Si ya hay una en curso, no empieza otra y devuelve `null`.
  Future<DriveSyncResult?> run({
    bool automatic = false,
    bool includeBackup = false,
    void Function(String step, int done, int total)? progress,
  }) async {
    if (state.running) return null;
    state = state.copyWith(running: true);
    final policy = ref.read(promptPolicyProvider);
    policy.allowPrompt = !automatic;
    try {
      final r = await ref.read(driveSyncProvider).sync(includeBackup: includeBackup, progress: progress);
      final now = DateTime.now();
      await ref.read(driveAccountProvider.notifier).markSynced(now);
      state = state.copyWith(running: false, clearProblem: true, lastAuto: automatic ? now : null);
      return r;
    } on GoogleAuthException catch (e) {
      state = state.copyWith(running: false, problem: e.needsUser ? e.message : null);
      if (!automatic) rethrow;
      return null;
    } catch (_) {
      // Sin internet u otro problema pasajero: se reintenta en la próxima vuelta.
      state = state.copyWith(running: false);
      if (!automatic) rethrow;
      return null;
    } finally {
      policy.allowPrompt = true;
    }
  }
}

final syncCoordinatorProvider = NotifierProvider<SyncCoordinator, SyncStatus>(SyncCoordinator.new);

/// Si la sincronización automática está encendida (Configuración → Google Drive).
/// Encendida por defecto en la app; apagada en las pruebas (sin preferencias).
class AutoSyncEnabledNotifier extends Notifier<bool> {
  static const _key = 'sincronizacion_automatica';

  @override
  bool build() {
    final prefs = ref.watch(preferencesProvider);
    return prefs?.getBool(_key) ?? prefs != null;
  }

  Future<void> set(bool value) async {
    state = value;
    await ref.read(preferencesProvider)?.setBool(_key, value);
  }
}

final autoSyncEnabledProvider = NotifierProvider<AutoSyncEnabledNotifier, bool>(AutoSyncEnabledNotifier.new);

/// Cuándo conviene sincronizar solo (reglas puras, para poder probarlas).
class AutoSyncRules {
  const AutoSyncRules({
    this.every = const Duration(minutes: 10),
    this.afterChange = const Duration(minutes: 2),
    this.minGap = const Duration(minutes: 1),
  });

  /// Cada cuánto mientras la app está abierta.
  final Duration every;

  /// Cuánto esperar tras un cambio local (si hay más cambios, se espera de nuevo).
  final Duration afterChange;

  /// Separación mínima entre dos sincronizaciones automáticas.
  final Duration minGap;

  bool shouldRun({required bool enabled, required bool connected, required DateTime now, DateTime? last}) =>
      enabled && connected && (last == null || now.difference(last) >= minGap);
}

/// Envuelve la app y sincroniza sola: al abrir, al volver a la app, cada
/// [AutoSyncRules.every] y poco después de cada cambio local.
class AutoSyncWatcher extends ConsumerStatefulWidget {
  const AutoSyncWatcher({super.key, required this.child, this.rules = const AutoSyncRules()});
  final Widget child;
  final AutoSyncRules rules;

  @override
  ConsumerState<AutoSyncWatcher> createState() => _AutoSyncWatcherState();
}

class _AutoSyncWatcherState extends ConsumerState<AutoSyncWatcher> with WidgetsBindingObserver {
  Timer? _periodic, _debounce;
  StreamSubscription<Object?>? _changes;
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(autoSyncEnabledProvider)) _start();
    ref.listenManual(autoSyncEnabledProvider, (_, on) => on ? _start() : _stop());
  }

  void _start() {
    _stop();
    _periodic = Timer.periodic(widget.rules.every, (_) => _maybeSync());
    // Cambios en la base hechos aquí (no los que trae la propia sincronización).
    _changes = ref.read(databaseProvider).tableUpdates().listen((_) {
      if (ref.read(syncCoordinatorProvider).running) return;
      _debounce?.cancel();
      _debounce = Timer(widget.rules.afterChange, _maybeSync);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSync());
  }

  void _stop() {
    _periodic?.cancel();
    _debounce?.cancel();
    _changes?.cancel();
    _periodic = _debounce = null;
    _changes = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _maybeSync();
  }

  Future<void> _maybeSync() async {
    if (!mounted) return;
    final ok = widget.rules.shouldRun(
      enabled: ref.read(autoSyncEnabledProvider),
      connected: ref.read(driveAccountProvider) != null,
      now: DateTime.now(),
      last: _last,
    );
    if (!ok) return;
    _last = DateTime.now();
    await ref.read(syncCoordinatorProvider.notifier).run(automatic: true);
    // Lo que la sincronización acaba de escribir no cuenta como «cambio local».
    _debounce?.cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
