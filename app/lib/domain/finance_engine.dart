import 'dart:math' as math;

import 'money.dart';

/// Perfil de ahorro: porcentajes de necesidades / gustos / ahorro+inversión.
/// Suman 100, salvo [none] (sin porcentajes: el usuario decide no usar un plan).
class SavingsProfile {
  const SavingsProfile._(this.id, this.needsPct, this.wantsPct, this.savingsPct);

  /// Perfil personalizado; lanza si no suma 100 o hay valores negativos.
  factory SavingsProfile.custom({
    required int needsPct,
    required int wantsPct,
    required int savingsPct,
  }) {
    if (needsPct < 0 || wantsPct < 0 || savingsPct < 0) {
      throw ArgumentError('Los porcentajes no pueden ser negativos');
    }
    if (needsPct + wantsPct + savingsPct != 100) {
      throw ArgumentError('Los porcentajes deben sumar 100');
    }
    return SavingsProfile._('custom', needsPct, wantsPct, savingsPct);
  }

  final String id;

  /// ¿Tiene reparto por porcentajes? `false` en [none].
  bool get hasPlan => id != 'none';
  final int needsPct;
  final int wantsPct;
  final int savingsPct;

  /// Modo Cohete: 40 % necesidades, 10 % gustos, 50 % ahorro/inversión.
  static const rocket = SavingsProfile._('rocket', 40, 10, 50);

  /// Equilibrado: 50 / 20 / 30.
  static const balanced = SavingsProfile._('balanced', 50, 20, 30);

  /// Sin porcentajes: no se reparte el sueldo ni se fija una meta de ahorro.
  static const none = SavingsProfile._('none', 0, 0, 0);

  /// Un perfil por su id. Para `custom` se pasan los porcentajes guardados;
  /// si no son válidos (no suman 100) se usa Modo Cohete.
  static SavingsProfile byId(String id, {int needs = 40, int wants = 10, int savings = 50}) {
    switch (id) {
      case 'rocket':
        return rocket;
      case 'balanced':
        return balanced;
      case 'none':
        return none;
      case 'custom':
        try {
          return SavingsProfile.custom(needsPct: needs, wantsPct: wants, savingsPct: savings);
        } on ArgumentError {
          return rocket;
        }
      default:
        throw ArgumentError.value(id, 'id', 'perfil desconocido');
    }
  }
}

/// Reparto del sueldo del mes en bloques.
class BudgetSplit {
  const BudgetSplit({
    required this.needs,
    required this.wants,
    required this.savings,
  });

  final Money needs;
  final Money wants;
  final Money savings;

  Money get total => needs + wants + savings;

  /// Reparte [netIncome]. El resto por redondeo va a ahorro, así la suma
  /// siempre es exactamente el sueldo (no se pierde ni un guaraní).
  factory BudgetSplit.compute(Money netIncome, SavingsProfile profile) {
    if (netIncome.isNegative) {
      throw ArgumentError('El sueldo no puede ser negativo');
    }
    if (!profile.hasPlan) {
      final z = Money.zero(netIncome.currency);
      return BudgetSplit(needs: z, wants: z, savings: z);
    }
    final needs = netIncome.percent(profile.needsPct);
    final wants = netIncome.percent(profile.wantsPct);
    final savings = netIncome - needs - wants;
    return BudgetSplit(needs: needs, wants: wants, savings: savings);
  }
}

/// Cálculos financieros puros (sin Flutter, sin base de datos).
class FinanceEngine {
  const FinanceEngine._();

  /// Cuánto se puede gastar hoy de lo "variable" (gustos + necesidades
  /// variables), repartiendo lo que queda en los días restantes
  /// (incluido hoy). Nunca devuelve negativo.
  static Money dailyAllowance({
    required Money variableBudget,
    required Money spentSoFar,
    required int daysRemainingInclToday,
  }) {
    if (daysRemainingInclToday <= 0) return Money.zero(variableBudget.currency);
    final left = (variableBudget - spentSoFar).clampMin(
      Money.zero(variableBudget.currency),
    );
    return left.divide(daysRemainingInclToday);
  }

  /// Días que quedan del mes, contando [today].
  static int daysRemainingInMonth(DateTime today) {
    final last = DateTime(today.year, today.month + 1, 0).day;
    return last - today.day + 1;
  }

  /// Porcentaje de ahorro sobre ingresos (0.0 – 1.0+). 0 si no hay ingresos.
  static double savingsRate({required Money saved, required Money income}) {
    if (income.minor <= 0) return 0;
    return saved.minor / income.minor;
  }

  /// Meses de gastos que cubre el ahorro líquido.
  static double emergencyMonths({
    required Money liquidSavings,
    required Money avgMonthlyExpenses,
  }) {
    if (avgMonthlyExpenses.minor <= 0) return 0;
    return liquidSavings.minor / avgMonthlyExpenses.minor;
  }

  /// Valor futuro con aportes mensuales e interés compuesto mensual.
  /// [annualRatePct] es nominal anual en % (8 = 8 %).
  static Money futureValue({
    required Money monthlyContribution,
    required double annualRatePct,
    required int years,
    Money? initial,
  }) {
    final currency = monthlyContribution.currency;
    final n = years * 12;
    final i = annualRatePct / 100 / 12;
    final p = (initial ?? Money.zero(currency)).minor.toDouble();
    final a = monthlyContribution.minor.toDouble();
    final growth = math.pow(1 + i, n).toDouble();
    final fv = i == 0 ? p + a * n : p * growth + a * ((growth - 1) / i);
    return Money(fv.round(), currency);
  }

  /// Total aportado (sin interés) en el mismo periodo.
  static Money totalContributed({
    required Money monthlyContribution,
    required int years,
    Money? initial,
  }) =>
      Money(
        monthlyContribution.minor * years * 12 +
            (initial?.minor ?? 0),
        monthlyContribution.currency,
      );

  /// Meses para llegar a una meta ahorrando [monthlySaving] sin rendimiento.
  /// Devuelve null si no se puede (ahorro <= 0). 0 si ya está cumplida.
  static int? monthsToGoal({
    required Money target,
    required Money current,
    required Money monthlySaving,
  }) {
    final missing = target.minor - current.minor;
    if (missing <= 0) return 0;
    if (monthlySaving.minor <= 0) return null;
    return (missing / monthlySaving.minor).ceil();
  }

  /// Meta de independencia financiera: gasto anual × 25 (regla del 4 %).
  static Money financialIndependenceNumber(Money monthlyExpenses) =>
      Money(monthlyExpenses.minor * 12 * 25, monthlyExpenses.currency);

  /// Años para llegar a [target] aportando mensual con rendimiento.
  /// Devuelve null si no se alcanza en [maxYears].
  static int? yearsToReach({
    required Money target,
    required Money monthlyContribution,
    required double annualRatePct,
    Money? initial,
    int maxYears = 80,
  }) {
    for (var y = 0; y <= maxYears; y++) {
      final fv = futureValue(
        monthlyContribution: monthlyContribution,
        annualRatePct: annualRatePct,
        years: y,
        initial: initial,
      );
      if (fv >= target) return y;
    }
    return null;
  }

  /// Cuánto de tu vida cuesta una compra: horas de trabajo.
  static double workHoursCost({
    required Money price,
    required Money monthlyNetIncome,
    int hoursPerMonth = 160,
  }) {
    if (monthlyNetIncome.minor <= 0) return 0;
    final hourly = monthlyNetIncome.minor / hoursPerMonth;
    return price.minor / hourly;
  }

  /// Estado de una barra de presupuesto según el uso.
  static BudgetStatus budgetStatus({required Money spent, required Money limit}) {
    if (limit.minor <= 0) return BudgetStatus.over;
    final ratio = spent.minor / limit.minor;
    if (ratio >= 1) return BudgetStatus.over;
    if (ratio >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.ok;
  }
}

enum BudgetStatus { ok, warning, over }
