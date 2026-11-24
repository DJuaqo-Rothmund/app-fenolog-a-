import 'dart:typed_data';

/// Datos de los informes, ya listos para dibujar. Son clases simples (sin base de
/// datos ni Flutter) para poder armar el PDF en otro isolate sin trabar la pantalla.

class ReportStage {
  const ReportStage({
    required this.code,
    required this.name,
    required this.color,
    this.sortOrder = 0,
    this.macroName = '',
  });
  final String code;
  final String name;

  /// Macroestadio al que pertenece (p. ej. «Floración»).
  final String macroName;

  /// Color ARGB del estadio, como en la escala.
  final int color;
  final int sortOrder;
}

/// Información general del ensayo que va en el encabezado.
class ReportHeader {
  const ReportHeader({
    required this.projectName,
    required this.kindLabel,
    required this.cropName,
    required this.seasonName,
    required this.unitCount,
    required this.generatedAt,
    this.details = const [],
  });
  final String projectName;
  final String kindLabel;
  final String cropName;
  final String seasonName;
  final int unitCount;
  final DateTime generatedAt;

  /// Líneas extra, p. ej. el diseño y los tratamientos con su descripción.
  final List<String> details;
}

class WeeklyUnitRow {
  const WeeklyUnitRow({
    required this.label,
    this.subtitle = '',
    this.code = '',
    this.stage,
    this.previous,
    this.photoCount = 0,
    this.notes = '',
    this.general = const [],
    this.detail = const [],
  });
  final String label;

  /// Descripción del tratamiento (dosis) o variedad, si corresponde.
  final String subtitle;

  /// Código corto de la variedad (p. ej. «C11»), si tiene.
  final String code;
  final ReportStage? stage;

  /// Estado de la semana anterior, para mostrar el avance.
  final ReportStage? previous;
  final int photoCount;
  final String notes;

  /// Fotos ya reducidas (JPEG).
  final List<Uint8List> general;
  final List<Uint8List> detail;

  bool get isComplete => stage != null && photoCount > 0;
}

class WeeklyReport {
  const WeeklyReport({
    required this.header,
    required this.week,
    required this.weekStart,
    required this.isoWeek,
    required this.rows,
    this.notSampled = false,
  });
  final ReportHeader header;
  final int week;
  final DateTime weekStart;
  final int isoWeek;
  final bool notSampled;
  final List<WeeklyUnitRow> rows;

  int get complete => rows.where((r) => r.isComplete).length;
}

class MatrixRow {
  const MatrixRow({required this.label, this.subtitle = '', this.group, this.stages = const {}});
  final String label;
  final String subtitle;

  /// Grupo para separar filas (p. ej. el tratamiento en un ensayo de tratamientos).
  final String? group;

  /// Estado por número de semana.
  final Map<int, ReportStage> stages;
}

class MatrixReport {
  const MatrixReport({
    required this.header,
    required this.weeks,
    required this.weekStarts,
    required this.rows,
    this.notSampledWeeks = const {},
  });
  final ReportHeader header;
  final List<int> weeks;
  final Map<int, DateTime> weekStarts;
  final Set<int> notSampledWeeks;
  final List<MatrixRow> rows;

  /// Estadios que aparecen en la matriz, en el orden de la escala (para la leyenda).
  List<ReportStage> get legend {
    final byCode = <String, ReportStage>{};
    for (final r in rows) {
      for (final s in r.stages.values) {
        byCode[s.code] = s;
      }
    }
    return byCode.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

/// Parte una lista de semanas en grupos que caben en una página.
List<List<int>> chunkWeeks(List<int> weeks, int perPage) => [
  for (var i = 0; i < weeks.length; i += perPage) weeks.sublist(i, (i + perPage).clamp(0, weeks.length)),
];

/// Semanas que muestra la matriz: desde la 1 hasta la actual o la última con datos.
List<int> matrixWeeks({required int currentWeek, int? lastWeekWithData}) {
  final last = [currentWeek, lastWeekWithData ?? 0].reduce((a, b) => a > b ? a : b).clamp(1, 1 << 20);
  return [for (var w = 1; w <= last; w++) w];
}
