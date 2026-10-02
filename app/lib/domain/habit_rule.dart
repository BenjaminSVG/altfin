/// Reglas de los gastos repetitivos ("hábitos de gasto"): el autobús, la
/// merienda, el tereré... Se define cuántas veces al día, a qué precio y en
/// qué días de la semana. Todo puro y probado; dinero en enteros.
class HabitRule {
  const HabitRule._();

  /// Bit de cada día de la semana: lunes = 1, martes = 2, ... domingo = 64.
  static int bit(int weekday) {
    if (weekday < 1 || weekday > 7) throw ArgumentError.value(weekday, 'weekday', 'debe ser 1 (lun) a 7 (dom)');
    return 1 << (weekday - 1);
  }

  static const mondayToFriday = 1 | 2 | 4 | 8 | 16;
  static const everyDay = 127;

  static int maskFromDays(Iterable<int> weekdays) => weekdays.fold(0, (m, d) => m | bit(d));

  static List<int> daysFromMask(int mask) => [for (var d = 1; d <= 7; d++) if (mask & bit(d) != 0) d];

  static bool occursOn(int mask, DateTime day) => mask & bit(day.weekday) != 0;

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Cuánto cuesta un día en que se hace: veces al día × precio.
  static int perDay(int unitPrice, int timesPerDay) => unitPrice * timesPerDay;

  /// Gasto de una semana típica.
  static int weekly(int unitPrice, int timesPerDay, int mask) =>
      perDay(unitPrice, timesPerDay) * daysFromMask(mask).length;

  /// Gasto estimado de un mes concreto (cuenta los días reales que caen en la
  /// máscara: un mes con 5 lunes cuenta 5 lunes).
  static int monthlyEstimate({
    required int unitPrice,
    required int timesPerDay,
    required int mask,
    required DateTime month,
  }) {
    final dim = DateTime(month.year, month.month + 1, 0).day;
    var days = 0;
    for (var d = 1; d <= dim; d++) {
      if (occursOn(mask, DateTime(month.year, month.month, d))) days++;
    }
    return perDay(unitPrice, timesPerDay) * days;
  }

  /// Días para los que hay que anotar el gasto: desde el día siguiente a
  /// [lastGenerated] (o desde [createdOn] si nunca se generó) hasta [today],
  /// solo los días de la máscara. Se limita a [maxBackfillDays] hacia atrás
  /// para no llenar el historial si la app estuvo mucho tiempo cerrada.
  static List<DateTime> daysToGenerate({
    required int mask,
    required DateTime createdOn,
    required DateTime? lastGenerated,
    required DateTime today,
    int maxBackfillDays = 31,
  }) {
    final end = dayOnly(today);
    var start = lastGenerated == null
        ? dayOnly(createdOn)
        : dayOnly(lastGenerated).add(const Duration(days: 1));
    final earliest = end.subtract(Duration(days: maxBackfillDays));
    if (start.isBefore(earliest)) start = earliest;
    final out = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1)) {
      if (occursOn(mask, d)) out.add(d);
    }
    return out;
  }

  /// Clave "2026-10-12" para guardar hasta qué día se generó.
  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseDayKey(String key) {
    final p = key.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
    return (y == null || m == null || d == null) ? null : DateTime(y, m, d);
  }
}
