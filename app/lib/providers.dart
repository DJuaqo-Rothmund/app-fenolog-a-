import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/backup_service.dart';
import 'data/catalog_repository.dart';
import 'data/database.dart';
import 'data/photo_store.dart';
import 'data/project_repository.dart';
import 'data/report_repository.dart';
import 'data/sampling_repository.dart';
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
  (ref) => ReportRepository(ref.watch(databaseProvider), ref.watch(photoStoreProvider)),
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

final weekNotSampledProvider = StreamProvider.family<bool, ({String seasonId, int week})>(
  (ref, k) => ref.watch(samplingRepositoryProvider).watchWeekNotSampled(k.seasonId, k.week),
);

final observationProvider = StreamProvider.family<Observation?, ({String seasonId, String unitId, int week})>(
  (ref, k) => ref.watch(samplingRepositoryProvider).watchObservation(k.seasonId, k.unitId, k.week),
);

final photosProvider = StreamProvider.family<List<Photo>, String>(
  (ref, observationId) => ref.watch(samplingRepositoryProvider).watchPhotos(observationId),
);
