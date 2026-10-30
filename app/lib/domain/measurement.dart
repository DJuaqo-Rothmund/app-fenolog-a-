/// Tipo de dato de una medición.
enum MeasurementKind {
  number('Número decimal'),
  integer('Número entero'),
  text('Texto'),
  choice('Opción de una lista');

  const MeasurementKind(this.label);
  final String label;

  bool get isNumeric => this == number || this == integer;

  static MeasurementKind fromName(String name) =>
      MeasurementKind.values.firstWhere((k) => k.name == name, orElse: () => MeasurementKind.number);
}

/// Cuándo se mide: cada semana en cada registro, o una vez por variedad y temporada.
enum MeasurementScope {
  observation('Cada semana, en cada registro'),
  varietySeason('Una vez por variedad y temporada');

  const MeasurementScope(this.label);
  final String label;

  static MeasurementScope fromName(String name) =>
      MeasurementScope.values.firstWhere((s) => s.name == name, orElse: () => MeasurementScope.observation);
}

/// Valor ya validado, listo para guardar.
typedef MeasurementInput = ({double? number, String? text});

/// Lista de opciones a partir del texto guardado (una por línea).
List<String> parseChoices(String raw) => [
  for (final line in raw.split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

/// Valida el texto escrito por la persona. Devuelve el valor a guardar o un
/// mensaje de error. Un texto vacío borra el valor.
({MeasurementInput? value, String? error}) parseMeasurement(
  String raw, {
  required MeasurementKind kind,
  double? min,
  double? max,
  List<String> choices = const [],
}) {
  final text = raw.trim();
  if (text.isEmpty) return (value: null, error: null);
  switch (kind) {
    case MeasurementKind.text:
      return (value: (number: null, text: text), error: null);
    case MeasurementKind.choice:
      if (choices.isNotEmpty && !choices.contains(text)) return (value: null, error: 'Elige una opción de la lista');
      return (value: (number: null, text: text), error: null);
    case MeasurementKind.number:
    case MeasurementKind.integer:
      final n = double.tryParse(text.replaceAll(',', '.'));
      if (n == null || n.isNaN || n.isInfinite) return (value: null, error: 'Debe ser un número');
      if (kind == MeasurementKind.integer && n != n.roundToDouble()) {
        return (value: null, error: 'Debe ser un número entero');
      }
      if (min != null && n < min) return (value: null, error: 'Mínimo ${formatNumber(min)}');
      if (max != null && n > max) return (value: null, error: 'Máximo ${formatNumber(max)}');
      return (value: (number: n, text: null), error: null);
  }
}

/// Número sin decimales innecesarios y con coma decimal: 12 → «12», 3.5 → «3,5».
String formatNumber(double n) {
  if (n == n.roundToDouble()) return n.toInt().toString();
  var s = n.toStringAsFixed(4);
  s = s.replaceFirst(RegExp(r'0+$'), '');
  return s.replaceAll('.', ',');
}

/// Texto para mostrar un valor guardado.
String formatMeasurement({double? number, String? text}) => number != null ? formatNumber(number) : (text ?? '');
