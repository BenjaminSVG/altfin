/// Reglas de los gastos recurrentes (puras, sin base de datos).
class RecurringRule {
  const RecurringRule._();

  static String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  /// Día real de cobro este mes (en meses cortos cae el último día).
  static int effectiveDay(int dayOfMonth, DateTime now) {
    final dim = _daysInMonth(now);
    return dayOfMonth > dim ? dim : dayOfMonth;
  }

  /// ¿Toca generar el gasto este mes? Sí si ya llegó el día y no se generó.
  static bool isDue(int dayOfMonth, DateTime now, String lastMonth) {
    if (lastMonth == monthKey(now)) return false;
    return now.day >= effectiveDay(dayOfMonth, now);
  }

  /// Fecha con la que se registra el gasto del mes.
  static DateTime dateFor(int dayOfMonth, DateTime now) =>
      DateTime(now.year, now.month, effectiveDay(dayOfMonth, now), 8);
}
