/// Plan de pago de deudas: métodos avalancha y bola de nieve.
/// Todo en enteros (unidad mínima de la moneda); los intereses se redondean
/// cada mes, así el total pagado = capital + intereses exactamente.
enum DebtStrategy {
  /// Primero la deuda con mayor tasa de interés (paga menos intereses).
  avalanche,

  /// Primero la deuda con menor saldo (victorias rápidas, más motivación).
  snowball,
}

class DebtInput {
  const DebtInput({
    required this.id,
    required this.name,
    required this.balance,
    required this.annualRatePct,
    required this.minPayment,
  });

  final int id;
  final String name;
  final int balance;
  final double annualRatePct;
  final int minPayment;
}

class DebtPlanResult {
  const DebtPlanResult({
    required this.strategy,
    required this.months,
    required this.totalInterest,
    required this.totalPaid,
    required this.payoffMonth,
    required this.order,
  });

  final DebtStrategy strategy;

  /// Meses hasta quedar libre de deudas.
  final int months;
  final int totalInterest;
  final int totalPaid;

  /// Mes (1 = el mes que viene) en que se termina de pagar cada deuda.
  final Map<int, int> payoffMonth;

  /// Ids en el orden en que se terminan de pagar.
  final List<int> order;
}

class DebtPlanner {
  const DebtPlanner._();

  static const maxMonths = 600;

  /// Simula el pago. [extraMonthly] se suma al total de mínimos y se aplica a
  /// la deuda prioritaria; cuando una deuda se termina, su pago mínimo pasa a
  /// la siguiente ("efecto bola de nieve").
  ///
  /// Devuelve `null` si con ese presupuesto la deuda no se termina nunca
  /// (los pagos no alcanzan ni para cubrir los intereses).
  static DebtPlanResult? simulate(
    List<DebtInput> debts, {
    required DebtStrategy strategy,
    int extraMonthly = 0,
  }) {
    if (extraMonthly < 0) throw ArgumentError.value(extraMonthly, 'extraMonthly');
    final active = debts.where((d) => d.balance > 0).toList();
    if (active.isEmpty) {
      return DebtPlanResult(
        strategy: strategy,
        months: 0,
        totalInterest: 0,
        totalPaid: 0,
        payoffMonth: const {},
        order: const [],
      );
    }

    final balance = {for (final d in active) d.id: d.balance};
    final budget = active.fold<int>(0, (a, d) => a + d.minPayment) + extraMonthly;
    final payoff = <int, int>{};
    final order = <int>[];
    var interestTotal = 0;
    var paidTotal = 0;

    for (var month = 1; month <= maxMonths; month++) {
      // 1) Intereses del mes.
      for (final d in active) {
        final b = balance[d.id]!;
        if (b <= 0) continue;
        final interest = (b * d.annualRatePct / 100 / 12).round();
        balance[d.id] = b + interest;
        interestTotal += interest;
      }

      // 2) Pagos mínimos.
      var left = budget;
      for (final d in active) {
        final b = balance[d.id]!;
        if (b <= 0) continue;
        final pay = d.minPayment < b ? d.minPayment : b;
        balance[d.id] = b - pay;
        left -= pay;
        paidTotal += pay;
      }

      // 3) Lo que sobra, a la deuda prioritaria (y en cascada).
      final pending = active.where((d) => balance[d.id]! > 0).toList()
        ..sort((a, b) => _priority(a, b, balance, strategy));
      for (final d in pending) {
        if (left <= 0) break;
        final b = balance[d.id]!;
        final pay = left < b ? left : b;
        balance[d.id] = b - pay;
        left -= pay;
        paidTotal += pay;
      }

      // 4) Deudas terminadas este mes.
      for (final d in active) {
        if (balance[d.id] == 0 && !payoff.containsKey(d.id)) {
          payoff[d.id] = month;
          order.add(d.id);
        }
      }
      if (payoff.length == active.length) {
        return DebtPlanResult(
          strategy: strategy,
          months: month,
          totalInterest: interestTotal,
          totalPaid: paidTotal,
          payoffMonth: payoff,
          order: order,
        );
      }
    }
    return null;
  }

  static int _priority(DebtInput a, DebtInput b, Map<int, int> balance, DebtStrategy s) {
    int byRate() => b.annualRatePct.compareTo(a.annualRatePct);
    int byBalance() => balance[a.id]!.compareTo(balance[b.id]!);
    final first = s == DebtStrategy.avalanche ? byRate() : byBalance();
    if (first != 0) return first;
    final second = s == DebtStrategy.avalanche ? byBalance() : byRate();
    return second != 0 ? second : a.id.compareTo(b.id);
  }
}
