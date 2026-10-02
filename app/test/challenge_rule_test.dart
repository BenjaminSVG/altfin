import 'package:altfin/domain/challenge_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 10, 5); // lunes

  test('cuenta los días terminados sin gasto; hoy todavía no cuenta', () {
    final p = ChallengeRule.evaluate(
        start: start, days: 7, today: DateTime(2026, 10, 8, 15), spendDays: {});
    expect(p.cleanDays, 3); // 5, 6 y 7
    expect(p.failed, isFalse);
    expect(p.completed, isFalse);
    expect(p.daysLeft, 4);
    expect(p.todayClean, isTrue);
  });

  test('un gasto en un día pasado pierde el reto', () {
    final p = ChallengeRule.evaluate(
        start: start, days: 7, today: DateTime(2026, 10, 9), spendDays: {DateTime(2026, 10, 7, 13)});
    expect(p.failed, isTrue);
    expect(p.failedOn, DateTime(2026, 10, 7));
    expect(p.cleanDays, 2);
  });

  test('gastar hoy pierde el reto', () {
    final p = ChallengeRule.evaluate(
        start: start, days: 7, today: DateTime(2026, 10, 6, 20), spendDays: {DateTime(2026, 10, 6)});
    expect(p.failed, isTrue);
    expect(p.todayClean, isFalse);
  });

  test('se completa al terminar el último día y los gastos posteriores no lo anulan', () {
    final p = ChallengeRule.evaluate(
        start: start, days: 3, today: DateTime(2026, 10, 8), spendDays: {DateTime(2026, 10, 8)});
    expect(p.completed, isTrue);
    expect(p.failed, isFalse);
    expect(p.ratio, 1);
  });

  test('un gasto antes del inicio no cuenta', () {
    final p = ChallengeRule.evaluate(
        start: start, days: 3, today: DateTime(2026, 10, 5, 9), spendDays: {DateTime(2026, 10, 4)});
    expect(p.failed, isFalse);
    expect(p.cleanDays, 0);
  });
}
