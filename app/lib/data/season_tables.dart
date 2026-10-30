import '../domain/season_weeks.dart';
import 'season_data.dart';

/// Tablas de una temporada (primera fila = encabezados). Las celdas son
/// `String`, `int`, `double`, `DateTime` o nulas; Excel y CSV las convierten.
typedef SheetTable = List<List<Object?>>;

/// Encabezados fijos de la hoja «Registros». La importación desde CSV
/// reconoce estos mismos nombres.
const recordHeaders = [
  'Semana',
  'Desde',
  'Semana ISO',
  'Unidad',
  'Variedad',
  'Tratamiento',
  'Repetición',
  'Equipo de riego',
  'Sector',
  'Código estadio',
  'Estadio',
  'Fotos',
  'Completo',
  'Notas',
  'Latitud',
  'Longitud',
];

/// Un registro por fila: unidad × semana, con sus mediciones como columnas.
SheetTable recordsTable(SeasonData d) {
  final defs = d.observationDefs;
  return [
    [...recordHeaders, for (final m in defs) m.unit.isEmpty ? m.name : '${m.name} (${m.unit})'],
    for (final r in d.records)
      [
        r.week,
        d.weekStart(r.week),
        isoWeek(d.weekStart(r.week)).week,
        r.unit.label,
        d.varietyName(r.unit),
        r.unit.treatment,
        r.unit.replicate,
        r.unit.irrigationGroup,
        r.unit.sector,
        r.stage?.code,
        r.stage?.name,
        r.photos.length,
        r.isComplete ? 'Sí' : 'No',
        r.observation.notes.isEmpty ? null : r.observation.notes,
        r.observation.lat,
        r.observation.lon,
        for (final m in defs) r.values[m.id]?.valueNum ?? r.values[m.id]?.valueText,
      ],
  ];
}

/// Una fila por variedad con sus parámetros de la temporada.
SheetTable varietyParamsTable(SeasonData d) => [
  ['Variedad', for (final m in d.varietyDefs) m.unit.isEmpty ? m.name : '${m.name} (${m.unit})'],
  for (final v in d.usedVarieties)
    [
      v.name,
      for (final m in d.varietyDefs) d.varietyValue(v.id, m.id)?.valueNum ?? d.varietyValue(v.id, m.id)?.valueText,
    ],
];

/// Matriz unidad × semana con el código del estadio («NM» = no muestreada).
SheetTable stageMatrixTable(SeasonData d) {
  final weeks = d.weeks;
  return [
    ['Unidad', 'Variedad', for (final w in weeks) 'S$w'],
    for (final u in d.units)
      [
        u.label,
        d.varietyName(u),
        for (final w in weeks) d.record(u.id, w)?.stage?.code ?? (d.notSampledWeeks.contains(w) ? 'NM' : null),
      ],
  ];
}

/// Escala fenológica usada por el proyecto.
SheetTable scaleTable(SeasonData d) => [
  ['Código', 'Macroestadio', 'Nombre', 'Descripción'],
  for (final s in d.stages) [s.code, s.macroCode, s.name, s.description],
];

/// Nombre de archivo seguro a partir de un texto («Ensayo 2026/27» → «Ensayo_2026-27»).
String safeFileName(String s) =>
    s.trim().replaceAll(RegExp(r'[/\\:]'), '-').replaceAll(RegExp(r'[*?"<>|]'), '').replaceAll(RegExp(r'\s+'), '_');
