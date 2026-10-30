import 'package:drift/drift.dart';

import '../domain/completeness.dart';
import '../domain/photo_naming.dart';
import 'database.dart';
import 'photo_store.dart';

/// Una fila de la semana: la unidad y, si existe, su registro.
class UnitWeekRow {
  const UnitWeekRow({
    required this.unit,
    this.observationId,
    this.stageCode,
    this.stageName,
    this.stageColor,
    this.photoCount = 0,
  });
  final Unit unit;
  final String? observationId;
  final String? stageCode;
  final String? stageName;
  final int? stageColor;
  final int photoCount;

  bool get isComplete => isObservationComplete(hasStage: stageCode != null, photoCount: photoCount);
}

/// Registros semanales (unidad × semana), fotos y estado de cada semana.
class SamplingRepository {
  SamplingRepository(this.db, this.photoStore);
  final AppDatabase db;
  final PhotoStore photoStore;

  Stream<List<UnitWeekRow>> watchWeek({required String projectId, required String seasonId, required int week}) {
    return db
        .customSelect(
          '''
SELECT u.*, o.id AS obs_id, s.code AS stage_code, s.name AS stage_name, s.color AS stage_color,
  (SELECT COUNT(*) FROM photos p WHERE p.observation_id = o.id AND p.deleted_at IS NULL) AS photo_count
FROM units u
LEFT JOIN observations o
  ON o.unit_id = u.id AND o.season_id = ?1 AND o.week_number = ?2 AND o.deleted_at IS NULL
LEFT JOIN pheno_stages s ON s.id = o.stage_id
WHERE u.project_id = ?3 AND u.deleted_at IS NULL
ORDER BY u.sort_order, u.label
''',
          variables: [Variable.withString(seasonId), Variable.withInt(week), Variable.withString(projectId)],
          readsFrom: {db.units, db.observations, db.phenoStages, db.photos},
        )
        .watch()
        .asyncMap(
          (rows) async => [
            for (final r in rows)
              UnitWeekRow(
                unit: await db.units.mapFromRow(r),
                observationId: r.readNullable<String>('obs_id'),
                stageCode: r.readNullable<String>('stage_code'),
                stageName: r.readNullable<String>('stage_name'),
                stageColor: r.readNullable<int>('stage_color'),
                photoCount: r.read<int>('photo_count'),
              ),
          ],
        );
  }

  Stream<bool> watchWeekNotSampled(String seasonId, int week) =>
      (db.select(db.weekStatuses)
            ..where((w) => w.seasonId.equals(seasonId) & w.weekNumber.equals(week) & w.deletedAt.isNull()))
          .watchSingleOrNull()
          .map((w) => w?.notSampled ?? false);

  Future<void> setWeekNotSampled(String seasonId, int week, bool notSampled) {
    return db
        .into(db.weekStatuses)
        .insert(
          WeekStatusesCompanion.insert(seasonId: seasonId, weekNumber: week, notSampled: Value(notSampled)),
          onConflict: DoUpdate(
            (_) => WeekStatusesCompanion(notSampled: Value(notSampled), updatedAt: Value(DateTime.now())),
            target: [db.weekStatuses.seasonId, db.weekStatuses.weekNumber],
          ),
        );
  }

  Stream<Observation?> watchObservation(String seasonId, String unitId, int week) =>
      (db.select(db.observations)
            ..where((o) => o.seasonId.equals(seasonId) & o.unitId.equals(unitId) & o.weekNumber.equals(week)))
          .watchSingleOrNull();

  /// Devuelve el registro de la unidad en la semana, creándolo si no existe.
  Future<String> ensureObservation(String seasonId, String unitId, int week) {
    return db.transaction(() async {
      final existing =
          await (db.select(db.observations)
                ..where((o) => o.seasonId.equals(seasonId) & o.unitId.equals(unitId) & o.weekNumber.equals(week)))
              .getSingleOrNull();
      if (existing != null) return existing.id;
      final row = await db
          .into(db.observations)
          .insertReturning(ObservationsCompanion.insert(seasonId: seasonId, unitId: unitId, weekNumber: week));
      return row.id;
    });
  }

  Future<void> setStage(String observationId, String? stageId) => _updateObservation(
    observationId,
    ObservationsCompanion(stageId: Value(stageId), stageSource: const Value('manual')),
  );

  Future<void> setNotes(String observationId, String notes) =>
      _updateObservation(observationId, ObservationsCompanion(notes: Value(notes)));

  Future<void> setLocation(String observationId, {double? lat, double? lon, double? accuracyM}) => _updateObservation(
    observationId,
    ObservationsCompanion(lat: Value(lat), lon: Value(lon), accuracyM: Value(accuracyM)),
  );

  Future<void> _updateObservation(String id, ObservationsCompanion fields) => (db.update(
    db.observations,
  )..where((o) => o.id.equals(id))).write(fields.copyWith(updatedAt: Value(DateTime.now())));

  Stream<List<Photo>> watchPhotos(String observationId) =>
      (db.select(db.photos)
            ..where((p) => p.observationId.equals(observationId) & p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm(expression: p.kind), (p) => OrderingTerm(expression: p.seq)]))
          .watch();

  /// Copia la imagen [sourcePath] a la carpeta de la app con su nombre uniforme
  /// y la asocia al registro.
  Future<Photo> addPhoto({
    required String observationId,
    required PhotoKind kind,
    required String sourcePath,
    DateTime? takenAt,
  }) async {
    final date = takenAt ?? DateTime.now();
    final info = await db
        .customSelect(
          '''
SELECT c.short_code, u.label, o.season_id,
  (SELECT COALESCE(MAX(p.seq), 0) FROM photos p WHERE p.observation_id = o.id AND p.kind = ?2) AS max_seq
FROM observations o
JOIN units u ON u.id = o.unit_id
JOIN projects pr ON pr.id = u.project_id
JOIN crops c ON c.id = pr.crop_id
WHERE o.id = ?1
''',
          variables: [Variable.withString(observationId), Variable.withString(kind.name)],
        )
        .getSingle();

    final seq = info.read<int>('max_seq') + 1;
    final fileName = photoFileName(
      date: date,
      cropShortCode: info.read<String>('short_code'),
      unitLabel: info.read<String>('label'),
      kind: kind,
      seq: seq,
    );
    final localPath = await photoStore.save(
      sourcePath: sourcePath,
      folder: info.read<String>('season_id'),
      fileName: fileName,
    );
    return db
        .into(db.photos)
        .insertReturning(
          PhotosCompanion.insert(
            observationId: observationId,
            kind: kind.name,
            seq: seq,
            fileName: fileName,
            localPath: localPath,
            takenAt: date,
          ),
        );
  }

  Future<void> deletePhoto(Photo photo) async {
    final now = DateTime.now();
    await (db.update(
      db.photos,
    )..where((p) => p.id.equals(photo.id))).write(PhotosCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await photoStore.delete(photo.localPath);
  }
}
