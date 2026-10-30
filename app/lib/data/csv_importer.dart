import '../domain/csv_import.dart';
import '../domain/measurement.dart';
import 'database.dart';
import 'measurement_repository.dart';
import 'project_repository.dart';
import 'sampling_repository.dart';

class CsvImportSummary {
  const CsvImportSummary({
    required this.imported,
    required this.createdUnits,
    required this.errors,
    required this.ignoredColumns,
  });
  final int imported;
  final List<String> createdUnits;
  final List<String> errors;
  final List<String> ignoredColumns;
}

/// Carga registros de una planilla CSV en una temporada. Las unidades que no
/// existen se crean; los datos vacíos de la planilla no borran lo ya registrado.
class SeasonCsvImporter {
  SeasonCsvImporter(this.db, this.projects, this.sampling, this.measurements);
  final AppDatabase db;
  final ProjectRepository projects;
  final SamplingRepository sampling;
  final MeasurementRepository measurements;

  Future<CsvImportSummary> import(String seasonId, String csvText) async {
    final season = await (db.select(db.seasons)..where((s) => s.id.equals(seasonId))).getSingle();
    final project = await (db.select(db.projects)..where((p) => p.id.equals(season.projectId))).getSingle();
    final defs = await measurements.defs(project.id, scope: MeasurementScope.observation);
    final parsed = readSeasonCsv(
      csvText,
      measurementNames: [for (final d in defs) d.name],
      week1Start: season.week1Start,
    );
    final errors = [...parsed.errors];
    if (parsed.records.isEmpty) {
      return CsvImportSummary(
        imported: 0,
        createdUnits: const [],
        errors: errors,
        ignoredColumns: parsed.ignoredColumns,
      );
    }

    final stages = await (db.select(db.phenoStages)..where((s) => s.scaleId.equals(project.scaleId))).get();
    PhenoStage? findStage(String text) {
      final n = normalizeHeader(text);
      return stages.where((s) => s.code == text.trim()).firstOrNull ??
          stages.where((s) => normalizeHeader(s.name) == n).firstOrNull;
    }

    final units = {for (final u in await projects.watchUnits(project.id).first) normalizeHeader(u.label): u.id};
    final created = <String>[];
    var imported = 0;

    await db.transaction(() async {
      for (final r in parsed.records) {
        final stage = r.stageCode == null ? null : findStage(r.stageCode!);
        if (r.stageCode != null && stage == null) {
          errors.add('Fila ${r.line}: estadio «${r.stageCode}» no existe en la escala; se importa sin estadio.');
        }
        final key = normalizeHeader(r.unit);
        var unitId = units[key];
        if (unitId == null) {
          unitId = await projects.createUnit(projectId: project.id, label: r.unit);
          units[key] = unitId;
          created.add(r.unit);
        }
        final obs = await sampling.ensureObservation(seasonId, unitId, r.week);
        if (stage != null) await sampling.setStage(obs, stage.id);
        if (r.notes != null) await sampling.setNotes(obs, r.notes!);
        for (final MapEntry(key: name, value: raw) in r.measurements.entries) {
          final def = defs.firstWhere((d) => d.name == name);
          final value = parseMeasurement(
            raw,
            kind: MeasurementKind.fromName(def.kind),
            min: def.minValue,
            max: def.maxValue,
            choices: parseChoices(def.choices),
          );
          if (value.error != null) {
            errors.add('Fila ${r.line}: «$name» = «$raw»: ${value.error}.');
          } else {
            await measurements.setObservationValue(obs, def.id, value.value);
          }
        }
        imported++;
      }
    });
    return CsvImportSummary(
      imported: imported,
      createdUnits: created,
      errors: errors,
      ignoredColumns: parsed.ignoredColumns,
    );
  }
}
