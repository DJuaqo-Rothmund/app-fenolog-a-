/// Nombre uniforme de las fotos, igual en el teléfono y (más adelante) en la nube:
///
///   `aaaammdd_<CULTIVO>_<UNIDAD>_<tipo><n>.jpg`
///
/// p. ej. `20261102_FRB_HERITAGE-T2R3_D1.jpg`.
library;

enum PhotoKind {
  general('G', 'General'),
  detail('D', 'Detalle'),
  extra('X', 'Extra');

  const PhotoKind(this.letter, this.label);
  final String letter;
  final String label;

  static PhotoKind fromName(String name) =>
      PhotoKind.values.firstWhere((k) => k.name == name, orElse: () => PhotoKind.extra);
}

const _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
  'Á': 'A',
  'É': 'E',
  'Í': 'I',
  'Ó': 'O',
  'Ú': 'U',
  'Ü': 'U',
  'Ñ': 'N',
};

/// Convierte un texto libre en un trozo seguro para nombre de archivo:
/// mayúsculas, sin tildes, solo letras, números y guiones; máximo [maxLength].
String fileSlug(String text, {int maxLength = 24}) {
  final folded = text.split('').map((c) => _accents[c] ?? c).join().toUpperCase();
  final slug = folded.replaceAll(RegExp(r'[^A-Z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  final cut = slug.length > maxLength ? slug.substring(0, maxLength) : slug;
  final clean = cut.replaceAll(RegExp(r'-+$'), '');
  return clean.isEmpty ? 'SIN-NOMBRE' : clean;
}

String photoFileName({
  required DateTime date,
  required String cropShortCode,
  required String unitLabel,
  required PhotoKind kind,
  required int seq,
}) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y$m${d}_${fileSlug(cropShortCode, maxLength: 6)}_${fileSlug(unitLabel)}_${kind.letter}$seq.jpg';
}
