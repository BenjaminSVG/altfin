import 'package:altfin/domain/debt_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tarjeta = DebtInput(id: 1, name: 'Tarjeta', balance: 1000000, annualRatePct: 36, minPayment: 60000);
  const prestamo = DebtInput(id: 2, name: 'Préstamo', balance: 5000000, annualRatePct: 12, minPayment: 150000);
  const celular = DebtInput(id: 3, name: 'Celular', balance: 400000, annualRatePct: 0, minPayment: 50000);

  test('sin deudas: 0 meses', () {
    final r = DebtPlanner.simulate(const [], strategy: DebtStrategy.avalanche)!;
    expect(r.months, 0);
    expect(r.totalInterest, 0);
  });

  test('una deuda sin interés: meses = saldo / pago', () {
    final r = DebtPlanner.simulate(const [celular], strategy: DebtStrategy.avalanche)!;
    expect(r.months, 8);
    expect(r.totalInterest, 0);
    expect(r.totalPaid, 400000);
    expect(r.payoffMonth[3], 8);
  });

  test('total pagado = capital + intereses, exacto', () {
    for (final s in DebtStrategy.values) {
      final r = DebtPlanner.simulate(const [tarjeta, prestamo, celular], strategy: s, extraMonthly: 100000)!;
      expect(r.totalPaid, 6400000 + r.totalInterest, reason: '$s');
      expect(r.payoffMonth.length, 3);
      expect(r.order.length, 3);
    }
  });

  test('avalanche paga igual o menos intereses que bola de nieve', () {
    final av = DebtPlanner.simulate(const [tarjeta, prestamo, celular], strategy: DebtStrategy.avalanche, extraMonthly: 100000)!;
    final sn = DebtPlanner.simulate(const [tarjeta, prestamo, celular], strategy: DebtStrategy.snowball, extraMonthly: 100000)!;
    expect(av.totalInterest, lessThanOrEqualTo(sn.totalInterest));
    expect(av.months, lessThanOrEqualTo(sn.months));
  });

  test('el orden: bola de nieve empieza por el menor saldo, avalancha por la mayor tasa', () {
    final sn = DebtPlanner.simulate(const [tarjeta, prestamo, celular], strategy: DebtStrategy.snowball, extraMonthly: 200000)!;
    expect(sn.order.first, 3, reason: 'el celular tiene el menor saldo');
    final av = DebtPlanner.simulate(const [tarjeta, prestamo, celular], strategy: DebtStrategy.avalanche, extraMonthly: 200000)!;
    expect(av.order.first, isIn([1, 3]));
    expect(av.payoffMonth[1]!, lessThan(av.payoffMonth[2]!), reason: 'la tarjeta (36 %) se paga antes que el préstamo (12 %)');
  });

  test('pagar extra acorta el plazo y baja los intereses', () {
    final base = DebtPlanner.simulate(const [tarjeta, prestamo], strategy: DebtStrategy.avalanche)!;
    final extra = DebtPlanner.simulate(const [tarjeta, prestamo], strategy: DebtStrategy.avalanche, extraMonthly: 200000)!;
    expect(extra.months, lessThan(base.months));
    expect(extra.totalInterest, lessThan(base.totalInterest));
  });

  test('si el pago no cubre los intereses, nunca se termina (null)', () {
    const mala = DebtInput(id: 9, name: 'Usura', balance: 10000000, annualRatePct: 60, minPayment: 100000);
    expect(DebtPlanner.simulate(const [mala], strategy: DebtStrategy.avalanche), isNull);
    expect(DebtPlanner.simulate(const [mala], strategy: DebtStrategy.avalanche, extraMonthly: 900000), isNotNull);
  });

  test('extra negativo es inválido', () {
    expect(() => DebtPlanner.simulate(const [tarjeta], strategy: DebtStrategy.avalanche, extraMonthly: -1), throwsArgumentError);
  });
}
