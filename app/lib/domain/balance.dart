import 'habit_rule.dart';
import 'money.dart';

/// Nota con la que se anota el sueldo cobrado. Suma al dinero disponible, pero no
/// se cuenta como ingreso extra del presupuesto (el sueldo ya está en Ajustes).
const salaryNote = 'Sueldo';

/// Período para mirar el balance: hoy, esta semana (lunes a domingo), este mes o este año.
enum BalancePeriod {
  day('Hoy'),
  week('Semana'),
  month('Mes'),
  year('Año');

  const BalancePeriod(this.label);
  final String label;
}

/// Un movimiento ya convertido a la moneda principal, listo para sumar.
class BalanceEntry {
  const BalanceEntry({required this.kind, required this.amount, required this.date, this.categoryId});

  /// expense | income | saving.
  final String kind;
  final Money amount;
  final DateTime date;
  final int? categoryId;
}

/// Totales de un período.
class PeriodTotals {
  const PeriodTotals({
    required this.income,
    required this.expense,
    required this.saving,
    required this.expenseByCategory,
  });

  final Money income, expense, saving;
  final Map<int?, Money> expenseByCategory;

  /// Lo que quedó: entró − gastó − ahorró.
  Money get net => income - expense - saving;
}

/// Cálculos del balance personal (puros, sin base de datos ni Flutter).
class BalanceEngine {
  const BalanceEngine._();

  /// Primer instante del período que contiene a [now].
  static DateTime start(BalancePeriod p, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (p) {
      case BalancePeriod.day:
        return today;
      case BalancePeriod.week:
        return DateTime(today.year, today.month, today.day - (today.weekday - 1));
      case BalancePeriod.month:
        return DateTime(now.year, now.month);
      case BalancePeriod.year:
        return DateTime(now.year);
    }
  }

  /// Primer instante DESPUÉS del período (excluido).
  static DateTime end(BalancePeriod p, DateTime now) {
    final s = start(p, now);
    switch (p) {
      case BalancePeriod.day:
        return DateTime(s.year, s.month, s.day + 1);
      case BalancePeriod.week:
        return DateTime(s.year, s.month, s.day + 7);
      case BalancePeriod.month:
        return DateTime(s.year, s.month + 1);
      case BalancePeriod.year:
        return DateTime(s.year + 1);
    }
  }

  /// Días transcurridos del período, contando hoy (mínimo 1). Sirve para el promedio por día.
  static int elapsedDays(BalancePeriod p, DateTime now) {
    final s = start(p, now);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(s).inDays + 1;
  }

  /// Suma los movimientos que caen en [from, to).
  static PeriodTotals totals(
    Iterable<BalanceEntry> entries, {
    required DateTime from,
    required DateTime to,
    required Currency currency,
  }) {
    final zero = Money.zero(currency);
    var income = zero, expense = zero, saving = zero;
    final byCat = <int?, Money>{};
    for (final e in entries) {
      if (e.date.isBefore(from) || !e.date.isBefore(to)) continue;
      switch (e.kind) {
        case 'income':
          income += e.amount;
        case 'saving':
          saving += e.amount;
        default:
          expense += e.amount;
          byCat[e.categoryId] = (byCat[e.categoryId] ?? zero) + e.amount;
      }
    }
    return PeriodTotals(income: income, expense: expense, saving: saving, expenseByCategory: byCat);
  }

  /// La base guarda las horas sin fracciones de segundo; se comparan igual.
  static DateTime floorToSecond(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second);

  /// Dinero disponible: lo que la persona dijo tener en [openingAt] más lo que
  /// entró, menos lo que gastó y lo que apartó para ahorrar desde ese momento.
  /// Los movimientos con fecha anterior a [openingAt] ya estaban incluidos en lo
  /// que declaró, así que no se cuentan.
  static Money available({
    required Money opening,
    required DateTime openingAt,
    required Iterable<BalanceEntry> entries,
  }) {
    var total = opening;
    for (final e in entries) {
      if (e.date.isBefore(openingAt)) continue;
      switch (e.kind) {
        case 'income':
          total += e.amount;
        default: // gasto o ahorro: sale del dinero disponible
          total -= e.amount;
      }
    }
    return total;
  }

  /// Cuántos días alcanza el dinero al ritmo de gasto diario [dailySpend].
  /// null si no se puede calcular (sin gasto o sin dinero).
  static int? runwayDays(Money available, Money dailySpend) {
    if (dailySpend.minor <= 0 || available.minor <= 0) return null;
    return available.minor ~/ dailySpend.minor;
  }
}

/// Frecuencia de un gasto periódico cargado a mano.
enum Periodicity { daily, weekly, monthly }

/// Cuánto cuesta un gasto periódico, expresado por día, semana y mes.
class PeriodicCost {
  const PeriodicCost({required this.perMonth, required this.daysInMonth});

  /// Gasto de un mes concreto (en unidades mínimas).
  final int perMonth;
  final int daysInMonth;

  int get perDay => perMonth ~/ daysInMonth;
  int get perWeek => perDay * 7;

  /// Costo del mes para un gasto [amount] con la frecuencia dada.
  /// [weekday] (1 = lun ... 7 = dom) para semanal; [times] veces por ocurrencia.
  static PeriodicCost of({
    required Periodicity frequency,
    required int amount,
    required DateTime month,
    int weekday = 1,
    int times = 1,
  }) {
    final dim = DateTime(month.year, month.month + 1, 0).day;
    final int monthly;
    switch (frequency) {
      case Periodicity.daily:
        monthly = HabitRule.monthlyEstimate(unitPrice: amount, timesPerDay: times, mask: HabitRule.everyDay, month: month);
      case Periodicity.weekly:
        monthly = HabitRule.monthlyEstimate(
            unitPrice: amount, timesPerDay: times, mask: HabitRule.bit(weekday), month: month);
      case Periodicity.monthly:
        monthly = amount * times;
    }
    return PeriodicCost(perMonth: monthly, daysInMonth: dim);
  }

  /// Etiqueta corta: "Cada día", "Cada martes", "El día 5 de cada mes".
  static String label(Periodicity f, {int weekday = 1, int dayOfMonth = 1}) {
    const names = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    switch (f) {
      case Periodicity.daily:
        return 'Cada día';
      case Periodicity.weekly:
        return 'Cada ${names[weekday - 1]}';
      case Periodicity.monthly:
        return 'El día $dayOfMonth de cada mes';
    }
  }
}
