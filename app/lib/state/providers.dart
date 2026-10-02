import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/finance_engine.dart';
import '../domain/fx.dart';
import '../domain/gamification.dart';
import '../domain/money.dart';

/// Reloj de la app (se puede reemplazar en pruebas).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Ajustes del usuario ya interpretados.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.name = '',
    this.currency = Currency.pyg,
    this.netIncomeMinor = 0,
    this.profileId = 'rocket',
    this.frequency = 'monthly',
    this.payDay = 1,
    this.xp = 0,
    this.dark = false,
    this.pygPerUsd = Fx.defaultRate,
    this.reminderHour = 20,
    this.reminders = true,
    this.pinHash = '',
    this.pinSalt = '',
    this.debtStrategy = 'avalanche',
    this.debtExtraMinor = 0,
    this.customNeeds = 40,
    this.customWants = 10,
    this.customSavings = 50,
  });

  factory AppSettings.fromMap(Map<String, String> m) => AppSettings(
        onboarded: m['onboarded'] == '1',
        name: m['name'] ?? '',
        currency: Currency.fromCode(m['currency'] ?? 'PYG'),
        netIncomeMinor: int.tryParse(m['net_income'] ?? '') ?? 0,
        profileId: m['profile'] ?? 'rocket',
        frequency: m['frequency'] ?? 'monthly',
        payDay: int.tryParse(m['pay_day'] ?? '') ?? 1,
        xp: int.tryParse(m['xp'] ?? '') ?? 0,
        dark: m['dark'] == '1',
        pygPerUsd: double.tryParse(m['usd_rate'] ?? '') ?? Fx.defaultRate,
        reminderHour: int.tryParse(m['reminder_hour'] ?? '') ?? 20,
        reminders: (m['reminders'] ?? '1') == '1',
        pinHash: m['pin_hash'] ?? '',
        pinSalt: m['pin_salt'] ?? '',
        debtStrategy: m['debt_strategy'] ?? 'avalanche',
        debtExtraMinor: int.tryParse(m['debt_extra'] ?? '') ?? 0,
        customNeeds: int.tryParse(m['pct_needs'] ?? '') ?? 40,
        customWants: int.tryParse(m['pct_wants'] ?? '') ?? 10,
        customSavings: int.tryParse(m['pct_savings'] ?? '') ?? 50,
      );

  final bool onboarded;
  final String name;
  final Currency currency;
  final int netIncomeMinor;
  final String profileId;
  final String frequency;
  final int payDay;
  final int xp;
  final bool dark;
  final double pygPerUsd;
  final int reminderHour;
  final bool reminders;
  final String pinHash;
  final String pinSalt;
  final String debtStrategy;
  final int debtExtraMinor;
  final int customNeeds;
  final int customWants;
  final int customSavings;

  bool get hasPin => pinHash.isNotEmpty;

  Money get netIncome => Money(netIncomeMinor, currency);
  SavingsProfile get profile =>
      SavingsProfile.byId(profileId, needs: customNeeds, wants: customWants, savings: customSavings);
  Fx get fx => Fx(pygPerUsd);
  int get level => Gamification.levelForXp(xp);
}

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(dbProvider).watchSettings().map(AppSettings.fromMap);
});

DateTime monthStart(DateTime d) => DateTime(d.year, d.month);

final monthTxnsProvider = StreamProvider<List<Txn>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(dbProvider)
      .watchTxnsBetween(monthStart(now), DateTime(now.year, now.month + 1));
});

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(dbProvider).watchCategories(),
);

final goalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(dbProvider).watchGoals(),
);

final loggedDaysProvider = StreamProvider<List<DateTime>>(
  (ref) => ref.watch(dbProvider).watchLoggedDays(),
);

/// Resumen del mes: presupuesto por bloque, gastado y "podés gastar hoy".
class MonthSummary {
  const MonthSummary({
    required this.split,
    required this.spentNeeds,
    required this.spentWants,
    required this.saved,
    required this.extraIncome,
    required this.dailyAllowance,
    required this.daysLeft,
    required this.leftToSpend,
    required this.spentByCategory,
    required this.hasPlan,
    required this.hasIncome,
  });

  final BudgetSplit split;
  final Money spentNeeds, spentWants, saved, extraIncome;
  final Money dailyAllowance, leftToSpend;
  final int daysLeft;
  final Map<int?, Money> spentByCategory;

  /// ¿Hay reparto por porcentajes? (no si eligió "sin porcentaje" o no cargó sueldo)
  final bool hasPlan;

  /// ¿Hay algún ingreso para el mes (sueldo o ingresos anotados)?
  final bool hasIncome;

  Money get spentTotal => spentNeeds + spentWants;

  static MonthSummary compute({
    required AppSettings settings,
    required List<Txn> txns,
    required List<Category> categories,
    required DateTime now,
  }) {
    final cur = settings.currency;
    final zero = Money.zero(cur);
    final split = BudgetSplit.compute(settings.netIncome, settings.profile);
    final blockOf = {for (final c in categories) c.id: c.block};
    var needs = zero, wants = zero, saved = zero, extra = zero;
    final byCat = <int?, Money>{};
    for (final t in txns) {
      final m = settings.fx.convert(Money(t.amountMinor, Currency.fromCode(t.currency)), cur);
      switch (t.kind) {
        case 'income':
          extra += m;
        case 'saving':
          saved += m;
        default:
          final block = blockOf[t.categoryId] ?? 'want';
          if (block == 'need') {
            needs += m;
          } else {
            wants += m;
          }
          byCat[t.categoryId] = (byCat[t.categoryId] ?? zero) + m;
      }
    }
    final daysLeft = FinanceEngine.daysRemainingInMonth(now);
    final plan = settings.profile.hasPlan && settings.netIncome.minor > 0;
    final available = settings.netIncome + extra;
    // Con plan: lo asignado a necesidades + gustos. Sin plan: todo lo que ingresó.
    final budget = plan ? split.needs + split.wants : available;
    final left = (budget - needs - wants).clampMin(zero);
    return MonthSummary(
      split: split,
      spentNeeds: needs,
      spentWants: wants,
      saved: saved,
      extraIncome: extra,
      daysLeft: daysLeft,
      leftToSpend: left,
      hasPlan: plan,
      hasIncome: available.minor > 0,
      dailyAllowance: FinanceEngine.dailyAllowance(
        variableBudget: budget,
        spentSoFar: needs + wants,
        daysRemainingInclToday: daysLeft,
      ),
      spentByCategory: byCat,
    );
  }
}

final monthSummaryProvider = Provider<AsyncValue<MonthSummary>>((ref) {
  final s = ref.watch(settingsProvider);
  final t = ref.watch(monthTxnsProvider);
  final c = ref.watch(categoriesProvider);
  if (s.hasError) return AsyncError(s.error!, s.stackTrace ?? StackTrace.empty);
  if (!s.hasValue || !t.hasValue || !c.hasValue) return const AsyncLoading();
  return AsyncData(MonthSummary.compute(
    settings: s.requireValue,
    txns: t.requireValue,
    categories: c.requireValue,
    now: ref.watch(clockProvider)(),
  ));
});

/// Guarda varios ajustes de una vez.
Future<void> saveSettings(AppDatabase db, Map<String, String> values) async {
  for (final e in values.entries) {
    await db.setSetting(e.key, e.value);
  }
}

final recurringsProvider = StreamProvider<List<Recurring>>(
  (ref) => ref.watch(dbProvider).watchRecurrings(),
);

/// Movimientos de los últimos 6 meses (informes).
final recentTxnsProvider = StreamProvider<List<Txn>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(dbProvider).watchTxnsSince(DateTime(now.year, now.month - 5));
});

final debtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(dbProvider).watchDebts(),
);

final habitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(dbProvider).watchHabits(),
);
