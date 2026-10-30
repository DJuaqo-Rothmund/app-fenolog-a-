import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/completeness.dart';
import 'package:frambitacora/domain/project_kind.dart';

void main() {
  test('etiqueta de unidad según tipo de proyecto', () {
    expect(unitLabel(kind: ProjectKind.varietyTrial, varietyName: 'Heritage'), 'Heritage');
    expect(unitLabel(kind: ProjectKind.treatmentTrial, treatment: 'T2', replicate: 3), 'T2 R3');
    expect(unitLabel(kind: ProjectKind.farm, irrigationGroup: '1', sector: '4'), 'Equipo 1 · Sector 4');
  });

  test('registro completo: estado y al menos una foto', () {
    expect(isObservationComplete(hasStage: true, photoCount: 1), isTrue);
    expect(isObservationComplete(hasStage: true, photoCount: 0), isFalse);
    expect(isObservationComplete(hasStage: false, photoCount: 3), isFalse);
  });

  test('avance de la semana', () {
    expect(const WeekProgress(complete: 0, total: 0).fraction, 0);
    expect(const WeekProgress(complete: 0, total: 0).isDone, isFalse);
    expect(const WeekProgress(complete: 3, total: 4).fraction, 0.75);
    expect(const WeekProgress(complete: 4, total: 4).isDone, isTrue);
  });
}
