import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/finance_engine.dart';
import '../../domain/gamification.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/icons/app_icon.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';
import '../budget/budget_screen.dart';
import '../plan/plan_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final summary = ref.watch(monthSummaryProvider).value;
    final txns = ref.watch(monthTxnsProvider).value ?? const <Txn>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final logged = ref.watch(loggedDaysProvider).value ?? const <DateTime>[];
    if (settings == null || summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final now = ref.watch(clockProvider)();
    final streak = Gamification.currentStreak(logged, now);
    final loggedToday = logged.any((d) => dayOnly(d) == dayOnly(now));
    final budget = summary.split.needs + summary.split.wants;
    final used = budget.minor == 0 ? 0.0 : summary.spentTotal.minor / budget.minor;
    final noIncome = !summary.hasIncome;
    final pose = noIncome
        ? FinnPose.think
        : (used >= 1 ? FinnPose.worry : (used >= .8 ? FinnPose.think : FinnPose.happy));
    void openPlan() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen()));
    final hello = settings.name.isEmpty ? 'Buen día' : 'Buen día, ${settings.name}';
    final catById = {for (final x in cats) x.id: x};

    final header = Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hello, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
              Text(monthTitle(now), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
          ),
          Pill('$streak', tone: 'o', icon: 'flame'),
        ]);
    final hero = GestureDetector(
        onTap: noIncome ? openPlan : null,
        child: MintCard(
          padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
          child: Row(children: [
            FinnView(pose: pose, size: 92),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(noIncome ? 'SIN INGRESOS CARGADOS' : 'PODÉS GASTAR HOY', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(noIncome ? '${settings.currency.symbol} —' : fmt(summary.dailyAllowance), style: numStyle(34)),
                ),
                Text(
                  _finnLine(used, summary, settings),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ]),
            ),
          ]),
        ));
    final plan = AltCard(
          onTap: summary.hasPlan ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen())) : openPlan,
          child: Column(children: [
            Row(children: [
              const Text('Tu plan del mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('día ${now.day} de ${DateTime(now.year, now.month + 1, 0).day}',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            if (summary.hasPlan) ...[
              _planRow('home', 'Necesidades', summary.spentNeeds, summary.split.needs, 'b'),
              const SizedBox(height: 10),
              _planRow('clapper', 'Gustos', summary.spentWants, summary.split.wants, 'o'),
              const SizedBox(height: 10),
              _planRow('sprout', 'Ahorro e inversión', summary.saved, summary.split.savings, 'g'),
            ] else ...[
              _plainRow('home', 'Necesidades', summary.spentNeeds),
              const SizedBox(height: 8),
              _plainRow('clapper', 'Gustos', summary.spentWants),
              const SizedBox(height: 8),
              _plainRow('sprout', 'Ahorro e inversión', summary.saved),
              const SizedBox(height: 10),
              Text(
                noIncome
                    ? 'Sin sueldo cargado por ahora. Tocá acá cuando quieras agregarlo.'
                    : 'Sin porcentajes. Tocá acá si querés armar un plan de ahorro.',
                style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ]),
        );
    final moves = AltCard(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Row(children: [
                const Text('Últimos movimientos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${txns.length} este mes', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            if (txns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('Todavía no anotaste nada. Tocá el + para empezar.',
                    style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
              )
            else
              Dividers(children: [
                for (final t in txns.take(3)) txnRow(t, catById[t.categoryId], now),
              ]),
          ]),
        );
    final streakCard = _streakCard(context, ref, logged, streak, loggedToday, now);

    // Celular: una columna.
    if (MediaQuery.sizeOf(context).width < 900) {
      const gap = SizedBox(height: 14);
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [header, gap, hero, gap, plan, gap, moves, gap, streakCard],
      );
    }

    // PC: panel con varias columnas.
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final goal = goals.isEmpty ? null : goals.first;
    final savedRatio = summary.split.savings.minor == 0 ? 0.0 : summary.saved.minor / summary.split.savings.minor;
    final savingsCard = !summary.hasPlan
        ? AltCard(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ahorro del mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(summary.saved), style: numStyle(26))),
              const SizedBox(height: 4),
              Text('Sin porcentaje definido', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          )
        : AltCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Ahorro del mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const Spacer(),
          Pill('${(savedRatio * 100).round()} %'),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          AltRing(
            value: savedRatio,
            size: 100,
            child: Text('${(savedRatio * 100).round()}%', style: numStyle(18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(summary.saved), style: numStyle(22))),
              Text('de ${fmt(summary.split.savings)}',
                  style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ]),
    );
    Widget goalCard() {
      if (goal == null) {
        return AltCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tu primera meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Creá una meta (viaje, laptop, fondo de emergencia) en la sección Metas.',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
          ]),
        );
      }
      final target = Money(goal.targetMinor, settings.currency);
      final saved = Money(goal.savedMinor, settings.currency);
      final v = target.minor == 0 ? 0.0 : saved.minor / target.minor;
      return AltCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Meta: ${goal.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            Pill('${(v * 100).round()} %', tone: 'b'),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            IconTile(goal.icon, tone: goal.tone, size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(saved), style: numStyle(22))),
                const SizedBox(height: 6),
                AltBar(value: v, tone: goal.tone == 'o' ? 'o' : (goal.tone == 'g' ? 'g' : 'b'), height: 10),
                const SizedBox(height: 4),
                Text('de ${fmt(target)}', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ]),
      );
    }

    const hgap = SizedBox(width: 16);
    const vgap = SizedBox(height: 16);
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      children: [
        header,
        vgap,
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 6, child: hero),
            hgap,
            Expanded(flex: 4, child: savingsCard),
            hgap,
            Expanded(flex: 4, child: goalCard()),
          ]),
        ),
        vgap,
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 6, child: plan),
            hgap,
            Expanded(flex: 5, child: moves),
          ]),
        ),
        vgap,
        streakCard,
      ],
    );
  }

  String _finnLine(double used, MonthSummary s, AppSettings st) {
    if (!s.hasIncome) return 'Cuando tengas ingresos, cargalos y te digo cuánto podés gastar.';
    if (used >= 1) return 'Te pasaste del plan. Mañana lo ajustamos juntos.';
    if (used >= .8) return 'Vamos cerca del límite. ¡Con cuidado!';
    return '¡Vas bien! Te quedan ${fmt(s.leftToSpend)} para ${s.daysLeft} días.';
  }

  Widget _plainRow(String icon, String name, Money spent) => Row(children: [
        AppIcon(icon, size: 18),
        const SizedBox(width: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const Spacer(),
        Text(fmt(spent), style: numStyle(13, weight: FontWeight.w700)),
      ]);

  Widget _planRow(String icon, String name, Money spent, Money total, String tone) {
    final status = tone == 'g' ? BudgetStatus.ok : FinanceEngine.budgetStatus(spent: spent, limit: total);
    final bar = tone == 'g'
        ? 'g'
        : (status == BudgetStatus.over ? 'r' : (status == BudgetStatus.warning ? 'o' : tone));
    final v = total.minor == 0 ? 0.0 : spent.minor / total.minor;
    return Column(children: [
      Row(children: [
        AppIcon(icon, size: 18),
        const SizedBox(width: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        const Spacer(),
        Text('${fmt(spent)} / ${total.format(withSymbol: false)}', style: numStyle(12, weight: FontWeight.w700)),
      ]),
      const SizedBox(height: 5),
      AltBar(value: v, tone: bar),
    ]);
  }

  Widget _streakCard(BuildContext context, WidgetRef ref, List<DateTime> logged, int streak, bool loggedToday, DateTime now) {
    final c = context.alt;
    final monday = dayOnly(now).subtract(Duration(days: now.weekday - 1));
    final set = logged.map(dayOnly).toSet();
    const names = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return AltCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(children: [
        Row(children: [
          const Text('Tu racha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          const AppIcon('flame', size: 18),
          const Spacer(),
          Text('$streak ${streak == 1 ? 'día' : 'días'} seguidos',
              style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (var i = 0; i < 7; i++)
            _dayDot(c, names[i], monday.add(Duration(days: i)), set, now),
        ]),
        if (!loggedToday) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final db = ref.read(dbProvider);
              await db.markNoSpendDay(now);
              final xp = ref.read(settingsProvider).value?.xp ?? 0;
              await db.setSetting('xp', '${xp + Gamification.xpPerCompleteDay}');
            },
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.blueSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Hoy no gasté  ·  +${Gamification.xpPerCompleteDay} XP',
                  style: TextStyle(color: c.blue, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _dayDot(AltColors c, String letter, DateTime day, Set<DateTime> logged, DateTime now) {
    final done = logged.contains(day);
    final today = day == dayOnly(now);
    return Column(children: [
      Text(letter, style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 11)),
      const SizedBox(height: 4),
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? c.green : (today ? c.orangeSoft : c.line),
          border: today && !done ? Border.all(color: c.orange, width: 3) : null,
        ),
        child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
      ),
    ]);
  }
}

/// Fila de movimiento reutilizable (Inicio y Movimientos).
Widget txnRow(Txn t, Category? cat, DateTime now, {VoidCallback? onLongPress}) {
  final m = Money(t.amountMinor, Currency.fromCode(t.currency));
  final isIncome = t.kind == 'income';
  final isSaving = t.kind == 'saving';
  final icon = isIncome ? 'briefcase' : (isSaving ? 'sprout' : (cat?.icon ?? 'tag'));
  final tone = isIncome || isSaving ? 'g' : (cat?.tone ?? 'p');
  final title = t.note.isNotEmpty ? t.note : (isIncome ? 'Ingreso' : (isSaving ? 'Ahorro' : (cat?.name ?? 'Gasto')));
  final sub = '${dayLabel(t.date, now)} · ${isIncome ? 'Ingreso' : (isSaving ? 'Ahorro' : (cat?.name ?? 'Sin categoría'))}';
  return AmountRow(
    icon: icon,
    tone: tone,
    title: title,
    subtitle: sub,
    amount: '${isIncome ? '+' : (isSaving ? '' : '−')}${m.format()}',
    positive: isIncome,
    onLongPress: onLongPress,
  );
}
