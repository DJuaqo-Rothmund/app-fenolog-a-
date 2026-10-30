import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
