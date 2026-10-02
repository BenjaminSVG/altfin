import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/finance_engine.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';
import '../habits/habits_screen.dart';
import '../plan/plan_screen.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final summary = ref.watch(monthSummaryProvider).value;
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (settings == null || summary == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cur = settings.currency;
    Money spentOf(int id) => summary.spentByCategory[id] ?? Money.zero(cur);
    double ratio(Money a, Money b) => b.minor == 0 ? 0 : a.minor / b.minor;

    // La categoría más cerca (o más pasada) de su límite, para el mensaje de Finn.
    Category? hot;
    var hotRatio = 0.0;
    for (final x in cats) {
      if (x.monthlyLimitMinor == null || x.monthlyLimitMinor == 0) continue;
      final r = spentOf(x.id).minor / x.monthlyLimitMinor!;
      if (r > hotRatio) {
        hot = x;
        hotRatio = r;
      }
    }

    Widget ring(String label, Money spent, Money total, String tone) => Expanded(
          child: AltCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(children: [
              AltRing(
                value: ratio(spent, total),
                size: 78,
                tone: tone,
                child: Text('${(ratio(spent, total) * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(total.format(), style: numStyle(11, color: c.muted, weight: FontWeight.w700)),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuesto', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        if (summary.hasPlan)
        Row(children: [
          ring('Necesidades', summary.spentNeeds, summary.split.needs, 'b'),
          const SizedBox(width: 10),
          ring('Gustos', summary.spentWants, summary.split.wants, 'o'),
          const SizedBox(width: 10),
          ring('Ahorro', summary.saved, summary.split.savings, 'g'),
        ])
        else
          AltCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen())),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sin porcentajes de ahorro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Gastaste ${summary.spentTotal.format()} este mes. Tocá para armar un plan de ahorro cuando quieras.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
            ]),
          ),
        const SizedBox(height: 14),
        AltCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
          child: Row(children: [
            const IconTile('bus', tone: 'b', size: 48),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Autobús y gastos repetitivos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text('Veces al día, precio y días: se anotan solos.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: c.muted),
          ]),
        ),
        const SizedBox(height: 14),
        AltCard(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Column(children: [
            Row(children: [
              const Text('Por categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('tocá una para poner límite', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            for (final x in cats)
              _catRow(context, ref, x, spentOf(x.id), cur),
          ]),
        ),
        if (hot != null && hotRatio >= .8) ...[
          const SizedBox(height: 14),
          AltCard(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              const FinnView(pose: FinnPose.worry, size: 46),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${hot.name} va al ${(hotRatio * 100).round()} %. ¿Probamos bajar un poco esta semana?',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _catRow(BuildContext context, WidgetRef ref, Category x, Money spent, Currency cur) {
    final limit = x.monthlyLimitMinor == null ? null : Money(x.monthlyLimitMinor!, cur);
    final status = limit == null ? BudgetStatus.ok : FinanceEngine.budgetStatus(spent: spent, limit: limit);
    final bar = switch (status) {
      BudgetStatus.over => 'r',
      BudgetStatus.warning => 'o',
      _ => x.tone == 'b' ? 'b' : 'g',
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _editLimit(context, ref, x, cur),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          IconTile(x.icon, tone: x.tone, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(children: [
              Row(children: [
                Text(x.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const Spacer(),
                Text(limit == null ? spent.format() : '${spent.format()} / ${limit.format(withSymbol: false)}',
                    style: numStyle(13, weight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              AltBar(value: limit == null || limit.minor == 0 ? 0 : spent.minor / limit.minor, tone: bar),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _editLimit(BuildContext context, WidgetRef ref, Category x, Currency cur) async {
    final ctl = TextEditingController(
      text: x.monthlyLimitMinor == null ? '' : '${x.monthlyLimitMinor! ~/ cur.factor}',
    );
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Límite de ${x.name}'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Sin límite'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Guardar')),
        ],
      ),
    );
    if (res == null) return;
    final v = parseAmount(res);
    await ref.read(dbProvider).setCategoryLimit(x.id, v == null || v == 0 ? null : v * cur.factor);
  }
}
