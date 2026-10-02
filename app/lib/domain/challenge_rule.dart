/// Reto sin gasto ("7 días sin comer afuera"): cuenta los días completos en
/// los que no hubo gastos del tipo elegido. Si hay un gasto, el reto se pierde.
class ChallengeProgress {
  const ChallengeProgress({
    required this.cleanDays,
    required this.days,
    required this.failed,
    this.failedOn,
    required this.todayClean,
  });

  /// Días ya terminados sin gastar (hoy no cuenta hasta que termine).
  final int cleanDays;
  final int days;
  final bool failed;
  final DateTime? failedOn;

  /// Hoy todavía no se gastó nada del tipo del reto.
  final bool todayClean;

  bool get completed => !failed && cleanDays >= days;
  int get daysLeft => (days - cleanDays).clamp(0, days);
  double get ratio => days == 0 ? 0 : (cleanDays / days).clamp(0.0, 1.0);
}

class ChallengeRule {
  const ChallengeRule._();

  static const xpReward = 150;
  static const minDays = 3;
  static const maxDays = 30;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// [spendDays] = días (a medianoche) en que hubo algún gasto del tipo del reto.
  static ChallengeProgress evaluate({
    required DateTime start,
    required int days,
    required DateTime today,
    required Set<DateTime> spendDays,
  }) {
    final s = _day(start);
    final t = _day(today);
    final spent = {for (final d in spendDays) _day(d)};
    var clean = 0;
    for (var d = s; d.isBefore(t); d = DateTime(d.year, d.month, d.day + 1)) {
      if (spent.contains(d)) {
        return ChallengeProgress(
            cleanDays: clean, days: days, failed: true, failedOn: d, todayClean: !spent.contains(t));
      }
      clean++;
      if (clean >= days) break;
    }
    final todaySpent = !t.isBefore(s) && spent.contains(t);
    // Gastar hoy pierde el reto aunque el día no haya terminado, salvo que ya esté completo.
    final failed = todaySpent && clean < days;
    return ChallengeProgress(
        cleanDays: clean, days: days, failed: failed, failedOn: failed ? t : null, todayClean: !todaySpent);
  }
}
