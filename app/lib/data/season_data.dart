import 'package:drift/drift.dart';

import '../domain/completeness.dart';
import '../domain/measurement.dart';
import '../domain/season_weeks.dart';
import 'database.dart';

/// Un registro semanal con todo lo necesario para exportar o informar.
class ObservationRecord {
  const ObservationRecord({
    required this.observation,
    required this.unit,
    required this.stage,
    required this.photos,
    required this.values,
  });
  final Observation observation;
  final Unit unit;
  final PhenoStage? stage;
  final List<Photo> photos;

  /// Valores de mediciones semanales, por id de medición.
  final Map<String, MeasurementValue> values;

  int get week => observation.weekNumber;
  bool get isComplete => isObservationComplete(hasStage: stage != null, photoCount: photos.length);
}

/// Todos los datos de una temporada de un proyecto.
class SeasonData {
  const SeasonData({
    required this.project,
    required this.crop,
    required this.season,
    required this.units,
    required this.varieties,
    required this.stages,
    required this.observationDefs,
    required this.varietyDefs,
    required this.records,
    required this.varietyValues,
    required this.notSampledWeeks,
  });
  final Project project;
  final Crop crop;
  final Season season;

  /// Unidades vigentes, en su orden.
  final List<Unit> units;
  final Map<String, Variety> varieties;

  /// Estadios de la escala del proyecto, en orden fenológico.
  final List<PhenoStage> stages;
  final List<MeasurementDef> observationDefs;
  final List<MeasurementDef> varietyDefs;

  /// Registros ordenados por semana y unidad.
  final List<ObservationRecord> records;
  final List<MeasurementValue> varietyValues;
  final Set<int> notSampledWeeks;

  /// Semanas con al menos un registro o marcadas como no muestreadas.
  List<int> get weeks => ({for (final r in records) r.week, ...notSampledWeeks}.toList()..sort());

  DateTime weekStart(int week) => seasonWeekStart(week, season.week1Start);

  String? varietyName(Unit u) => u.varietyId == null ? null : varieties[u.varietyId]?.name;

  /// Variedades usadas por las unidades, en el orden de las unidades.
  List<Variety> get usedVarieties {
    final seen = <String>{};
    return [
      for (final u in units)
        if (u.varietyId != null && seen.add(u.varietyId!) && varieties[u.varietyId] != null) varieties[u.varietyId]!,
    ];
  }

  ObservationRecord? record(String unitId, int week) =>
      records.where((r) => r.unit.id == unitId && r.week == week).firstOrNull;

  MeasurementValue? varietyValue(String varietyId, String defId) =>
      varietyValues.where((v) => v.varietyId == varietyId && v.defId == defId).firstOrNull;

  /// Texto de un valor de medición, o vacío.
  static String valueText(MeasurementValue? v) =>
      v == null ? '' : formatMeasurement(number: v.valueNum, text: v.valueText);
}

/// Carga [SeasonData] desde la base local.
Future<SeasonData> loadSeasonData(AppDatabase db, String seasonId) async {
  final season = await (db.select(db.seasons)..where((s) => s.id.equals(seasonId))).getSingle();
  final project = await (db.select(db.projects)..where((p) => p.id.equals(season.projectId))).getSingle();
  final crop = await (db.select(db.crops)..where((c) => c.id.equals(project.cropId))).getSingle();

  final allUnits =
      await (db.select(db.units)
            ..where((u) => u.projectId.equals(project.id))
            ..orderBy([(u) => OrderingTerm(expression: u.sortOrder), (u) => OrderingTerm(expression: u.label)]))
          .get();
  final unitById = {for (final u in allUnits) u.id: u};

  final varieties = await (db.select(db.varieties)..where((v) => v.cropId.equals(crop.id))).get();
  final stages =
      await (db.select(db.phenoStages)
            ..where((s) => s.scaleId.equals(project.scaleId))
            ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
          .get();
  final stageById = {for (final s in stages) s.id: s};

  final defs =
      await (db.select(db.measurementDefs)
            ..where((d) => d.projectId.equals(project.id) & d.deletedAt.isNull())
            ..orderBy([(d) => OrderingTerm(expression: d.sortOrder), (d) => OrderingTerm(expression: d.name)]))
          .get();

  final observations =
      await (db.select(db.observations)
            ..where((o) => o.seasonId.equals(seasonId) & o.deletedAt.isNull())
            ..orderBy([(o) => OrderingTerm(expression: o.weekNumber)]))
          .get();
  final obsIds = [for (final o in observations) o.id];

  final photos =
      await (db.select(db.photos)
            ..where((p) => p.observationId.isIn(obsIds) & p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm(expression: p.kind), (p) => OrderingTerm(expression: p.seq)]))
          .get();
  final obsValues = await (db.select(
    db.measurementValues,
  )..where((v) => v.observationId.isIn(obsIds) & v.deletedAt.isNull())).get();
  final varietyValues = await (db.select(
    db.measurementValues,
  )..where((v) => v.seasonId.equals(seasonId) & v.deletedAt.isNull())).get();
  final notSampled = await (db.select(
    db.weekStatuses,
  )..where((w) => w.seasonId.equals(seasonId) & w.notSampled.equals(true) & w.deletedAt.isNull())).get();

  final unitOrder = {for (final (i, u) in allUnits.indexed) u.id: i};
  final records = [
    for (final o in observations)
      if (unitById[o.unitId] case final unit? when unit.deletedAt == null)
        ObservationRecord(
          observation: o,
          unit: unit,
          stage: o.stageId == null ? null : stageById[o.stageId],
          photos: [
            for (final p in photos)
              if (p.observationId == o.id) p,
          ],
          values: {
            for (final v in obsValues)
              if (v.observationId == o.id) v.defId: v,
          },
        ),
  ]..sort((a, b) => a.week != b.week ? a.week - b.week : unitOrder[a.unit.id]! - unitOrder[b.unit.id]!);

  return SeasonData(
    project: project,
    crop: crop,
    season: season,
    units: [
      for (final u in allUnits)
        if (u.deletedAt == null) u,
    ],
    varieties: {for (final v in varieties) v.id: v},
    stages: stages,
    observationDefs: [
      for (final d in defs)
        if (d.scope == MeasurementScope.observation.name) d,
    ],
    varietyDefs: [
      for (final d in defs)
        if (d.scope == MeasurementScope.varietySeason.name) d,
    ],
    records: records,
    varietyValues: varietyValues,
    notSampledWeeks: {for (final w in notSampled) w.weekNumber},
  );
}
