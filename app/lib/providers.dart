import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data/backup_service.dart';
import 'data/catalog_repository.dart';
import 'data/drive/data_sync.dart';
import 'data/drive/drive_client.dart';
import 'data/drive/drive_sync.dart';
import 'data/database.dart';
import 'data/photo_source.dart';
import 'data/photo_store.dart';
import 'data/project_repository.dart';
import 'data/report_repository.dart';
import 'data/sampling_repository.dart';
import 'features/drive/google_auth.dart';
import 'reports/pdf_reports.dart';
import 'reports/photo_shrink.dart';

/// Se reemplaza en `main.dart` (base real) y en las pruebas (base en memoria).
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider sin configurar'));

/// Se reemplaza en `main.dart` (carpeta de documentos) y en las pruebas.
final photoStoreProvider = Provider<PhotoStore>((ref) => throw UnimplementedError('photoStoreProvider sin configurar'));

/// Carpeta temporal donde se arman las copias; se reemplaza en `main.dart` y en las pruebas.
final tempDirProvider = Provider<String>((ref) => throw UnimplementedError('tempDirProvider sin configurar'));

final backupServiceProvider = Provider(
  (ref) => BackupService(
    db: ref.watch(databaseProvider),
    photoStore: ref.watch(photoStoreProvider),
    tempDir: ref.watch(tempDirProvider),
  ),
);

final catalogRepositoryProvider = Provider((ref) => CatalogRepository(ref.watch(databaseProvider)));
final projectRepositoryProvider = Provider((ref) => ProjectRepository(ref.watch(databaseProvider)));
final samplingRepositoryProvider = Provider(
  (ref) => SamplingRepository(ref.watch(databaseProvider), ref.watch(photoStoreProvider)),
);

final reportRepositoryProvider = Provider(
  (ref) => ReportRepository(
    ref.watch(databaseProvider),
    ref.watch(photoStoreProvider),
    source: ref.watch(photoSourceProvider),
  ),
);

/// Cómo se reducen las fotos para los informes (se reemplaza en las pruebas).
final photoShrinkerProvider = Provider<PhotoShrinker>((ref) => shrinkPhotoForReport);

/// Fuentes y logo de los informes PDF.
final reportAssetsProvider = FutureProvider<ReportAssets>(
  (ref) async => ReportAssets(
    regular: await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    bold: await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    logoSvg: await rootBundle.loadString('assets/brand/symbol.svg'),
  ),
);

/// Fecha de hoy; se reemplaza en las pruebas.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final cropsProvider = StreamProvider((ref) => ref.watch(catalogRepositoryProvider).watchCrops());

final cropProvider = FutureProvider.family<Crop, String>((ref, id) => ref.watch(catalogRepositoryProvider).getCrop(id));

final macrosProvider = StreamProvider.family<List<PhenoMacro>, String>(
  (ref, scaleId) => ref.watch(catalogRepositoryProvider).watchMacros(scaleId),
);

final stagesProvider = StreamProvider.family<List<PhenoStage>, String>(
  (ref, scaleId) => ref.watch(catalogRepositoryProvider).watchStages(scaleId),
);

final varietiesProvider = StreamProvider.family<List<Variety>, ({String cropId, bool includeArchived})>(
  (ref, a) => ref.watch(catalogRepositoryProvider).watchVarieties(a.cropId, includeArchived: a.includeArchived),
);

final projectsProvider = StreamProvider((ref) => ref.watch(projectRepositoryProvider).watchProjects());

final projectProvider = StreamProvider.family<Project, String>(
  (ref, id) => ref.watch(projectRepositoryProvider).watchProject(id),
);

final currentSeasonProvider = StreamProvider.family<Season?, String>(
  (ref, projectId) => ref.watch(projectRepositoryProvider).watchCurrentSeason(projectId),
);

final unitsProvider = StreamProvider.family<List<Unit>, String>(
  (ref, projectId) => ref.watch(projectRepositoryProvider).watchUnits(projectId),
);

final treatmentsProvider = StreamProvider.family<List<Treatment>, String>(
  (ref, projectId) => ref.watch(projectRepositoryProvider).watchTreatments(projectId),
);

typedef WeekKey = ({String projectId, String seasonId, int week});

final weekRowsProvider = StreamProvider.family<List<UnitWeekRow>, WeekKey>(
  (ref, k) =>
      ref.watch(samplingRepositoryProvider).watchWeek(projectId: k.projectId, seasonId: k.seasonId, week: k.week),
);

final seasonGridProvider = StreamProvider.family<SeasonGrid, ({String projectId, String seasonId})>(
  (ref, k) => ref.watch(samplingRepositoryProvider).watchSeasonGrid(projectId: k.projectId, seasonId: k.seasonId),
);

final weekNotSampledProvider = StreamProvider.family<bool, ({String seasonId, int week})>(
  (ref, k) => ref.watch(samplingRepositoryProvider).watchWeekNotSampled(k.seasonId, k.week),
);

final observationProvider = StreamProvider.family<Observation?, ({String seasonId, String unitId, int week})>(
  (ref, k) => ref.watch(samplingRepositoryProvider).watchObservation(k.seasonId, k.unitId, k.week),
);

final photosProvider = StreamProvider.family<List<Photo>, String>(
  (ref, observationId) => ref.watch(samplingRepositoryProvider).watchPhotos(observationId),
);

/// Preferencias guardadas en el teléfono. Se configura en `main.dart`; si falta
/// (pruebas), las preferencias funcionan pero no se guardan.
final preferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Tema elegido: claro, oscuro o según el teléfono (se recuerda al reabrir la app).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'tema';

  @override
  ThemeMode build() {
    final saved = ref.watch(preferencesProvider)?.getString(_key);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(preferencesProvider)?.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ---------------------------------------------------------------------------
// Google Drive

/// Inicio de sesión con Google (se reemplaza en las pruebas).
final googleAuthProvider = Provider<GoogleAuth>((ref) => GoogleSignInAuth());

/// Conexión a internet para Drive (se reemplaza en las pruebas).
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Si se puede abrir la ventana de Google (no durante la sincronización automática).
class PromptPolicy {
  bool allowPrompt = true;
}

final promptPolicyProvider = Provider((ref) => PromptPolicy());

final driveApiProvider = Provider<DriveApi>(
  (ref) => DriveClient(
    ref.watch(httpClientProvider),
    () => ref.read(googleAuthProvider).token(interactive: ref.read(promptPolicyProvider).allowPrompt),
  ),
);

/// Lo que este equipo recuerda de la sincronización (en memoria en las pruebas).
final syncStateStoreProvider = Provider<SyncStateStore>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return prefs == null ? MemorySyncStateStore() : PrefsSyncStateStore(prefs);
});

final dataSyncProvider = Provider(
  (ref) => DataSync(
    db: ref.watch(databaseProvider),
    drive: ref.watch(driveApiProvider),
    store: ref.watch(syncStateStoreProvider),
  ),
);

final driveSyncProvider = Provider(
  (ref) => DriveSync(
    db: ref.watch(databaseProvider),
    photoStore: ref.watch(photoStoreProvider),
    drive: ref.watch(driveApiProvider),
    backup: ref.watch(backupServiceProvider),
    data: ref.watch(dataSyncProvider),
  ),
);

/// De dónde se leen las fotos: la carpeta del teléfono o, en la web, Drive.
final photoSourceProvider = Provider<PhotoSource>(
  (ref) => kIsWeb ? DrivePhotoSource(ref.watch(driveApiProvider)) : FilePhotoSource(ref.watch(photoStoreProvider)),
);

/// Bytes de una foto (para mostrarla en la web).
final photoBytesProvider = FutureProvider.family<Uint8List?, Photo>(
  (ref, photo) => ref.watch(photoSourceProvider).bytes(photo),
);

/// Fotos que aún no están en Drive.
final drivePendingProvider = StreamProvider((ref) => ref.watch(driveSyncProvider).watchPending());

/// Cuenta de Google conectada para Drive.
class DriveAccount {
  const DriveAccount({required this.email, this.name = '', this.lastSync});
  final String email;
  final String name;
  final DateTime? lastSync;
}

class DriveAccountNotifier extends Notifier<DriveAccount?> {
  static const _email = 'drive_correo', _name = 'drive_nombre', _last = 'drive_ultima_sincronizacion';

  SharedPreferences? get _prefs => ref.read(preferencesProvider);

  @override
  DriveAccount? build() {
    final prefs = ref.watch(preferencesProvider);
    final email = prefs?.getString(_email);
    if (email == null) return null;
    return DriveAccount(
      email: email,
      name: prefs?.getString(_name) ?? '',
      lastSync: DateTime.tryParse(prefs?.getString(_last) ?? ''),
    );
  }

  /// Muestra el selector de cuentas y el permiso de Google, y guarda la cuenta.
  Future<void> connect() async {
    await ref.read(googleAuthProvider).token();
    final who = await ref.read(driveApiProvider).about();
    // Otra cuenta = otro Drive: todas las fotos y los datos vuelven a quedar por subir.
    if (state?.email != who.email) {
      await ref.read(driveSyncProvider).resetUploads();
      await ref.read(syncStateStoreProvider).reset();
    }
    await _prefs?.setString(_email, who.email);
    await _prefs?.setString(_name, who.name);
    await _prefs?.remove(_last);
    state = DriveAccount(email: who.email, name: who.name);
  }

  Future<void> changeAccount() async {
    await ref.read(googleAuthProvider).signOut();
    await connect();
  }

  Future<void> disconnect() async {
    await ref.read(googleAuthProvider).signOut();
    for (final k in [_email, _name, _last]) {
      await _prefs?.remove(k);
    }
    state = null;
  }

  Future<void> markSynced(DateTime at) async {
    final s = state;
    if (s == null) return;
    await _prefs?.setString(_last, at.toIso8601String());
    state = DriveAccount(email: s.email, name: s.name, lastSync: at);
  }
}

final driveAccountProvider = NotifierProvider<DriveAccountNotifier, DriveAccount?>(DriveAccountNotifier.new);
