import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/finance_engine.dart';
import '../../domain/gamification.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../debts/debts_screen.dart';
import '../grow/grow_screen.dart';
import '../networth/net_worth_screen.dart';
import '../shared/shared_screen.dart';
import 'emergency_fund_screen.dart';

const _goalIcons = [
  ('plane', 'b'),
  ('laptop', 'o'),
  ('villa', 'g'),
  ('home', 'b'),
  ('backpack', 'p'),
  ('card', 'b'),
  ('trophy', 'o'),
  ('sprout', 'g'),
];

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final settings = ref.watch(settingsProvider).value;
    final summary = ref.watch(monthSummaryProvider).value;
    final cur = settings?.currency ?? Currency.pyg;
    final monthlySaving = summary?.split.savings ?? Money.zero(cur);

    return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
      Row(children: [
        const Text('Mis metas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const Spacer(),
        GestureDetector(onTap: () => _addGoal(context, ref, cur), child: const Pill('+ Nueva')),
      ]),
      const SizedBox(height: 14),
      AltCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GrowScreen())),
        child: Row(children: [
          const FinnView(pose: FinnPose.rich, size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Simulador de crecimiento', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Mirá cuánto puede crecer tu plata con interés compuesto.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
      const SizedBox(height: 12),
      AltCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebtsScreen())),
        child: Row(children: [
          const IconTile('card', tone: 'b', size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deudas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Armá tu plan para salir de ellas: avalancha o bola de nieve.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
      const SizedBox(height: 12),
      AltCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NetWorthScreen())),
        child: Row(children: [
          const IconTile('chart', tone: 'g', size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Patrimonio neto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Lo que tenés menos lo que debés, mes a mes.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
      const SizedBox(height: 12),
      AltCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SharedScreen())),
        child: Row(children: [
          const IconTile('exchange', tone: 'o', size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gastos compartidos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Dividí cuentas con amigos y mirá quién le debe a quién.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
      const SizedBox(height: 12),
      AltCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmergencyFundScreen())),
        child: Row(children: [
          const IconTile('lifebuoy', tone: 'b', size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fondo de emergencia', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('Calculá cuánto guardar para imprevistos: 3, 6 o 9 meses de gastos.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
      const SizedBox(height: 14),
      if (goals.isEmpty)
        AltCard(
          child: Column(children: [
            const FinnView(pose: FinnPose.think, size: 100),
            const SizedBox(height: 8),
            Text('Todavía no tenés metas. Creá una (viaje, laptop, fondo de emergencia) y yo te ayudo a llegar.',
                textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
          ]),
        ),
      for (final g in goals) ...[
        _goalCard(context, ref, g, cur, monthlySaving),
        const SizedBox(height: 12),
      ],
    ]);
  }

  Widget _goalCard(BuildContext context, WidgetRef ref, Goal g, Currency cur, Money monthlySaving) {
    final c = context.alt;
    final target = Money(g.targetMinor, cur);
    final saved = Money(g.savedMinor, cur);
    final v = target.minor == 0 ? 0.0 : saved.minor / target.minor;
    final months = FinanceEngine.monthsToGoal(target: target, current: saved, monthlySaving: monthlySaving);
    final eta = v >= 1
        ? '¡Meta cumplida!'
        : (months == null ? 'Sin ahorro mensual' : 'Listo en ~$months ${months == 1 ? 'mes' : 'meses'}');
    return AltCard(
      onTap: () => _contribute(context, ref, g, cur),
      child: Row(children: [
        IconTile(g.icon, tone: g.tone, size: 54),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              Pill(eta, tone: v >= 1 ? 'g' : 'b'),
            ]),
            const SizedBox(height: 8),
            AltBar(value: v, tone: g.tone == 'o' ? 'o' : (g.tone == 'g' ? 'g' : 'b'), height: 12),
            const SizedBox(height: 5),
            Row(children: [
              Text('${saved.format()} / ${target.format(withSymbol: false)}',
                  style: numStyle(12, color: c.muted, weight: FontWeight.w700)),
              const Spacer(),
              Text('${(v * 100).round()}%', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Future<void> _contribute(BuildContext context, WidgetRef ref, Goal g, Currency cur) async {
    final ctl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sumar a "${g.name}"'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(prefixText: '${cur.symbol} '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Sumar')),
        ],
      ),
    );
    final v = int.tryParse(res ?? '');
    if (v == null || v <= 0) return;
    final db = ref.read(dbProvider);
    await db.addToGoal(g.id, v * cur.factor);
    final reached = g.savedMinor + v * cur.factor >= g.targetMinor && g.savedMinor < g.targetMinor;
    if (reached) {
      final xp = ref.read(settingsProvider).value?.xp ?? 0;
      await db.setSetting('xp', '${xp + Gamification.xpPerGoal}');
    }
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref, Currency cur) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var icon = 0;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nueva meta'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Nombre (ej. Viaje a Brasil)')),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Cuánto necesitás'),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var i = 0; i < _goalIcons.length; i++)
                GestureDetector(
                  onTap: () => setS(() => icon = i),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: icon == i ? ctx.alt.green : Colors.transparent, width: 3),
                    ),
                    child: IconTile(_goalIcons[i].$1, tone: _goalIcons[i].$2, size: 38),
                  ),
                ),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final v = int.tryParse(amount.text);
                if (name.text.trim().isEmpty || v == null || v <= 0) return;
                await ref.read(dbProvider).addGoal(GoalsCompanion.insert(
                      name: name.text.trim(),
                      icon: _goalIcons[icon].$1,
                      tone: Value(_goalIcons[icon].$2),
                      targetMinor: v * cur.factor,
                      currency: cur.code,
                    ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
