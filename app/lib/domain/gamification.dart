/// Reglas de gamificación: XP, niveles y rachas. Todo puro y testeable.
class Gamification {
  const Gamification._();

  static const xpPerExpense = 10;
  static const xpPerCompleteDay = 25;
  static const xpPerWeeklyBudget = 100;
  static const xpPerGoal = 500;
  static const xpPerLevel = 1000;
  static const maxLevel = 50;

  static int levelForXp(int xp) =>
      (xp ~/ xpPerLevel + 1).clamp(1, maxLevel);

  static int xpIntoLevel(int xp) =>
      levelForXp(xp) >= maxLevel ? xpPerLevel : xp % xpPerLevel;

  /// Nombre de la evolución de Finn según el nivel.
  static String finnStage(int level) {
    if (level >= 40) return 'Finn Magnate';
    if (level >= 30) return 'Finn Inversor';
    if (level >= 20) return 'Finn Ahorrador';
    if (level >= 10) return 'Finn Estudiante';
    return 'Finn Brote';
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Racha actual: días consecutivos con registro, terminando hoy o ayer
  /// (si hoy todavía no registró, la racha sigue viva hasta medianoche).
  /// [loggedDays] puede traer fechas con hora; se normalizan al día.
  static int currentStreak(Iterable<DateTime> loggedDays, DateTime today) {
    final days = loggedDays.map(_day).toSet();
    var cursor = _day(today);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  /// ¿La racha corre peligro hoy? (ya hay racha pero hoy no se registró).
  static bool streakAtRisk(Iterable<DateTime> loggedDays, DateTime today) {
    final days = loggedDays.map(_day).toSet();
    return !days.contains(_day(today)) &&
        currentStreak(loggedDays, today) > 0;
  }
}
