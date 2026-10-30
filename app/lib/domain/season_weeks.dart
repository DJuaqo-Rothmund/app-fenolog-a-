/// Reglas de semanas de muestreo.
///
/// Una temporada define la fecha de inicio de su semana 1 (siempre un lunes).
/// Todas las fechas se tratan como días de calendario (sin hora) para que los
/// cambios de horario de verano no desplacen semanas.
library;

DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Lunes de la semana que contiene [d].
DateTime mondayOf(DateTime d) {
  final day = dateOnly(d);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// Número de semana de temporada para [date]. La semana 1 empieza en
/// [week1Start]; las fechas anteriores dan 0 o números negativos.
int seasonWeekFor(DateTime date, DateTime week1Start) {
  final days = dateOnly(date).difference(mondayOf(week1Start)).inDays;
  return (days / 7).floor() + 1;
}

/// Primer día (lunes) de la semana de temporada [week].
DateTime seasonWeekStart(int week, DateTime week1Start) => mondayOf(week1Start).add(Duration(days: (week - 1) * 7));

/// Semana 1 por defecto: el lunes de la semana que contiene la fecha de
/// inicio de temporada del cultivo ([month]/[day]) más reciente que no sea
/// posterior a [today].
DateTime defaultWeek1Start(DateTime today, int month, int day) {
  final t = dateOnly(today);
  var start = DateTime.utc(t.year, month, day);
  if (mondayOf(start).isAfter(t)) start = DateTime.utc(t.year - 1, month, day);
  return mondayOf(start);
}

/// Nombre sugerido de temporada, p. ej. «2026-27».
String defaultSeasonName(DateTime week1Start) {
  final y = week1Start.year;
  return '$y-${((y + 1) % 100).toString().padLeft(2, '0')}';
}

/// Semana ISO 8601 y su año (la semana 1 contiene el primer jueves del año).
({int week, int year}) isoWeek(DateTime date) {
  final d = dateOnly(date);
  final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
  final firstThursdayYearStart = DateTime.utc(thursday.year, 1, 1);
  final week = (thursday.difference(firstThursdayYearStart).inDays / 7).floor() + 1;
  return (week: week, year: thursday.year);
}
