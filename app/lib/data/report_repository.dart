import 'package:drift/drift.dart';

import '../domain/photo_naming.dart';
import '../domain/project_kind.dart';
import '../domain/season_weeks.dart';
import '../reports/report_models.dart';
import 'database.dart';
import 'photo_source.dart';
import 'photo_store.dart';

/// Reduce una foto para el PDF (recibe la foto original, devuelve JPEG) o `null`
/// si no se puede leer.
typedef PhotoShrinker = Future<Uint8List?> Function(Uint8List original);

/// Reúne desde la base los datos de cada informe.
class ReportRepository {
  ReportRepository(this.db, PhotoStore photoStore, {PhotoSource? source})
    : source = source ?? FilePhotoSource(photoStore);
  final AppDatabase db;

  /// De dónde se leen las fotos (carpeta del teléfono o Drive en la web).
  final PhotoSource source;

  Future<ReportHeader> _header(Project project, Season season, List<Unit> units, DateTime now) async {
    final crop = await (db.select(db.crops)..where((c) => c.id.equals(project.cropId))).getSingle();
    final kind = ProjectKind.fromName(project.kind);
    final details = <String>[];
    if (kind == ProjectKind.treatmentTrial) {
      final treatments = await _treatments(project.id);
      final reps = project.replicates;
      if (treatments.isNotEmpty) {
        details.add(
          'Diseño: ${treatments.length} tratamientos'
          '${treatments.any((t) => t.isControl) ? ' (incluye testigo T0)' : ''}'
          '${reps == null ? '' : ' × $reps repeticiones'}',
        );
        for (final t in treatments) {
          details.add(
            '${t.code}: ${t.description.isEmpty ? (t.isControl ? 'Testigo' : 'Sin descripción') : t.description}',
          );
        }
      }
    }
    return ReportHeader(
      projectName: project.name,
      kindLabel: kind.label,
      cropName: crop.name,
      seasonName: season.name,
      unitCount: units.length,
      generatedAt: now,
      details: details,
    );
  }

  Future<List<Treatment>> _treatments(String projectId) =>
      (db.select(db.treatments)
            ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<List<Unit>> _units(String projectId) =>
      (db.select(db.units)
            ..where((u) => u.projectId.equals(projectId) & u.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm(expression: u.sortOrder), (u) => OrderingTerm(expression: u.label)]))
          .get();

  /// Descripción corta de cada unidad (dosis del tratamiento o variedad).
  Future<String Function(Unit)> _subtitles(Project project) async {
    final kind = ProjectKind.fromName(project.kind);
    final treatments = {for (final t in await _treatments(project.id)) t.code: t.description};
    final varieties = {for (final v in await db.select(db.varieties).get()) v.id: v.name};
    return (u) => switch (kind) {
      ProjectKind.varietyTrial => '',
      ProjectKind.treatmentTrial => treatments[u.treatment] ?? '',
      ProjectKind.farm => varieties[u.varietyId] ?? '',
    };
  }

  /// Estado de cada unidad en una semana: unidad → (estadio, id del registro, notas).
  Future<Map<String, ({ReportStage? stage, String observationId, String notes})>> _week(
    String seasonId,
    int week,
  ) async {
    final rows = await db
        .customSelect(
          '''
SELECT o.id, o.unit_id, o.notes, s.code, s.name, s.color, s.sort_order, m.name AS macro
FROM observations o
LEFT JOIN pheno_stages s ON s.id = o.stage_id
LEFT JOIN pheno_macros m ON m.scale_id = s.scale_id AND m.code = s.macro_code AND m.deleted_at IS NULL
WHERE o.season_id = ? AND o.week_number = ? AND o.deleted_at IS NULL''',
          variables: [Variable.withString(seasonId), Variable.withInt(week)],
        )
        .get();
    return {
      for (final r in rows)
        r.read<String>('unit_id'): (
          stage: r.readNullable<String>('code') == null
              ? null
              : ReportStage(
                  code: r.read<String>('code'),
                  name: r.read<String>('name'),
                  color: r.read<int>('color'),
                  sortOrder: r.read<int>('sort_order'),
                  macroName: r.readNullable<String>('macro') ?? '',
                ),
          observationId: r.read<String>('id'),
          notes: r.read<String>('notes'),
        ),
    };
  }

  Future<bool> _notSampled(String seasonId, int week) async {
    final w = await (db.select(
      db.weekStatuses,
    )..where((x) => x.seasonId.equals(seasonId) & x.weekNumber.equals(week) & x.deletedAt.isNull())).getSingleOrNull();
    return w?.notSampled ?? false;
  }

  /// Informe semanal: avance por unidad (semana anterior → esta semana) y fotos.
  Future<WeeklyReport> weekly({
    required String projectId,
    required String seasonId,
    required int week,
    required PhotoShrinker shrink,
    bool includePhotos = true,
    int maxPhotosPerKind = 1,
    DateTime? now,
  }) async {
    final project = await (db.select(db.projects)..where((p) => p.id.equals(projectId))).getSingle();
    final season = await (db.select(db.seasons)..where((s) => s.id.equals(seasonId))).getSingle();
    final units = await _units(projectId);
    final subtitle = await _subtitles(project);
    final codes = {for (final v in await db.select(db.varieties).get()) v.id: v.code.trim()};
    final current = await _week(seasonId, week);
    final previous = week > 1 ? await _week(seasonId, week - 1) : const <String, Never>{};

    final rows = <WeeklyUnitRow>[];
    for (final u in units) {
      final obs = current[u.id];
      final photos = obs == null
          ? <Photo>[]
          : await (db.select(db.photos)
                  ..where((p) => p.observationId.equals(obs.observationId) & p.deletedAt.isNull())
                  ..orderBy([(p) => OrderingTerm(expression: p.seq)]))
                .get();
      Future<List<Uint8List>> pick(PhotoKind kind) async {
        if (!includePhotos) return const [];
        final out = <Uint8List>[];
        for (final p in photos.where((p) => p.kind == kind.name).take(maxPhotosPerKind)) {
          final original = await source.bytes(p);
          final bytes = original == null ? null : await shrink(original);
          if (bytes != null) out.add(bytes);
        }
        return out;
      }

      rows.add(
        WeeklyUnitRow(
          label: u.label,
          subtitle: subtitle(u),
          code: codes[u.varietyId] ?? '',
          stage: obs?.stage,
          previous: previous[u.id]?.stage,
          photoCount: photos.length,
          notes: obs?.notes.trim() ?? '',
          general: await pick(PhotoKind.general),
          detail: await pick(PhotoKind.detail),
        ),
      );
    }

    final start = seasonWeekStart(week, season.week1Start);
    return WeeklyReport(
      header: await _header(project, season, units, now ?? DateTime.now()),
      week: week,
      weekStart: start,
      isoWeek: isoWeek(start).week,
      notSampled: await _notSampled(seasonId, week),
      rows: rows,
    );
  }

  /// Matriz de la temporada: estado de cada unidad en cada semana.
  Future<MatrixReport> matrix({
    required String projectId,
    required String seasonId,
    required int currentWeek,
    DateTime? now,
  }) async {
    final project = await (db.select(db.projects)..where((p) => p.id.equals(projectId))).getSingle();
    final season = await (db.select(db.seasons)..where((s) => s.id.equals(seasonId))).getSingle();
    final kind = ProjectKind.fromName(project.kind);
    var units = await _units(projectId);
    final subtitle = await _subtitles(project);

    final obs = await db
        .customSelect(
          '''
SELECT o.unit_id, o.week_number, s.code, s.name, s.color, s.sort_order, m.name AS macro
FROM observations o JOIN pheno_stages s ON s.id = o.stage_id
LEFT JOIN pheno_macros m ON m.scale_id = s.scale_id AND m.code = s.macro_code AND m.deleted_at IS NULL
WHERE o.season_id = ? AND o.deleted_at IS NULL''',
          variables: [Variable.withString(seasonId)],
        )
        .get();
    final byUnit = <String, Map<int, ReportStage>>{};
    var lastWeek = 0;
    for (final r in obs) {
      final w = r.read<int>('week_number');
      if (w > lastWeek) lastWeek = w;
      byUnit.putIfAbsent(r.read<String>('unit_id'), () => {})[w] = ReportStage(
        code: r.read<String>('code'),
        name: r.read<String>('name'),
        color: r.read<int>('color'),
        sortOrder: r.read<int>('sort_order'),
        macroName: r.readNullable<String>('macro') ?? '',
      );
    }

    // En ensayos de tratamientos se agrupa por tratamiento para comparar repeticiones.
    if (kind == ProjectKind.treatmentTrial) {
      final order = {for (final (i, t) in (await _treatments(projectId)).indexed) t.code: i};
      units = [...units]
        ..sort((a, b) {
          final byTreatment = (order[a.treatment] ?? 999).compareTo(order[b.treatment] ?? 999);
          return byTreatment != 0 ? byTreatment : (a.replicate ?? 0).compareTo(b.replicate ?? 0);
        });
    }

    final weeks = matrixWeeks(currentWeek: currentWeek, lastWeekWithData: lastWeek == 0 ? null : lastWeek);
    final statuses = await (db.select(
      db.weekStatuses,
    )..where((w) => w.seasonId.equals(seasonId) & w.notSampled.equals(true) & w.deletedAt.isNull())).get();

    return MatrixReport(
      header: await _header(project, season, units, now ?? DateTime.now()),
      weeks: weeks,
      weekStarts: {for (final w in weeks) w: seasonWeekStart(w, season.week1Start)},
      notSampledWeeks: {for (final s in statuses) s.weekNumber},
      rows: [
        for (final u in units)
          MatrixRow(
            label: u.label,
            subtitle: subtitle(u),
            group: kind == ProjectKind.treatmentTrial ? u.treatment : null,
            stages: byUnit[u.id] ?? const {},
          ),
      ],
    );
  }
}
