import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'photo_store.dart';

part 'database.g.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

/// Columnas comunes a todas las tablas, pensadas para sincronizar más adelante:
/// identificador creado en el teléfono, marcas de tiempo y borrado lógico.
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Crops extends Table with SyncColumns {
  TextColumn get code => text().unique()();
  TextColumn get shortCode => text()();
  TextColumn get name => text()();
  TextColumn get scientificName => text().withDefault(const Constant(''))();
  IntColumn get seasonStartMonth => integer()();
  IntColumn get seasonStartDay => integer()();
}

class PhenoScales extends Table with SyncColumns {
  TextColumn get cropId => text().references(Crops, #id)();
  TextColumn get name => text()();
  IntColumn get version => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class PhenoMacros extends Table with SyncColumns {
  TextColumn get scaleId => text().references(PhenoScales, #id)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
}

class PhenoStages extends Table with SyncColumns {
  TextColumn get scaleId => text().references(PhenoScales, #id)();
  TextColumn get code => text()();
  TextColumn get macroCode => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get color => integer()();
}

class Varieties extends Table with SyncColumns {
  TextColumn get cropId => text().references(Crops, #id)();
  TextColumn get name => text()();
  TextColumn get code => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

class Projects extends Table with SyncColumns {
  TextColumn get cropId => text().references(Crops, #id)();
  TextColumn get scaleId => text().references(PhenoScales, #id)();

  /// Nombre de [ProjectKind].
  TextColumn get kind => text()();
  TextColumn get name => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Ensayo de tratamientos: cantidad de repeticiones (bloques).
  IntColumn get replicates => integer().nullable()();
}

/// Tratamientos de un ensayo de tratamientos (T0 = testigo, T1, T2…), con su
/// descripción (producto, dosis…). Las unidades guardan el código en `treatment`.
class Treatments extends Table with SyncColumns {
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get code => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isControl => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Seasons extends Table with SyncColumns {
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get name => text()();
  DateTimeColumn get week1Start => dateTime()();
}

class Units extends Table with SyncColumns {
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get varietyId => text().nullable().references(Varieties, #id)();
  TextColumn get label => text()();
  TextColumn get treatment => text().nullable()();
  IntColumn get replicate => integer().nullable()();
  TextColumn get irrigationGroup => text().nullable()();
  TextColumn get sector => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('WeekStatus')
class WeekStatuses extends Table with SyncColumns {
  TextColumn get seasonId => text().references(Seasons, #id)();
  IntColumn get weekNumber => integer()();
  BoolColumn get notSampled => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {seasonId, weekNumber},
  ];
}

class Observations extends Table with SyncColumns {
  TextColumn get seasonId => text().references(Seasons, #id)();
  TextColumn get unitId => text().references(Units, #id)();
  IntColumn get weekNumber => integer()();
  TextColumn get stageId => text().nullable().references(PhenoStages, #id)();

  /// `manual` por ahora; más adelante `ai_accepted` / `ai_corrected`.
  TextColumn get stageSource => text().withDefault(const Constant('manual'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  RealColumn get accuracyM => real().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {seasonId, unitId, weekNumber},
  ];
}

class Photos extends Table with SyncColumns {
  TextColumn get observationId => text().references(Observations, #id)();

  /// Nombre de [PhotoKind].
  TextColumn get kind => text()();
  IntColumn get seq => integer()();
  TextColumn get fileName => text()();

  /// Ruta relativa a la carpeta de la app (`fotos/<temporada>/<archivo>`).
  /// Ver [PhotoStore.file] para obtener el archivo.
  TextColumn get localPath => text()();
  DateTimeColumn get takenAt => dateTime()();

  /// `pending` hasta que exista la nube (etapa 4).
  TextColumn get uploadStatus => text().withDefault(const Constant('pending'))();
}

@DriftDatabase(
  tables: [
    Crops,
    PhenoScales,
    PhenoMacros,
    PhenoStages,
    Varieties,
    Projects,
    Treatments,
    Seasons,
    Units,
    WeekStatuses,
    Observations,
    Photos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  static QueryExecutor _openDefault() => driftDatabase(name: 'frambitacora');

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Las migraciones usan SQL directo (no las clases de tabla) para que sigan
      // siendo válidas cuando el esquema cambie en versiones futuras.
      if (from < 2) await _photoPathsToRelative();
      if (from < 3) await _addTreatments();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Versión 2: las fotos guardan su ruta relativa a la carpeta de la app.
  Future<void> _photoPathsToRelative() async {
    final rows = await customSelect('SELECT id, local_path FROM photos').get();
    for (final r in rows) {
      final old = r.read<String>('local_path');
      final rel = relativePhotoPath(old);
      if (rel != old) {
        await customUpdate(
          'UPDATE photos SET local_path = ? WHERE id = ?',
          variables: [Variable.withString(rel), Variable.withString(r.read<String>('id'))],
        );
      }
    }
  }

  /// Versión 3: tabla de tratamientos y repeticiones del ensayo. Los ensayos de
  /// tratamientos que ya existían reciben sus tratamientos desde sus unidades.
  Future<void> _addTreatments() async {
    await customStatement('''
CREATE TABLE IF NOT EXISTS "treatments" (
  "id" TEXT NOT NULL,
  "created_at" TEXT NOT NULL,
  "updated_at" TEXT NOT NULL,
  "deleted_at" TEXT NULL,
  "project_id" TEXT NOT NULL REFERENCES projects (id),
  "code" TEXT NOT NULL,
  "description" TEXT NOT NULL DEFAULT '',
  "is_control" INTEGER NOT NULL DEFAULT 0 CHECK ("is_control" IN (0, 1)),
  "sort_order" INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
)''');
    final cols = await customSelect('PRAGMA table_info(projects)').get();
    if (!cols.any((c) => c.read<String>('name') == 'replicates')) {
      await customStatement('ALTER TABLE projects ADD COLUMN "replicates" INTEGER NULL');
    }

    final now = DateTime.now().toIso8601String();
    final projects = await customSelect("SELECT id FROM projects WHERE kind = 'treatmentTrial'").get();
    for (final p in projects) {
      final projectId = p.read<String>('id');
      final codes = await customSelect(
        '''
SELECT treatment, MIN(sort_order) AS first FROM units
WHERE project_id = ? AND deleted_at IS NULL AND treatment IS NOT NULL
GROUP BY treatment ORDER BY first''',
        variables: [Variable.withString(projectId)],
      ).get();
      var order = 0;
      for (final c in codes) {
        final code = c.read<String>('treatment');
        await customStatement(
          'INSERT INTO treatments (id, created_at, updated_at, project_id, code, is_control, sort_order) '
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
          [newId(), now, now, projectId, code, isControlCode(code) ? 1 : 0, order++],
        );
      }
      await customStatement(
        'UPDATE projects SET replicates = (SELECT MAX(replicate) FROM units WHERE project_id = ?1 AND deleted_at IS NULL) '
        'WHERE id = ?1',
        [projectId],
      );
    }
  }
}

/// `T0` o un nombre que diga «testigo» se considera el testigo del ensayo.
bool isControlCode(String code) {
  final c = code.trim().toLowerCase();
  return c == 't0' || c.contains('testigo');
}
