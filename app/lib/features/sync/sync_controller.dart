import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_engine.dart';
import '../../providers.dart';

class SyncState {
  const SyncState({this.running = false, this.status, this.error, this.report, this.at});
  final bool running;
  final String? status;
  final String? error;
  final SyncReport? report;
  final DateTime? at;
}

/// Sincroniza al abrir la app, cada 10 minutos mientras está abierta y cuando
/// se pide. Nunca dos a la vez. Sin conexión solo deja el error a la vista:
/// el trabajo sigue guardado en el teléfono.
class SyncController extends Notifier<SyncState> {
  Timer? _timer;

  @override
  SyncState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SyncState();
  }

  /// Arranca la sincronización automática (si hay sesión).
  void start({Duration every = const Duration(minutes: 10)}) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => run(quiet: true));
    run(quiet: true);
  }

  Future<SyncReport?> run({bool quiet = false}) async {
    if (state.running) return null;
    final engine = ref.read(syncEngineProvider);
    if (await engine.session() == null) return null;
    state = SyncState(running: true, status: quiet ? null : 'Conectando…', report: state.report, at: state.at);
    try {
      final report = await engine.sync(
        onStatus: (s) => state = SyncState(running: true, status: s, report: state.report, at: state.at),
      );
      state = SyncState(report: report, at: DateTime.now());
      return report;
    } catch (e) {
      state = SyncState(error: '$e', report: state.report, at: state.at);
      return null;
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);
