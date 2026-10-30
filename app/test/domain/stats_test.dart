import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/stats.dart';

void main() {
  test('distribuciones t y F coinciden con tablas', () {
    expect(studentTQuantile(0.975, 6), closeTo(2.446912, 1e-5));
    expect(studentTQuantile(0.975, 1000), closeTo(1.962339, 1e-4));
    expect(fDistributionUpperTail(19, 2, 6), closeTo(0.0025357, 1e-6));
  });

  test('ANOVA de una vía y LSD', () {
    final samples = [
      for (final v in [4.0, 5.0, 6.0]) (group: 'A', block: null, value: v),
      for (final v in [6.0, 7.0, 8.0]) (group: 'B', block: null, value: v),
      for (final v in [9.0, 10.0, 11.0]) (group: 'C', block: null, value: v),
    ];
    final r = compareGroups(samples);
    expect(r.blocked, isFalse);
    expect(r.groups.ss, closeTo(38, 1e-9));
    expect(r.groups.f, closeTo(19, 1e-9));
    expect(r.groups.p, closeTo(0.0025357, 1e-6));
    expect(r.table.map((x) => x.df), [2, 6, 8]);
    expect(r.significant, isTrue);
    expect(r.lsd, closeTo(2.4469 * 0.8165, 1e-3));
    expect(r.means.map((m) => (m.group, m.letters)), [('C', 'a'), ('B', 'b'), ('A', 'c')]);
    expect(r.means.first.sd, closeTo(1, 1e-9));
  });

  group('bloques completos al azar', () {
    final data = {
      'T1': [10.0, 12.0, 11.0, 13.0],
      'T2': [14.0, 15.0, 15.0, 17.0],
      'T3': [9.0, 11.0, 10.0, 10.0],
    };
    List<Sample> samples({bool withBlocks = true}) => [
      for (final MapEntry(key: g, value: values) in data.entries)
        for (final (i, v) in values.indexed) (group: g, block: withBlocks ? 'R${i + 1}' : null, value: v),
    ];

    test('separa el efecto de las repeticiones (valores de SciPy)', () {
      final r = compareGroups(samples());
      expect(r.blocked, isTrue);
      expect(r.table.map((x) => x.source), ['Grupos', 'Bloques', 'Error', 'Total']);
      expect(r.groups.f, closeTo(61.94118, 1e-4));
      expect(r.groups.p, closeTo(9.8583e-5, 1e-8));
      expect(r.table[1].p, closeTo(0.0277483, 1e-6));
      expect(r.lsd, closeTo(1.188985, 1e-5));
      expect(r.cv, closeTo(5.60967, 1e-4));
      expect(r.means.map((m) => '${m.group}=${m.letters}'), ['T2=a', 'T1=b', 'T3=c']);
    });

    test('sin repeticiones usa una vía', () {
      final r = compareGroups(samples(withBlocks: false));
      expect(r.blocked, isFalse);
      expect(r.groups.f, closeTo(22.40426, 1e-4));
      expect(r.groups.p, closeTo(0.00032008, 1e-7));
    });

    test('un diseño incompleto vuelve a una vía', () {
      final r = compareGroups(samples().sublist(1));
      expect(r.blocked, isFalse);
    });
  });

  test('letras superpuestas: a, ab, b', () {
    final means = [10.0, 9.0, 8.0];
    final letters = groupingLetters(3, (i, j) => (means[i] - means[j]).abs() < 1.5);
    expect(letters, ['a', 'ab', 'b']);
  });

  test('errores claros con pocos datos', () {
    expect(() => compareGroups([(group: 'A', block: null, value: 1)]), throwsA(isA<StatsException>()));
    expect(
      () => compareGroups([(group: 'A', block: null, value: 1), (group: 'B', block: null, value: 2)]),
      throwsA(isA<StatsException>()),
    );
  });

  test('sin variación de error, las diferencias son significativas', () {
    final r = compareGroups([
      for (final v in [1.0, 1.0]) (group: 'A', block: null, value: v),
      for (final v in [3.0, 3.0]) (group: 'B', block: null, value: v),
    ]);
    expect(r.groups.f, double.infinity);
    expect(r.groups.p, 0);
    expect(r.means.map((m) => m.letters), ['a', 'b']);
  });
}
