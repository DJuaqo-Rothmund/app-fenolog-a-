import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/season_review.dart';

GridCell cell(String? code, int? order, {int photos = 1}) =>
    GridCell(observationId: 'o', stageCode: code, stageOrder: order, photoCount: photos);

void main() {
  const labels = {'a': 'Heritage', 'b': 'Tulameen'};

  test('detecta un estado que retrocede respecto de la semana anterior registrada', () {
    final alerts = findAlerts({
      'a': {1: cell('51', 10), 2: cell('55', 12), 4: cell('51', 10)},
    }, labels);
    expect(alerts.single.kind, AlertKind.regression);
    expect(alerts.single.week, 4);
    expect(alerts.single.message, 'Heritage · S4: el estado 51 es anterior al de S2 (55)');
  });

  test('igual o más avanzado no es alerta', () {
    expect(
      findAlerts({
        'a': {1: cell('51', 10), 2: cell('51', 10), 3: cell('57', 14)},
      }, labels),
      isEmpty,
    );
  });

  test('registros incompletos: estado sin foto y fotos sin estado', () {
    final alerts = findAlerts({
      'a': {1: cell('51', 10, photos: 0)},
      'b': {2: cell(null, null, photos: 2)},
    }, labels);
    expect(alerts.map((a) => a.kind), [AlertKind.noPhoto, AlertKind.noStage]);
    expect(alerts.map((a) => a.week), [1, 2]);
  });

  test('las semanas no muestreadas no generan alertas', () {
    final alerts = findAlerts(
      {
        'a': {1: cell('55', 12), 2: cell('51', 10, photos: 0)},
      },
      labels,
      notSampled: {2},
    );
    expect(alerts, isEmpty);
  });
}
