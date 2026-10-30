import 'package:drift/drift.dart';

import '../domain/measurement.dart';
import 'database.dart';

/// Mediciones definidas por el usuario y sus valores.
class MeasurementRepository {
  MeasurementRepository(this.db);
  final AppDatabase db;

  Stream<List<MeasurementDef>> watchDefs(String projectId, {MeasurementScope? scope}) {
    final q = db.select(db.measurementDefs)
      ..where((d) => d.projectId.equals(projectId) & d.deletedAt.isNull())
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder), (d) => OrderingTerm(expression: d.name)]);
    if (scope != null) q.where((d) => d.scope.equals(scope.name));
    return q.watch();
  }

  Future<List<MeasurementDef>> defs(String projectId, {MeasurementScope? scope}) =>
      watchDefs(projectId, scope: scope).first;

  Future<String> createDef({
    required String projectId,
    required String name,
    required MeasurementKind kind,
    required MeasurementScope scope,
    String unit = '',
    double? minValue,
    double? maxValue,
    String choices = '',
  }) {
    return db.transaction(() async {
      final maxOrder = db.measurementDefs.sortOrder.max();
      final last =
          await (db.selectOnly(db.measurementDefs)
                ..addColumns([maxOrder])
                ..where(db.measurementDefs.projectId.equals(projectId)))
              .map((r) => r.read(maxOrder))
              .getSingle();
      final row = await db
          .into(db.measurementDefs)
          .insertReturning(
            MeasurementDefsCompanion.insert(
              projectId: projectId,
              name: name.trim(),
              kind: kind.name,
              scope: scope.name,
              unit: Value(unit.trim()),
              minValue: Value(minValue),
              maxValue: Value(maxValue),
              choices: Value(choices.trim()),
              sortOrder: Value((last ?? -1) + 1),
            ),
          );
      return row.id;
    });
  }

  Future<void> updateDef(
    String id, {
    required String name,
    required MeasurementKind kind,
    required String unit,
    double? minValue,
    double? maxValue,
    String choices = '',
  }) => (db.update(db.measurementDefs)..where((d) => d.id.equals(id))).write(
    MeasurementDefsCompanion(
      name: Value(name.trim()),
      kind: Value(kind.name),
      unit: Value(unit.trim()),
      minValue: Value(minValue),
      maxValue: Value(maxValue),
      choices: Value(choices.trim()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Borrado lógico: la medición deja de pedirse; los valores ya tomados se conservan.
  Future<void> deleteDef(String id) {
    final now = DateTime.now();
    return (db.update(
      db.measurementDefs,
    )..where((d) => d.id.equals(id))).write(MeasurementDefsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  /// Valores de un registro semanal, por id de medición.
  Stream<Map<String, MeasurementValue>> watchObservationValues(String observationId) =>
      (db.select(db.measurementValues)..where((v) => v.observationId.equals(observationId) & v.deletedAt.isNull()))
          .watch()
          .map((rows) => {for (final r in rows) r.defId: r});

  Future<void> setObservationValue(String observationId, String defId, MeasurementInput? value) => _upsert(
    (v) => v.observationId.equals(observationId) & v.defId.equals(defId),
    MeasurementValuesCompanion.insert(defId: defId, observationId: Value(observationId)),
    value,
  );

  /// Parámetros por variedad de una temporada.
  Stream<List<MeasurementValue>> watchVarietyValues(String seasonId) =>
      (db.select(db.measurementValues)..where((v) => v.seasonId.equals(seasonId) & v.deletedAt.isNull())).watch();

  Future<void> setVarietyValue({
    required String seasonId,
    required String varietyId,
    required String defId,
    required MeasurementInput? value,
  }) => _upsert(
    (v) => v.seasonId.equals(seasonId) & v.varietyId.equals(varietyId) & v.defId.equals(defId),
    MeasurementValuesCompanion.insert(defId: defId, seasonId: Value(seasonId), varietyId: Value(varietyId)),
    value,
  );

  /// Crea, actualiza o borra (si [value] es nulo) el valor que cumple [match].
  Future<void> _upsert(
    Expression<bool> Function($MeasurementValuesTable v) match,
    MeasurementValuesCompanion insert,
    MeasurementInput? value,
  ) {
    return db.transaction(() async {
      final now = DateTime.now();
      final existing = await (db.select(
        db.measurementValues,
      )..where((v) => match(v) & v.deletedAt.isNull())).getSingleOrNull();
      if (value == null) {
        if (existing != null) {
          await (db.update(db.measurementValues)..where((v) => v.id.equals(existing.id))).write(
            MeasurementValuesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
        }
        return;
      }
      final fields = MeasurementValuesCompanion(
        valueNum: Value(value.number),
        valueText: Value(value.text),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await db
            .into(db.measurementValues)
            .insert(insert.copyWith(valueNum: fields.valueNum, valueText: fields.valueText));
      } else {
        await (db.update(db.measurementValues)..where((v) => v.id.equals(existing.id))).write(fields);
      }
    });
  }
}
