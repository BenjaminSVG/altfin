import 'package:altfin/domain/balance.dart';
import 'package:altfin/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

Money g(int v) => Money(v, Currency.pyg);

BalanceEntry e(String kind, int v, DateTime d, {int? cat}) =>
    BalanceEntry(kind: kind, amount: g(v), date: d, categoryId: cat);

void main() {
  // Jueves 8 de octubre de 2026.
  final now = DateTime(2026, 10, 8, 15, 30);

  group('períodos', () {
    test('hoy: de las 00:00 de hoy a las 00:00 de mañana', () {
      expect(BalanceEngine.start(BalancePeriod.day, now), DateTime(2026, 10, 8));
      expect(BalanceEngine.end(BalancePeriod.day, now), DateTime(2026, 10, 9));
    });

    test('semana: de lunes a domingo', () {
      expect(BalanceEngine.start(BalancePeriod.week, now), DateTime(2026, 10, 5));
      expect(BalanceEngine.end(BalancePeriod.week, now), DateTime(2026, 10, 12));
    });

    test('semana que cruza de mes', () {
      final d = DateTime(2026, 11, 1); // domingo
      expect(BalanceEngine.start(BalancePeriod.week, d), DateTime(2026, 10, 26));
      expect(BalanceEngine.end(BalancePeriod.week, d), DateTime(2026, 11, 2));
    });

    test('mes y año', () {
      expect(BalanceEngine.start(BalancePeriod.month, now), DateTime(2026, 10));
      expect(BalanceEngine.end(BalancePeriod.month, now), DateTime(2026, 11));
      expect(BalanceEngine.start(BalancePeriod.year, now), DateTime(2026));
      expect(BalanceEngine.end(BalancePeriod.year, now), DateTime(2027));
    });

    test('días transcurridos cuentan hoy', () {
      expect(BalanceEngine.elapsedDays(BalancePeriod.day, now), 1);
      expect(BalanceEngine.elapsedDays(BalancePeriod.week, now), 4);
      expect(BalanceEngine.elapsedDays(BalancePeriod.month, now), 8);
    });
  });

  group('totales', () {
    final entries = [
      e('income', 5000000, DateTime(2026, 10, 1)),
      e('expense', 200000, DateTime(2026, 10, 8, 9), cat: 1),
      e('expense', 50000, DateTime(2026, 10, 6), cat: 1),
      e('expense', 80000, DateTime(2026, 10, 2), cat: 2),
      e('saving', 1000000, DateTime(2026, 10, 3)),
      e('expense', 999, DateTime(2026, 9, 30)), // fuera del mes
    ];

    test('mes', () {
      final t = BalanceEngine.totals(entries,
          from: BalanceEngine.start(BalancePeriod.month, now),
          to: BalanceEngine.end(BalancePeriod.month, now),
          currency: Currency.pyg);
      expect(t.income, g(5000000));
      expect(t.expense, g(330000));
      expect(t.saving, g(1000000));
      expect(t.net, g(3670000));
      expect(t.expenseByCategory[1], g(250000));
      expect(t.expenseByCategory[2], g(80000));
    });

    test('hoy: solo lo de hoy', () {
      final t = BalanceEngine.totals(entries,
          from: BalanceEngine.start(BalancePeriod.day, now),
          to: BalanceEngine.end(BalancePeriod.day, now),
          currency: Currency.pyg);
      expect(t.expense, g(200000));
      expect(t.income, g(0));
    });

    test('el límite final del período está excluido', () {
      final t = BalanceEngine.totals([e('expense', 10, DateTime(2026, 10, 9))],
          from: DateTime(2026, 10, 8), to: DateTime(2026, 10, 9), currency: Currency.pyg);
      expect(t.expense, g(0));
    });
  });

  group('dinero disponible', () {
    final at = DateTime(2026, 10, 1, 10);

    test('sin movimientos es lo declarado', () {
      expect(BalanceEngine.available(opening: g(2000000), openingAt: at, entries: const []), g(2000000));
    });

    test('suma ingresos y resta gastos y ahorros posteriores', () {
      final v = BalanceEngine.available(opening: g(2000000), openingAt: at, entries: [
        e('income', 500000, DateTime(2026, 10, 2)),
        e('expense', 120000, DateTime(2026, 10, 3)),
        e('saving', 300000, DateTime(2026, 10, 4)),
      ]);
      expect(v, g(2080000));
    });

    test('ignora lo anterior al momento declarado', () {
      final v = BalanceEngine.available(opening: g(1000000), openingAt: at, entries: [
        e('expense', 400000, DateTime(2026, 9, 30)),
        e('income', 999, DateTime(2026, 10, 1, 9, 59)),
        e('expense', 1000, DateTime(2026, 10, 1, 10)), // justo en el momento: cuenta
      ]);
      expect(v, g(999000));
    });

    test('puede quedar negativo', () {
      final v = BalanceEngine.available(
          opening: g(100000), openingAt: at, entries: [e('expense', 150000, DateTime(2026, 10, 2))]);
      expect(v, g(-50000));
    });

    test('en dólares usa centavos', () {
      final v = BalanceEngine.available(
        opening: const Money(10000, Currency.usd),
        openingAt: at,
        entries: [BalanceEntry(kind: 'expense', amount: const Money(2550, Currency.usd), date: DateTime(2026, 10, 2))],
      );
      expect(v.format(), 'US\$ 74,50');
    });
  });

  test('las horas se comparan al segundo: la base no guarda milisegundos', () {
    // Declaró su dinero a las 9:51:50,6; un ingreso de ese mismo segundo se guarda como 9:51:50,0.
    final declared = BalanceEngine.floorToSecond(DateTime(2026, 10, 2, 9, 51, 50, 600));
    expect(declared, DateTime(2026, 10, 2, 9, 51, 50));
    final v = BalanceEngine.available(
      opening: g(1000),
      openingAt: declared,
      entries: [e('income', 500, DateTime(2026, 10, 2, 9, 51, 50))],
    );
    expect(v, g(1500));
  });

  test('cuántos días alcanza el dinero', () {
    expect(BalanceEngine.runwayDays(g(1000000), g(50000)), 20);
    expect(BalanceEngine.runwayDays(g(1000000), g(0)), isNull);
    expect(BalanceEngine.runwayDays(g(-5), g(1000)), isNull);
  });

  group('gasto periódico', () {
    final oct = DateTime(2026, 10, 15); // octubre 2026: 31 días, 5 jueves/viernes/sábados

    test('diario: monto × días del mes', () {
      final c = PeriodicCost.of(frequency: Periodicity.daily, amount: 20000, month: oct);
      expect(c.perMonth, 620000);
      expect(c.perDay, 20000);
      expect(c.perWeek, 140000);
    });

    test('semanal: cuenta los días reales (5 viernes en octubre 2026)', () {
      final c = PeriodicCost.of(frequency: Periodicity.weekly, amount: 100000, month: oct, weekday: 5);
      expect(c.perMonth, 500000);
      final tue = PeriodicCost.of(frequency: Periodicity.weekly, amount: 100000, month: oct, weekday: 2);
      expect(tue.perMonth, 400000);
    });

    test('mensual: el monto una vez', () {
      final c = PeriodicCost.of(frequency: Periodicity.monthly, amount: 1500000, month: oct);
      expect(c.perMonth, 1500000);
      expect(c.perDay, 48387);
    });

    test('etiquetas', () {
      expect(PeriodicCost.label(Periodicity.daily), 'Cada día');
      expect(PeriodicCost.label(Periodicity.weekly, weekday: 2), 'Cada martes');
      expect(PeriodicCost.label(Periodicity.monthly, dayOfMonth: 5), 'El día 5 de cada mes');
    });
  });
}
