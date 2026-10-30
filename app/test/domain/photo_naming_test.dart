import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/photo_naming.dart';

void main() {
  test('nombre uniforme de foto', () {
    expect(
      photoFileName(
        date: DateTime(2026, 11, 2),
        cropShortCode: 'FRB',
        unitLabel: 'Heritage',
        kind: PhotoKind.detail,
        seq: 1,
      ),
      '20261102_FRB_HERITAGE_D1.jpg',
    );
  });

  test('las etiquetas se limpian: tildes, espacios y símbolos', () {
    expect(fileSlug('Equipo 2 · Sector 3'), 'EQUIPO-2-SECTOR-3');
    expect(fileSlug('Ñuble Rojo'), 'NUBLE-ROJO');
    expect(fileSlug('  T1 R2 '), 'T1-R2');
    expect(fileSlug('***'), 'SIN-NOMBRE');
  });

  test('las etiquetas largas se recortan sin dejar guion al final', () {
    final slug = fileSlug('Una variedad con un nombre muy largo de verdad');
    expect(slug.length, lessThanOrEqualTo(24));
    expect(slug.endsWith('-'), isFalse);
  });

  test('cada tipo de foto tiene su letra', () {
    expect(PhotoKind.values.map((k) => k.letter), ['G', 'D', 'X']);
    expect(PhotoKind.fromName('general'), PhotoKind.general);
  });
}
