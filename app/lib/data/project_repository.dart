import 'package:drift/drift.dart';

import '../domain/project_kind.dart';
import 'database.dart';

/// Proyectos (ensayos y predios), temporadas y unidades.
class ProjectRepository {
  ProjectRepository(this.db);
  final AppDatabase db;

  /// Proyectos vigentes; con [cropId], solo los de ese cultivo.
  Stream<List<Project>> watchProjects({String? cropId}) =>
      (db.select(db.projects)
            ..where((p) => p.deletedAt.isNull() & (cropId == null ? const Constant(true) : p.cropId.equals(cropId)))
            ..orderBy([(p) => OrderingTerm(expression: p.archived), (p) => OrderingTerm(expression: p.name)]))
          .watch();

  Stream<Project> watchProject(String id) => (db.select(db.projects)..where((p) => p.id.equals(id))).watchSingle();

  /// Crea el proyecto junto con su primera temporada.
  Future<String> createProject({
    required String cropId,
    required String scaleId,
    required ProjectKind kind,
    required String name,
    required String seasonName,
    required DateTime week1Start,
  }) {
    return db.transaction(() async {
      final project = await db
          .into(db.projects)
          .insertReturning(
            ProjectsCompanion.insert(cropId: cropId, scaleId: scaleId, kind: kind.name, name: name.trim()),
          );
      await db
          .into(db.seasons)
          .insert(SeasonsCompanion.insert(projectId: project.id, name: seasonName.trim(), week1Start: week1Start));
      return project.id;
    });
  }

  Future<void> renameProject(String id, String name) => (db.update(db.projects)..where((p) => p.id.equals(id))).write(
    ProjectsCompanion(name: Value(name.trim()), updatedAt: Value(DateTime.now())),
  );

  Future<void> setProjectArchived(String id, bool archived) => (db.update(db.projects)..where((p) => p.id.equals(id)))
      .write(ProjectsCompanion(archived: Value(archived), updatedAt: Value(DateTime.now())));

  /// Temporada más reciente del proyecto.
  Stream<Season?> watchCurrentSeason(String projectId) =>
      (db.select(db.seasons)
            ..where((s) => s.projectId.equals(projectId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm(expression: s.week1Start, mode: OrderingMode.desc)])
            ..limit(1))
          .watchSingleOrNull();

  /// Todas las temporadas del proyecto, la más reciente primero.
  Stream<List<Season>> watchSeasons(String projectId) =>
      (db.select(db.seasons)
            ..where((s) => s.projectId.equals(projectId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm(expression: s.week1Start, mode: OrderingMode.desc)]))
          .watch();

  Future<String> createSeason({required String projectId, required String name, required DateTime week1Start}) async {
    final row = await db
        .into(db.seasons)
        .insertReturning(SeasonsCompanion.insert(projectId: projectId, name: name.trim(), week1Start: week1Start));
    return row.id;
  }

  Future<void> updateSeason(String id, {required String name, required DateTime week1Start}) =>
      (db.update(db.seasons)..where((s) => s.id.equals(id))).write(
        SeasonsCompanion(name: Value(name.trim()), week1Start: Value(week1Start), updatedAt: Value(DateTime.now())),
      );

  Stream<List<Unit>> watchUnits(String projectId) =>
      (db.select(db.units)
            ..where((u) => u.projectId.equals(projectId) & u.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm(expression: u.sortOrder), (u) => OrderingTerm(expression: u.label)]))
          .watch();

  Future<String> createUnit({
    required String projectId,
    required String label,
    String? varietyId,
    String? treatment,
    int? replicate,
    String? irrigationGroup,
    String? sector,
  }) {
    return db.transaction(() async {
      final maxOrder = db.units.sortOrder.max();
      final last =
          await (db.selectOnly(db.units)
                ..addColumns([maxOrder])
                ..where(db.units.projectId.equals(projectId)))
              .map((r) => r.read(maxOrder))
              .getSingle();
      final row = await db
          .into(db.units)
          .insertReturning(
            UnitsCompanion.insert(
              projectId: projectId,
              label: label.trim(),
              varietyId: Value(varietyId),
              treatment: Value(treatment),
              replicate: Value(replicate),
              irrigationGroup: Value(irrigationGroup),
              sector: Value(sector),
              sortOrder: Value((last ?? -1) + 1),
            ),
          );
      return row.id;
    });
  }

  Future<void> updateUnit(
    String id, {
    required String label,
    String? varietyId,
    String? treatment,
    int? replicate,
    String? irrigationGroup,
    String? sector,
  }) => (db.update(db.units)..where((u) => u.id.equals(id))).write(
    UnitsCompanion(
      label: Value(label.trim()),
      varietyId: Value(varietyId),
      treatment: Value(treatment),
      replicate: Value(replicate),
      irrigationGroup: Value(irrigationGroup),
      sector: Value(sector),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Borrado lógico: la unidad deja de aparecer, pero sus registros se conservan.
  Future<void> deleteUnit(String id) {
    final now = DateTime.now();
    return (db.update(
      db.units,
    )..where((u) => u.id.equals(id))).write(UnitsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }
}
