import '../domain/measurement.dart';
import '../domain/project_kind.dart';
import '../domain/stats.dart';
import 'database.dart';
import 'season_data.dart';

/// Cómo se agrupan las unidades para comparar o dibujar curvas.
enum GroupBy {
  unit('Cada unidad'),
  variety('Variedad'),
  treatment('Tratamiento'),
  sector('Equipo de riego');

  const GroupBy(this.label);
  final String label;

  /// Agrupación natural según el tipo de proyecto.
  static GroupBy defaultFor(ProjectKind kind) => switch (kind) {
    ProjectKind.varietyTrial => GroupBy.variety,
    ProjectKind.treatmentTrial => GroupBy.treatment,
    ProjectKind.farm => GroupBy.sector,
  };
}

/// Un punto de la curva fenológica: semana y posición del estadio en la
/// escala (0 = primer estadio). En grupos es el promedio de sus unidades.
typedef CurvePoint = ({int week, double stageIndex});

class Curve {
  const Curve(this.name, this.points);
  final String name;
  final List<CurvePoint> points;
}

/// Análisis de una temporada a partir de [SeasonData].
extension SeasonAnalysis on SeasonData {
  /// Nombre del grupo de una unidad.
  String groupOf(Unit u, GroupBy by) => switch (by) {
    GroupBy.unit => u.label,
    GroupBy.variety => varietyName(u) ?? 'Sin variedad',
    GroupBy.treatment => (u.treatment ?? '').trim().isEmpty ? 'Sin tratamiento' : u.treatment!.trim(),
    GroupBy.sector => (u.irrigationGroup ?? '').trim().isEmpty ? 'Sin equipo' : 'Equipo ${u.irrigationGroup!.trim()}',
  };

  /// Bloque (repetición) de una unidad, solo en ensayos de tratamientos.
  String? blockOf(Unit u) => ProjectKind.fromName(project.kind) == ProjectKind.treatmentTrial && u.replicate != null
      ? 'R${u.replicate}'
      : null;

  int? stageIndex(PhenoStage? s) {
    if (s == null) return null;
    final i = stages.indexWhere((x) => x.id == s.id);
    return i < 0 ? null : i;
  }

  /// Curvas fenológicas (una por grupo), con las semanas que tienen estadio.
  List<Curve> curves(GroupBy by) {
    final byGroup = <String, Map<int, List<int>>>{};
    for (final u in units) {
      byGroup.putIfAbsent(groupOf(u, by), () => {});
    }
    for (final r in records) {
      final i = stageIndex(r.stage);
      if (i == null) continue;
      (byGroup[groupOf(r.unit, by)]![r.week] ??= []).add(i);
    }
    return [
      for (final MapEntry(key: name, value: weeks) in byGroup.entries)
        if (weeks.isNotEmpty)
          Curve(name, [
            for (final w in weeks.keys.toList()..sort())
              (week: w, stageIndex: weeks[w]!.reduce((a, b) => a + b) / weeks[w]!.length),
          ]),
    ];
  }

  /// Primera semana en que la unidad registró [stage] o uno posterior.
  int? weekReached(Unit u, PhenoStage stage) {
    final target = stageIndex(stage)!;
    for (final r in records.where((r) => r.unit.id == u.id)) {
      final i = stageIndex(r.stage);
      if (i != null && i >= target) return r.week;
    }
    return null;
  }

  /// Muestras para comparar una medición semanal numérica en [week].
  List<Sample> measurementSamples(MeasurementDef def, int week, GroupBy by) => [
    for (final r in records)
      if (r.week == week && r.values[def.id]?.valueNum != null)
        (group: groupOf(r.unit, by), block: blockOf(r.unit), value: r.values[def.id]!.valueNum!),
  ];

  /// Muestras del índice de estadio en [week].
  List<Sample> stageSamples(int week, GroupBy by) => [
    for (final r in records)
      if (r.week == week && stageIndex(r.stage) != null)
        (group: groupOf(r.unit, by), block: blockOf(r.unit), value: stageIndex(r.stage)!.toDouble()),
  ];

  /// Muestras de la semana en que cada unidad alcanzó [stage].
  List<Sample> weekReachedSamples(PhenoStage stage, GroupBy by) => [
    for (final u in units)
      if (weekReached(u, stage) case final w?) (group: groupOf(u, by), block: blockOf(u), value: w.toDouble()),
  ];

  /// Mediciones semanales numéricas (las únicas que se pueden promediar).
  List<MeasurementDef> get numericObservationDefs => [
    for (final d in observationDefs)
      if (MeasurementKind.fromName(d.kind).isNumeric) d,
  ];
}
