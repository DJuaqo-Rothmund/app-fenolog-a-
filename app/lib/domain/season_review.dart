/// Revisión de la temporada: estado de cada unidad en cada semana y alertas de
/// posibles errores de registro, para corregirlos antes de hacer un informe.
library;

class GridCell {
  const GridCell({
    required this.observationId,
    this.stageCode,
    this.stageName,
    this.stageColor,
    this.stageOrder,
    this.photoCount = 0,
  });
  final String observationId;
  final String? stageCode;
  final String? stageName;
  final int? stageColor;

  /// Posición del estadio en la escala (sirve para saber si «retrocedió»).
  final int? stageOrder;
  final int photoCount;

  bool get hasStage => stageCode != null;
}

enum AlertKind {
  /// El estado es anterior al de la última semana registrada de la misma unidad.
  regression('Retrocede'),

  /// Tiene estado pero ninguna foto.
  noPhoto('Sin foto'),

  /// Tiene fotos o notas pero no se eligió el estado.
  noStage('Sin estado');

  const AlertKind(this.label);
  final String label;
}

class GridAlert {
  const GridAlert({required this.unitId, required this.week, required this.kind, required this.message});
  final String unitId;
  final int week;
  final AlertKind kind;
  final String message;
}

/// Busca posibles errores. [cells] es unidad → semana → celda; [labels] el
/// nombre de cada unidad para el mensaje. Las semanas no muestreadas se omiten.
List<GridAlert> findAlerts(
  Map<String, Map<int, GridCell>> cells,
  Map<String, String> labels, {
  Set<int> notSampled = const {},
}) {
  final alerts = <GridAlert>[];
  for (final MapEntry(key: unit, value: weeks) in cells.entries) {
    final name = labels[unit] ?? '';
    GridCell? last;
    int? lastWeek;
    for (final w in weeks.keys.toList()..sort()) {
      if (notSampled.contains(w)) continue;
      final c = weeks[w]!;
      if (!c.hasStage && c.photoCount > 0) {
        alerts.add(
          GridAlert(unitId: unit, week: w, kind: AlertKind.noStage, message: '$name · S$w: tiene fotos pero no estado'),
        );
      }
      if (c.hasStage && c.photoCount == 0) {
        alerts.add(
          GridAlert(
            unitId: unit,
            week: w,
            kind: AlertKind.noPhoto,
            message: '$name · S$w: estado ${c.stageCode} sin foto',
          ),
        );
      }
      if (c.hasStage && c.stageOrder != null) {
        if (last != null && last.stageOrder! > c.stageOrder!) {
          alerts.add(
            GridAlert(
              unitId: unit,
              week: w,
              kind: AlertKind.regression,
              message: '$name · S$w: el estado ${c.stageCode} es anterior al de S$lastWeek (${last.stageCode})',
            ),
          );
        }
        last = c;
        lastWeek = w;
      }
    }
  }
  alerts.sort((a, b) => a.week != b.week ? a.week.compareTo(b.week) : a.message.compareTo(b.message));
  return alerts;
}
