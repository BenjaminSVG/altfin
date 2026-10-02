import 'package:altfin/domain/finance_engine.dart';
import 'package:altfin/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pyg = Currency.pyg;
  final now = DateTime(2026, 10, 12);

  test('reparte lo que falta entre los meses hasta la fecha', () {
    final m = FinanceEngine.monthlyNeeded(
        target: const Money(1200000, pyg), current: const Money(200000, pyg), deadline: DateTime(2027, 4, 12), now: now);
    expect(m!.minor, 166667); // 1.000.000 / 6, redondeado hacia arriba
  });

  test('sin fecha es null, cumplida es 0, fecha pasada = todo en 1 mes', () {
    expect(FinanceEngine.monthlyNeeded(target: const Money(100, pyg), current: Money.zero(pyg), deadline: null, now: now), isNull);
    expect(
        FinanceEngine.monthlyNeeded(
            target: const Money(100, pyg), current: const Money(100, pyg), deadline: DateTime(2027), now: now)!.minor,
        0);
    expect(
        FinanceEngine.monthlyNeeded(
            target: const Money(100, pyg), current: Money.zero(pyg), deadline: DateTime(2026, 1), now: now)!.minor,
        100);
  });
}
