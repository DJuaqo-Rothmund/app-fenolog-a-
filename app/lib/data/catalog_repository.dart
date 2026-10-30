import 'package:drift/drift.dart';

import 'database.dart';

/// Cultivos, escalas fenológicas y variedades.
class CatalogRepository {
  CatalogRepository(this.db);
  final AppDatabase db;

  Stream<List<Crop>> watchCrops() =>
      (db.select(db.crops)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm(expression: c.name)]))
          .watch();

  Future<Crop> getCrop(String id) => (db.select(db.crops)..where((c) => c.id.equals(id))).getSingle();

  Future<PhenoScale> defaultScale(String cropId) async {
    final scales =
        await (db.select(db.phenoScales)
              ..where((s) => s.cropId.equals(cropId) & s.deletedAt.isNull())
              ..orderBy([(s) => OrderingTerm(expression: s.isDefault, mode: OrderingMode.desc)]))
            .get();
    return scales.first;
  }

  Stream<List<PhenoMacro>> watchMacros(String scaleId) =>
      (db.select(db.phenoMacros)
            ..where((m) => m.scaleId.equals(scaleId) & m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm(expression: m.sortOrder)]))
          .watch();

  Stream<List<PhenoStage>> watchStages(String scaleId) =>
      (db.select(db.phenoStages)
            ..where((s) => s.scaleId.equals(scaleId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
          .watch();

  Stream<List<Variety>> watchVarieties(String cropId, {bool includeArchived = false}) {
    final q = db.select(db.varieties)
      ..where((v) => v.cropId.equals(cropId) & v.deletedAt.isNull())
      ..orderBy([(v) => OrderingTerm(expression: v.archived), (v) => OrderingTerm(expression: v.name)]);
    if (!includeArchived) q.where((v) => v.archived.equals(false));
    return q.watch();
  }

  Future<String> createVariety({
    required String cropId,
    required String name,
    String code = '',
    String notes = '',
  }) async {
    final row = await db
        .into(db.varieties)
        .insertReturning(
          VarietiesCompanion.insert(
            cropId: cropId,
            name: name.trim(),
            code: Value(code.trim()),
            notes: Value(notes.trim()),
          ),
        );
    return row.id;
  }

  Future<void> updateVariety(String id, {required String name, required String code, required String notes}) =>
      (db.update(db.varieties)..where((v) => v.id.equals(id))).write(
        VarietiesCompanion(
          name: Value(name.trim()),
          code: Value(code.trim()),
          notes: Value(notes.trim()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setVarietyArchived(String id, bool archived) => (db.update(db.varieties)..where((v) => v.id.equals(id)))
      .write(VarietiesCompanion(archived: Value(archived), updatedAt: Value(DateTime.now())));
}
