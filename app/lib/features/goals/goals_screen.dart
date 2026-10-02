import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/finance_engine.dart';
import '../../domain/gamification.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';
import '../balance/balance_screen.dart';
import '../debts/debts_screen.dart';
import '../periodic/periodic_screen.dart';
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
      const SizedBox(height: 14),
      Text('HERRAMIENTAS', style: TextStyle(color: c.muted, fontWeight: FontWeight.w900, fontSize: 12)),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, box) {
        final w = (box.maxWidth - 10) / 2;
        Widget tile(String icon, String tone, String title, String sub, Widget screen) => SizedBox(
              width: w,
              child: AltCard(
                padding: const EdgeInsets.all(12),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconTile(icon, tone: tone, size: 40),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            );
        return Wrap(spacing: 10, runSpacing: 10, children: [
          tile('coin', 'g', 'Mi balance', 'Cuánto tengo y a dónde va', const BalanceScreen()),
          tile('bus', 'o', 'Gastos periódicos', 'Por día, semana o mes', const PeriodicScreen()),
          tile('sprout', 'g', 'Simulador', 'Interés compuesto', const GrowScreen()),
          tile('card', 'b', 'Deudas', 'Avalancha o bola de nieve', const DebtsScreen()),
          tile('chart', 'g', 'Patrimonio neto', 'Activos menos deudas', const NetWorthScreen()),
          tile('exchange', 'o', 'Compartidos', 'Dividir con amigos', const SharedScreen()),
          tile('lifebuoy', 'b', 'Fondo de emergencia', '3, 6 o 9 meses', const EmergencyFundScreen()),
        ]);
      }),
    ]);
  }

  Widget _goalCard(BuildContext context, WidgetRef ref, Goal g, Currency cur, Money monthlySaving) {
    final c = context.alt;
    final target = Money(g.targetMinor, cur);
    final saved = Money(g.savedMinor, cur);
    final v = target.minor == 0 ? 0.0 : saved.minor / target.minor;
    final months = FinanceEngine.monthsToGoal(target: target, current: saved, monthlySaving: monthlySaving);
    final need = FinanceEngine.monthlyNeeded(
        target: target, current: saved, deadline: g.deadline, now: ref.read(clockProvider)());
    final eta = v >= 1
        ? '¡Meta cumplida!'
        : (months == null ? 'Sin ahorro mensual' : 'Listo en ~$months ${months == 1 ? 'mes' : 'meses'}');
    return AltCard(
      onTap: () => _contribute(context, ref, g, cur),
      onLongPress: () => _options(context, ref, g, cur),
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
            if (need != null && need.minor > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Ahorrá ${need.format()} por mes para llegar en ${g.deadline!.month}/${g.deadline!.year}'
                  '${monthlySaving.minor >= need.minor ? ' (vas bien)' : ''}',
                  style: TextStyle(color: c.greenDark, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  /// Menú de la meta (pulsación larga): plazo, monto y borrar.
  Future<void> _options(BuildContext context, WidgetRef ref, Goal g, Currency cur) async {
    final db = ref.read(dbProvider);
    final now = ref.read(clockProvider)();
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ),
          ListTile(
            leading: const Icon(Icons.event_rounded),
            title: const Text('Cambiar plazo'),
            onTap: () async {
              Navigator.pop(ctx);
              final months = await showDialog<int?>(
                context: context,
                builder: (d) => SimpleDialog(title: const Text('¿En cuántos meses?'), children: [
                  SimpleDialogOption(onPressed: () => Navigator.pop(d, 0), child: const Text('Sin fecha')),
                  for (final m in const [3, 6, 12, 24])
                    SimpleDialogOption(onPressed: () => Navigator.pop(d, m), child: Text('$m meses')),
                ]),
              );
              if (months == null) return;
              await db.setGoalDeadline(g.id, months == 0 ? null : DateTime(now.year, now.month + months, now.day));
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Cambiar monto objetivo'),
            onTap: () async {
              Navigator.pop(ctx);
              final ctl = TextEditingController(text: '${g.targetMinor ~/ cur.factor}');
              final res = await showDialog<String>(
                context: context,
                builder: (d) => AlertDialog(
                  title: const Text('Monto objetivo'),
                  content: TextField(
                    controller: ctl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: InputDecoration(prefixText: '${cur.symbol} '),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(d, ctl.text), child: const Text('Guardar')),
                  ],
                ),
              );
              final v = parseAmount(res ?? '');
              if (v != null && v > 0) await db.setGoalTarget(g.id, v * cur.factor);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('Borrar meta'),
            onTap: () async {
              await db.deleteGoal(g.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ]),
      ),
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
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(prefixText: '${cur.symbol} '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Sumar')),
        ],
      ),
    );
    final v = parseAmount(res ?? '');
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
    int? months; // plazo opcional para la meta
    final now = ref.read(clockProvider)();
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
              inputFormatters: [ThousandsFormatter()],
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Cuánto necesitás'),
            ),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text('¿En cuántos meses? (opcional)', style: TextStyle(fontWeight: FontWeight.w800, color: ctx.alt.muted))),
            Wrap(spacing: 6, children: [
              for (final m in const <int?>[null, 3, 6, 12, 24])
                ChoiceChip(label: Text(m == null ? 'Sin fecha' : '$m'), selected: months == m, onSelected: (_) => setS(() => months = m)),
            ]),
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
                final v = parseAmount(amount.text);
                if (name.text.trim().isEmpty || v == null || v <= 0) return;
                await ref.read(dbProvider).addGoal(GoalsCompanion.insert(
                      name: name.text.trim(),
                      icon: _goalIcons[icon].$1,
                      tone: Value(_goalIcons[icon].$2),
                      targetMinor: v * cur.factor,
                      currency: cur.code,
                      deadline: Value(months == null ? null : DateTime(now.year, now.month + months!, now.day)),
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
