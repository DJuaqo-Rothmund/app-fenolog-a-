/// Definición de un cultivo como datos (archivo JSON), para agregar cultivos
/// sin cambiar código. Ver `assets/crops/rubus-idaeus.json`.
library;

class CropDefinitionError implements Exception {
  CropDefinitionError(this.message);
  final String message;
  @override
  String toString() => 'Definición de cultivo inválida: $message';
}

class StageDef {
  const StageDef({
    required this.code,
    required this.macro,
    required this.name,
    required this.description,
    required this.color,
  });
  final String code;
  final String macro;
  final String name;
  final String description;

  /// Color ARGB (p. ej. 0xFF6D4C41).
  final int color;
}

class MacroDef {
  const MacroDef({required this.code, required this.name});
  final String code;
  final String name;
}

class ScaleDef {
  const ScaleDef({
    required this.name,
    required this.version,
    required this.isDefault,
    required this.macros,
    required this.stages,
  });
  final String name;
  final int version;
  final bool isDefault;
  final List<MacroDef> macros;

  /// En orden fenológico: el índice es el orden de avance.
  final List<StageDef> stages;
}

class CropDefinition {
  const CropDefinition({
    required this.code,
    required this.shortCode,
    required this.name,
    required this.scientificName,
    required this.seasonStartMonth,
    required this.seasonStartDay,
    required this.scales,
  });
  final String code;
  final String shortCode;
  final String name;
  final String scientificName;
  final int seasonStartMonth;
  final int seasonStartDay;
  final List<ScaleDef> scales;

  static const supportedFormat = 1;

  factory CropDefinition.fromJson(Map<String, dynamic> json) {
    T req<T>(Map<String, dynamic> m, String key, String where) {
      final v = m[key];
      if (v is! T) throw CropDefinitionError('falta «$key» en $where');
      return v;
    }

    final format = json['format'];
    if (format != supportedFormat) {
      throw CropDefinitionError('formato $format no soportado');
    }
    final code = req<String>(json, 'code', 'el cultivo');
    final start = req<Map<String, dynamic>>(json, 'seasonStart', code);
    final month = req<int>(start, 'month', 'seasonStart');
    final day = req<int>(start, 'day', 'seasonStart');
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      throw CropDefinitionError('fecha de inicio de temporada inválida');
    }

    final scales = <ScaleDef>[];
    for (final s in req<List<dynamic>>(json, 'scales', code).cast<Map<String, dynamic>>()) {
      final scaleName = req<String>(s, 'name', 'una escala');
      final macros = [
        for (final m in req<List<dynamic>>(s, 'macros', scaleName).cast<Map<String, dynamic>>())
          MacroDef(code: req<String>(m, 'code', scaleName), name: req<String>(m, 'name', scaleName)),
      ];
      final macroCodes = macros.map((m) => m.code).toSet();
      final stages = <StageDef>[];
      final seen = <String>{};
      for (final st in req<List<dynamic>>(s, 'stages', scaleName).cast<Map<String, dynamic>>()) {
        final stageCode = req<String>(st, 'code', scaleName);
        if (!seen.add(stageCode)) {
          throw CropDefinitionError('estadio $stageCode repetido en $scaleName');
        }
        final macro = req<String>(st, 'macro', 'estadio $stageCode');
        if (!macroCodes.contains(macro)) {
          throw CropDefinitionError('el estadio $stageCode usa un macroestadio desconocido: $macro');
        }
        stages.add(
          StageDef(
            code: stageCode,
            macro: macro,
            name: req<String>(st, 'name', 'estadio $stageCode'),
            description: (st['description'] as String?) ?? '',
            color: parseHexColor(req<String>(st, 'color', 'estadio $stageCode')),
          ),
        );
      }
      if (stages.isEmpty) throw CropDefinitionError('la escala $scaleName no tiene estadios');
      scales.add(
        ScaleDef(
          name: scaleName,
          version: req<int>(s, 'version', scaleName),
          isDefault: (s['default'] as bool?) ?? false,
          macros: macros,
          stages: stages,
        ),
      );
    }
    if (scales.isEmpty) throw CropDefinitionError('el cultivo $code no tiene escalas');
    if (scales.where((s) => s.isDefault).length > 1) {
      throw CropDefinitionError('el cultivo $code tiene más de una escala por defecto');
    }

    return CropDefinition(
      code: code,
      shortCode: req<String>(json, 'shortCode', code),
      name: req<String>(json, 'name', code),
      scientificName: (json['scientificName'] as String?) ?? '',
      seasonStartMonth: month,
      seasonStartDay: day,
      scales: scales,
    );
  }
}

/// `#RRGGBB` → ARGB opaco.
int parseHexColor(String hex) {
  final m = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex);
  if (m == null) throw CropDefinitionError('color inválido: $hex');
  return 0xFF000000 | int.parse(m.group(1)!, radix: 16);
}
