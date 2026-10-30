import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/domain/season_weeks.dart';

void main() {
  final week1 = DateTime.utc(2026, 9, 7); // lunes

  group('semana de temporada', () {
    test('el lunes de inicio es la semana 1', () {
      expect(seasonWeekFor(DateTime(2026, 9, 7), week1), 1);
    });

    test('el domingo sigue en la misma semana', () {
      expect(seasonWeekFor(DateTime(2026, 9, 13, 23, 59), week1), 1);
    });

    test('el lunes siguiente es la semana 2', () {
      expect(seasonWeekFor(DateTime(2026, 9, 14), week1), 2);
    });

    test('las fechas anteriores al inicio dan 0 o menos', () {
      expect(seasonWeekFor(DateTime(2026, 9, 6), week1), 0);
      expect(seasonWeekFor(DateTime(2026, 8, 30), week1), -1);
    });

    test('si la semana 1 no es lunes, se usa el lunes de esa semana', () {
      expect(seasonWeekFor(DateTime(2026, 9, 7), DateTime.utc(2026, 9, 10)), 1);
    });

    test('inicio de la semana N', () {
      expect(seasonWeekStart(1, week1), DateTime.utc(2026, 9, 7));
      expect(seasonWeekStart(8, week1), DateTime.utc(2026, 10, 26));
    });

    test('ida y vuelta entre fecha y semana', () {
      for (var w = 1; w <= 60; w++) {
        expect(seasonWeekFor(seasonWeekStart(w, week1), week1), w);
      }
    });
  });

  group('semana 1 por defecto', () {
    test('en plena temporada usa el año en curso', () {
      expect(defaultWeek1Start(DateTime(2026, 10, 30), 9, 7), DateTime.utc(2026, 9, 7));
    });

    test('antes del inicio usa la temporada del año anterior', () {
      // 7-sep-2025 fue domingo: su semana empieza el lunes 1-sep-2025.
      expect(defaultWeek1Start(DateTime(2026, 3, 1), 9, 7), DateTime.utc(2025, 9, 1));
    });

    test('nombre de temporada', () {
      expect(defaultSeasonName(DateTime.utc(2026, 9, 7)), '2026-27');
      expect(defaultSeasonName(DateTime.utc(2099, 9, 7)), '2099-00');
    });
  });

  group('semana ISO', () {
    test('casos conocidos', () {
      expect(isoWeek(DateTime(2026, 10, 26)), (week: 44, year: 2026));
      expect(isoWeek(DateTime(2027, 1, 1)), (week: 53, year: 2026));
      expect(isoWeek(DateTime(2024, 12, 30)), (week: 1, year: 2025));
    });
  });
}
