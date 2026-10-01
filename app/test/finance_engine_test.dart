import 'package:altfin/domain/finance_engine.dart';
import 'package:altfin/domain/gamification.dart';
import 'package:altfin/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

Money gs(int v) => Money(v, Currency.pyg);

void main() {
  group('Money', () {
    test('formato guaraní con puntos de miles', () {
      expect(gs(1250000).format(), '₲ 1.250.000');
      expect(gs(0).format(), '₲ 0');
      expect(gs(-18000).format(), '-₲ 18.000');
      expect(gs(999).format(withSymbol: false), '999');
    });
    test('formato dólar con coma decimal', () {
      expect(const Money(65000, Currency.usd).format(), 'US\$ 650,00');
      expect(const Money(5, Currency.usd).format(), 'US\$ 0,05');
    });
    test('suma, resta y comparación', () {
      expect((gs(100) + gs(50)).minor, 150);
      expect((gs(100) - gs(150)).isNegative, isTrue);
      expect(gs(5) < gs(6), isTrue);
    });
    test('no mezcla monedas', () {
      expect(() => gs(1) + const Money(1, Currency.usd), throwsArgumentError);
    });
    test('fromMajor redondea bien (sin errores de double)', () {
      expect(Money.fromMajor(19.99, Currency.usd).minor, 1999);
      expect(Money.fromMajor(0.1 + 0.2, Currency.usd).minor, 30);
    });
  });

  group('BudgetSplit', () {
    test('Modo Cohete con ₲ 5.000.000', () {
      final s = BudgetSplit.compute(gs(5000000), SavingsProfile.rocket);
      expect(s.needs, gs(2000000));
      expect(s.wants, gs(500000));
      expect(s.savings, gs(2500000));
    });
    test('Equilibrado con ₲ 5.000.000', () {
      final s = BudgetSplit.compute(gs(5000000), SavingsProfile.balanced);
      expect(s.savings, gs(1500000));
    });
    test('la suma siempre es el sueldo exacto (sin perder guaraníes)', () {
      for (final income in [1, 7, 99, 1234567, 2899999, 5000001]) {
        final s = BudgetSplit.compute(gs(income), SavingsProfile.rocket);
        expect(s.total, gs(income), reason: 'sueldo $income');
      }
    });
    test('perfil personalizado valida que sume 100', () {
      expect(
        () => SavingsProfile.custom(needsPct: 50, wantsPct: 30, savingsPct: 30),
        throwsArgumentError,
      );
      expect(
        SavingsProfile.custom(needsPct: 30, wantsPct: 10, savingsPct: 60)
            .savingsPct,
        60,
      );
    });
  });

  group('FinanceEngine', () {
    test('gasto diario permitido (caso del diseño)', () {
      // 1.200.000 variable, gastado 520.000, quedan 19 días.
      final d = FinanceEngine.dailyAllowance(
        variableBudget: gs(1200000),
        spentSoFar: gs(520000),
        daysRemainingInclToday: 19,
      );
      expect(d, gs(35789)); // 680.000 / 19 = 35.789,47 → 35.789
    });
    test('si te pasaste, el permitido es 0 (no negativo)', () {
      final d = FinanceEngine.dailyAllowance(
        variableBudget: gs(100),
        spentSoFar: gs(500),
        daysRemainingInclToday: 5,
      );
      expect(d, gs(0));
    });
    test('días restantes del mes incluye hoy', () {
      expect(FinanceEngine.daysRemainingInMonth(DateTime(2026, 10, 1)), 31);
      expect(FinanceEngine.daysRemainingInMonth(DateTime(2026, 10, 31)), 1);
      expect(FinanceEngine.daysRemainingInMonth(DateTime(2028, 2, 10)), 20);
    });
    test('interés compuesto: ₲ 1.000.000 al mes, 8 %, 10 años', () {
      final fv = FinanceEngine.futureValue(
        monthlyContribution: gs(1000000),
        annualRatePct: 8,
        years: 10,
      );
      expect(fv.minor, closeTo(182946000, 100000));
      final contributed = FinanceEngine.totalContributed(
        monthlyContribution: gs(1000000),
        years: 10,
      );
      expect(contributed, gs(120000000));
    });
    test('interés 0 % es solo la suma de aportes', () {
      final fv = FinanceEngine.futureValue(
        monthlyContribution: gs(100),
        annualRatePct: 0,
        years: 1,
        initial: gs(50),
      );
      expect(fv, gs(1250));
    });
    test('meses para una meta', () {
      expect(
        FinanceEngine.monthsToGoal(
          target: gs(5000000),
          current: gs(3400000),
          monthlySaving: gs(500000),
        ),
        4,
      );
      expect(
        FinanceEngine.monthsToGoal(
            target: gs(10), current: gs(10), monthlySaving: gs(0)),
        0,
      );
      expect(
        FinanceEngine.monthsToGoal(
            target: gs(10), current: gs(0), monthlySaving: gs(0)),
        isNull,
      );
    });
    test('fondo de emergencia en meses', () {
      expect(
        FinanceEngine.emergencyMonths(
          liquidSavings: gs(6900000),
          avgMonthlyExpenses: gs(4900000),
        ),
        closeTo(1.41, 0.01),
      );
    });
    test('número de independencia financiera = gasto anual × 25', () {
      expect(FinanceEngine.financialIndependenceNumber(gs(3000000)),
          gs(900000000));
    });
    test('años para alcanzar un objetivo', () {
      final y = FinanceEngine.yearsToReach(
        target: gs(100000000),
        monthlyContribution: gs(1000000),
        annualRatePct: 8,
      );
      expect(y, 7);
    });
    test('horas de trabajo que cuesta una compra', () {
      // Sueldo 4.800.000 / 160 h = 30.000 por hora; compra 90.000 = 3 h.
      expect(
        FinanceEngine.workHoursCost(
            price: gs(90000), monthlyNetIncome: gs(4800000)),
        closeTo(3, 0.001),
      );
    });
    test('estado de presupuesto: verde, naranja, rojo', () {
      expect(FinanceEngine.budgetStatus(spent: gs(50), limit: gs(100)),
          BudgetStatus.ok);
      expect(FinanceEngine.budgetStatus(spent: gs(80), limit: gs(100)),
          BudgetStatus.warning);
      expect(FinanceEngine.budgetStatus(spent: gs(100), limit: gs(100)),
          BudgetStatus.over);
    });
    test('tasa de ahorro', () {
      expect(
        FinanceEngine.savingsRate(saved: gs(2350000), income: gs(5000000)),
        closeTo(0.47, 1e-9),
      );
      expect(FinanceEngine.savingsRate(saved: gs(1), income: gs(0)), 0);
    });
  });

  group('Gamification', () {
    final today = DateTime(2026, 10, 12);
    test('racha cuenta días consecutivos hasta hoy', () {
      final days = [for (var i = 0; i < 5; i++) DateTime(2026, 10, 12 - i, 15)];
      expect(Gamification.currentStreak(days, today), 5);
    });
    test('si hoy no registró, la racha sigue viva desde ayer', () {
      final days = [for (var i = 1; i <= 3; i++) DateTime(2026, 10, 12 - i)];
      expect(Gamification.currentStreak(days, today), 3);
      expect(Gamification.streakAtRisk(days, today), isTrue);
    });
    test('un día sin registro corta la racha', () {
      final days = [DateTime(2026, 10, 12), DateTime(2026, 10, 10)];
      expect(Gamification.currentStreak(days, today), 1);
    });
    test('racha cruza el cambio de mes', () {
      final days = [DateTime(2026, 10, 1), DateTime(2026, 9, 30)];
      expect(Gamification.currentStreak(days, DateTime(2026, 10, 1)), 2);
    });
    test('sin registros no hay racha', () {
      expect(Gamification.currentStreak([], today), 0);
      expect(Gamification.streakAtRisk([], today), isFalse);
    });
    test('niveles y evolución de Finn', () {
      expect(Gamification.levelForXp(0), 1);
      expect(Gamification.levelForXp(11720), 12);
      expect(Gamification.xpIntoLevel(11720), 720);
      expect(Gamification.levelForXp(999999), 50);
      expect(Gamification.finnStage(12), 'Finn Estudiante');
      expect(Gamification.finnStage(45), 'Finn Magnate');
    });
  });
}
