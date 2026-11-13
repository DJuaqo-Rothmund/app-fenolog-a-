/// Tipos de proyecto. Todos comparten el mismo modelo: un proyecto tiene
/// unidades, y cada semana se registra una observación por unidad.
enum ProjectKind {
  varietyTrial('Ensayo de variedades', 'Cada unidad es una variedad'),
  treatmentTrial('Ensayo de tratamientos', 'Cada unidad es un tratamiento en una repetición'),
  farm('Predio', 'Cada unidad es un sector de un equipo de riego');

  const ProjectKind(this.label, this.help);
  final String label;
  final String help;

  static ProjectKind fromName(String name) =>
      ProjectKind.values.firstWhere((k) => k.name == name, orElse: () => ProjectKind.varietyTrial);
}

/// Etiqueta de una unidad según el tipo de proyecto.
String unitLabel({
  required ProjectKind kind,
  String? varietyName,
  String? treatment,
  int? replicate,
  String? irrigationGroup,
  String? sector,
}) {
  String t(String? s) => (s ?? '').trim();
  switch (kind) {
    case ProjectKind.varietyTrial:
      return t(varietyName).isEmpty ? 'Variedad sin nombre' : t(varietyName);
    case ProjectKind.treatmentTrial:
      final rep = replicate == null ? '' : ' R$replicate';
      return '${t(treatment).isEmpty ? 'T?' : t(treatment)}$rep';
    case ProjectKind.farm:
      return 'Equipo ${t(irrigationGroup).isEmpty ? '?' : t(irrigationGroup)}'
          ' · Sector ${t(sector).isEmpty ? '?' : t(sector)}';
  }
}

/// Código del testigo en los ensayos de tratamientos.
const controlCode = 'T0';

/// Códigos de los tratamientos: `T0` (si hay testigo) y luego `T1`…`Tn`.
List<String> treatmentCodes(int count, {required bool hasControl}) => [
  if (hasControl) controlCode,
  for (var i = 1; i <= count; i++) 'T$i',
];

/// Todas las combinaciones tratamiento × repetición, ordenadas por repetición
/// (bloque) y luego por tratamiento, como se recorren en el campo.
List<({String treatment, int replicate})> treatmentGrid(List<String> treatments, int replicates) => [
  for (var r = 1; r <= replicates; r++)
    for (final t in treatments) (treatment: t, replicate: r),
];
