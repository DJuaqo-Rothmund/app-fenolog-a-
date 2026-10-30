/// Estadística para comparar tratamientos o variedades: análisis de varianza
/// (ANOVA) de una vía o en bloques completos al azar, y comparación de medias
/// con la diferencia mínima significativa (LSD de Fisher).
library;

import 'dart:math' as math;

/// Una observación: grupo (tratamiento o variedad), bloque (repetición, o
/// nulo si el diseño no tiene bloques) y valor.
typedef Sample = ({String group, String? block, double value});

class AnovaRow {
  const AnovaRow(this.source, this.df, this.ss, {this.f, this.p});
  final String source;
  final int df;
  final double ss;
  final double? f;
  final double? p;
  double get ms => df == 0 ? double.nan : ss / df;
}

class GroupMean {
  const GroupMean(this.group, this.n, this.mean, this.sd, this.letters);
  final String group;
  final int n;
  final double mean;
  final double sd;

  /// Letras de agrupación: medias que comparten una letra no difieren (p ≥ α).
  final String letters;
}

class ComparisonResult {
  const ComparisonResult({
    required this.table,
    required this.means,
    required this.lsd,
    required this.alpha,
    required this.cv,
    required this.blocked,
  });

  /// Filas del ANOVA: grupos, (bloques), error y total.
  final List<AnovaRow> table;

  /// Medias de mayor a menor con sus letras.
  final List<GroupMean> means;

  /// Diferencia mínima significativa (para grupos con igual número de datos);
  /// nula si no se puede calcular.
  final double? lsd;
  final double alpha;

  /// Coeficiente de variación del ensayo, en %.
  final double cv;
  final bool blocked;

  AnovaRow get groups => table.first;
  bool get significant => (groups.p ?? 1) < alpha;
}

class StatsException implements Exception {
  StatsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Compara las medias de los grupos. Si todas las muestras traen bloque y el
/// diseño está completo (cada grupo una vez en cada bloque), usa ANOVA en
/// bloques; si no, ANOVA de una vía.
ComparisonResult compareGroups(List<Sample> samples, {double alpha = 0.05}) {
  final groups = <String, List<Sample>>{};
  for (final s in samples) {
    (groups[s.group] ??= []).add(s);
  }
  if (groups.length < 2) throw StatsException('Se necesitan al menos dos grupos con datos.');
  final n = samples.length;
  final grand = samples.fold(0.0, (a, s) => a + s.value) / n;
  final ssTotal = samples.fold(0.0, (a, s) => a + _sq(s.value - grand));
  final ssGroups = groups.values.fold(0.0, (a, g) => a + g.length * _sq(_mean(g) - grand));
  final dfGroups = groups.length - 1;

  final blocks = <String, List<Sample>>{};
  final blocked = samples.every((s) => s.block != null) && _isComplete(groups, samples);
  if (blocked) {
    for (final s in samples) {
      (blocks[s.block!] ??= []).add(s);
    }
  }
  final ssBlocks = blocked ? blocks.values.fold(0.0, (a, b) => a + b.length * _sq(_mean(b) - grand)) : 0.0;
  final dfBlocks = blocked ? blocks.length - 1 : 0;
  final dfError = n - 1 - dfGroups - dfBlocks;
  if (dfError < 1) throw StatsException('Faltan repeticiones: no quedan grados de libertad para el error.');
  final ssError = math.max(0.0, ssTotal - ssGroups - ssBlocks);
  final msError = ssError / dfError;

  // Sin variación de error, cualquier diferencia entre medias es exacta.
  double? fOf(double ss, int df) => msError > 1e-12 ? (ss / df) / msError : (ss > 1e-12 ? double.infinity : null);
  final fGroups = fOf(ssGroups, dfGroups);
  final fBlocks = blocked ? fOf(ssBlocks, dfBlocks) : null;
  final table = [
    AnovaRow('Grupos', dfGroups, ssGroups, f: fGroups, p: fGroups == null ? null : _pValue(fGroups, dfGroups, dfError)),
    if (blocked)
      AnovaRow(
        'Bloques',
        dfBlocks,
        ssBlocks,
        f: fBlocks,
        p: fBlocks == null ? null : _pValue(fBlocks, dfBlocks, dfError),
      ),
    AnovaRow('Error', dfError, ssError),
    AnovaRow('Total', n - 1, ssTotal),
  ];

  final t = studentTQuantile(1 - alpha / 2, dfError);
  double lsdFor(int a, int b) => t * math.sqrt(msError * (1 / a + 1 / b));
  final sorted = groups.entries.toList()..sort((a, b) => _mean(b.value).compareTo(_mean(a.value)));
  final means = [for (final e in sorted) (group: e.key, n: e.value.length, mean: _mean(e.value))];
  final letters = groupingLetters(
    means.length,
    (i, j) => (means[i].mean - means[j].mean).abs() < lsdFor(means[i].n, means[j].n),
  );
  final sizes = {for (final m in means) m.n};

  return ComparisonResult(
    table: table,
    means: [
      for (final (i, m) in means.indexed)
        GroupMean(m.group, m.n, m.mean, _sd(groups[m.group]!.map((s) => s.value).toList()), letters[i]),
    ],
    lsd: sizes.length == 1 ? lsdFor(sizes.single, sizes.single) : null,
    alpha: alpha,
    cv: grand == 0 ? double.nan : 100 * math.sqrt(msError) / grand.abs(),
    blocked: blocked,
  );
}

bool _isComplete(Map<String, List<Sample>> groups, List<Sample> samples) {
  final blockNames = {for (final s in samples) s.block};
  if (blockNames.length < 2) return false;
  for (final g in groups.values) {
    final b = [for (final s in g) s.block];
    if (b.length != blockNames.length || b.toSet().length != blockNames.length) return false;
  }
  return true;
}

/// Letras de agrupación para [k] medias ordenadas de mayor a menor.
/// [same] dice si dos medias no difieren significativamente.
List<String> groupingLetters(int k, bool Function(int i, int j) same) {
  // Cada grupo de medias consecutivas que no difieren entre sí recibe una
  // letra; se omiten los grupos contenidos en uno anterior.
  final spans = <(int, int)>[];
  for (var i = 0; i < k; i++) {
    var j = i;
    while (j + 1 < k && same(i, j + 1)) {
      j++;
    }
    if (spans.isEmpty || j > spans.last.$2) spans.add((i, j));
  }
  final out = List.filled(k, '');
  for (final (idx, (from, to)) in spans.indexed) {
    final letter = String.fromCharCode('a'.codeUnitAt(0) + idx % 26);
    for (var m = from; m <= to; m++) {
      out[m] += letter;
    }
  }
  return out;
}

double _pValue(double f, int d1, int d2) => f.isInfinite ? 0 : fDistributionUpperTail(f, d1, d2);

double _sq(double x) => x * x;
double _mean(List<Sample> s) => s.fold(0.0, (a, x) => a + x.value) / s.length;

double _sd(List<double> v) {
  if (v.length < 2) return double.nan;
  final m = v.reduce((a, b) => a + b) / v.length;
  return math.sqrt(v.fold(0.0, (a, x) => a + _sq(x - m)) / (v.length - 1));
}

// ---------------------------------------------------------------------------
// Distribuciones (Numerical Recipes): función beta incompleta regularizada.

double _lnGamma(double x) {
  const c = [
    76.18009172947146,
    -86.50532032941677,
    24.01409824083091,
    -1.231739572450155,
    0.1208650973866179e-2,
    -0.5395239384953e-5,
  ];
  var y = x;
  var tmp = x + 5.5;
  tmp -= (x + 0.5) * math.log(tmp);
  var ser = 1.000000000190015;
  for (final cj in c) {
    ser += cj / ++y;
  }
  return -tmp + math.log(2.5066282746310005 * ser / x);
}

double _betaContinuedFraction(double a, double b, double x) {
  const maxIt = 300, eps = 3e-14, fpMin = 1e-300;
  final qab = a + b, qap = a + 1, qam = a - 1;
  var c = 1.0;
  var d = 1 - qab * x / qap;
  if (d.abs() < fpMin) d = fpMin;
  d = 1 / d;
  var h = d;
  for (var m = 1; m <= maxIt; m++) {
    final m2 = 2 * m;
    var aa = m * (b - m) * x / ((qam + m2) * (a + m2));
    d = 1 + aa * d;
    if (d.abs() < fpMin) d = fpMin;
    c = 1 + aa / c;
    if (c.abs() < fpMin) c = fpMin;
    d = 1 / d;
    h *= d * c;
    aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
    d = 1 + aa * d;
    if (d.abs() < fpMin) d = fpMin;
    c = 1 + aa / c;
    if (c.abs() < fpMin) c = fpMin;
    d = 1 / d;
    final del = d * c;
    h *= del;
    if ((del - 1).abs() < eps) break;
  }
  return h;
}

/// Beta incompleta regularizada I_x(a, b).
double incompleteBeta(double a, double b, double x) {
  if (x <= 0) return 0;
  if (x >= 1) return 1;
  final bt = math.exp(_lnGamma(a + b) - _lnGamma(a) - _lnGamma(b) + a * math.log(x) + b * math.log(1 - x));
  if (x < (a + 1) / (a + b + 2)) return bt * _betaContinuedFraction(a, b, x) / a;
  return 1 - bt * _betaContinuedFraction(b, a, 1 - x) / b;
}

/// P(F > f) para una F con (d1, d2) grados de libertad.
double fDistributionUpperTail(double f, int d1, int d2) {
  if (f <= 0) return 1;
  return incompleteBeta(d2 / 2, d1 / 2, d2 / (d2 + d1 * f));
}

/// Función de distribución acumulada de la t de Student.
double studentTCdf(double t, int df) {
  final x = df / (df + t * t);
  final tail = 0.5 * incompleteBeta(df / 2, 0.5, x);
  return t >= 0 ? 1 - tail : tail;
}

/// Cuantil de la t de Student (p entre 0,5 y 1), por bisección.
double studentTQuantile(double p, int df) {
  var lo = 0.0, hi = 1000.0;
  for (var i = 0; i < 200; i++) {
    final mid = (lo + hi) / 2;
    if (studentTCdf(mid, df) < p) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}
