import 'package:drift/drift.dart';

import '../domain/project_kind.dart';
import 'database.dart';

/// Proyectos (ensayos y predios), temporadas y unidades.
class ProjectRepository {
  ProjectRepository(this.db);
  final AppDatabase db;

  Stream<List<Project>> watchProjects() =>
      (db.select(db.projects)
            ..where((p) => p.deletedAt.isNull())
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

  Future<void> updateSeason(String id, {required String name, required DateTime week1Start}) =>
      (db.update(db.seasons)..where((s) => s.id.equals(id))).write(
        SeasonsCompanion(name: Value(name.trim()), week1Start: Value(week1Start), updatedAt: Value(DateTime.now())),
      );

  Stream<List<Unit>> watchUnits(String projectId) => _units(projectId).watch();

  SimpleSelectStatement<$UnitsTable, Unit> _units(String projectId) => (db.select(db.units)
    ..where((u) => u.projectId.equals(projectId) & u.deletedAt.isNull())
    ..orderBy([(u) => OrderingTerm(expression: u.sortOrder), (u) => OrderingTerm(expression: u.label)]));

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

  /// Ensayo de variedades: agrega una unidad por cada variedad que aún no esté
  /// en el proyecto. Devuelve cuántas se agregaron.
  Future<int> addVarietyUnits(String projectId, List<Variety> varieties) {
    return db.transaction(() async {
      final existing = (await _units(projectId).get()).map((u) => u.varietyId).toSet();
      var added = 0;
      for (final v in varieties) {
        if (existing.contains(v.id)) continue;
        await createUnit(
          projectId: projectId,
          label: unitLabel(kind: ProjectKind.varietyTrial, varietyName: v.name),
          varietyId: v.id,
        );
        existing.add(v.id);
        added++;
      }
      return added;
    });
  }

  /// Tratamientos del ensayo, del testigo al último.
  Stream<List<Treatment>> watchTreatments(String projectId) =>
      (db.select(db.treatments)
            ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Future<void> setTreatmentDescription(String id, String description) =>
      (db.update(db.treatments)..where((t) => t.id.equals(id))).write(
        TreatmentsCompanion(description: Value(description.trim()), updatedAt: Value(DateTime.now())),
      );

  /// Ensayo de tratamientos: deja el proyecto con [treatments] tratamientos
  /// (más el testigo T0 si [hasControl]) en [replicates] repeticiones.
  ///
  /// Crea los tratamientos y unidades que falten y quita (borrado lógico) los
  /// que sobren; los registros de las unidades quitadas se conservan. Las
  /// descripciones de los tratamientos que siguen se mantienen.
  Future<({int added, int removed})> configureTreatmentTrial(
    String projectId, {
    required int treatments,
    required int replicates,
    required bool hasControl,
  }) {
    return db.transaction(() async {
      final now = DateTime.now();
      final codes = treatmentCodes(treatments, hasControl: hasControl);

      // Tratamientos.
      final current = await (db.select(
        db.treatments,
      )..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())).get();
      final byCode = {for (final t in current) t.code: t};
      for (final (i, code) in codes.indexed) {
        final existing = byCode[code];
        if (existing == null) {
          await db
              .into(db.treatments)
              .insert(
                TreatmentsCompanion.insert(
                  projectId: projectId,
                  code: code,
                  isControl: Value(code == controlCode),
                  description: Value(code == controlCode ? 'Testigo' : ''),
                  sortOrder: Value(i),
                ),
              );
        } else {
          await (db.update(db.treatments)..where((t) => t.id.equals(existing.id))).write(
            TreatmentsCompanion(sortOrder: Value(i), updatedAt: Value(now)),
          );
        }
      }
      for (final t in current.where((t) => !codes.contains(t.code))) {
        await (db.update(
          db.treatments,
        )..where((x) => x.id.equals(t.id))).write(TreatmentsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      }

      // Unidades: una por tratamiento y repetición, en el orden del campo.
      final units = await _units(projectId).get();
      final grid = treatmentGrid(codes, replicates);
      final wanted = {for (final c in grid) (c.treatment, c.replicate)};
      var removed = 0;
      for (final u in units.where((u) => !wanted.contains((u.treatment, u.replicate)))) {
        await deleteUnit(u.id);
        removed++;
      }
      final kept = {for (final u in units) (u.treatment, u.replicate): u};
      var added = 0;
      for (final (i, cell) in grid.indexed) {
        final label = unitLabel(kind: ProjectKind.treatmentTrial, treatment: cell.treatment, replicate: cell.replicate);
        final unit = kept[(cell.treatment, cell.replicate)];
        if (unit == null) {
          await db
              .into(db.units)
              .insert(
                UnitsCompanion.insert(
                  projectId: projectId,
                  label: label,
                  treatment: Value(cell.treatment),
                  replicate: Value(cell.replicate),
                  sortOrder: Value(i),
                ),
              );
          added++;
        } else if (unit.sortOrder != i) {
          await (db.update(
            db.units,
          )..where((x) => x.id.equals(unit.id))).write(UnitsCompanion(sortOrder: Value(i), updatedAt: Value(now)));
        }
      }

      await (db.update(db.projects)..where((p) => p.id.equals(projectId))).write(
        ProjectsCompanion(replicates: Value(replicates), updatedAt: Value(now)),
      );
      return (added: added, removed: removed);
    });
  }
}
