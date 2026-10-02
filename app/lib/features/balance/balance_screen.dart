import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/balance.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';
import '../networth/net_worth_screen.dart';
import '../periodic/periodic_screen.dart';

const _periodTitles = {
  BalancePeriod.day: 'de hoy',
  BalancePeriod.week: 'de esta semana',
  BalancePeriod.month: 'de este mes',
  BalancePeriod.year: 'de este año',
};

/// Dialogo para declarar (o corregir) cuánto dinero tiene la persona ahora.
/// Se usa desde "Mi balance" y desde el inicio.
Future<void> editAvailableMoney(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider).value;
  if (s == null) return;
  final current = ref.read(availableMoneyProvider);
  final ctrl = TextEditingController(
    text: current == null || current.minor <= 0 ? '' : Money(current.minor ~/ s.currency.factor, Currency.pyg).format(withSymbol: false),
  );
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Cuánto dinero tenés ahora?'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Sumá el efectivo, tu cuenta del banco y billeteras. Desde este momento, lo que anotes lo va sumando y restando solo.',
          style: TextStyle(color: ctx.alt.muted, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(prefixText: '${s.currency.symbol} ', hintText: 'Monto total'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        TextButton(
          onPressed: () async {
            final v = parseAmount(ctrl.text);
            if (v == null) return;
            final db = ref.read(dbProvider);
            await db.setSetting('opening_balance', '${v * s.currency.factor}');
            await db.setSetting('opening_at', ref.read(clockProvider)().toIso8601String());
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

/// Mi balance: cuánto dinero tengo y a dónde va, por día, semana, mes o año.
class BalanceScreen extends ConsumerStatefulWidget {
  const BalanceScreen({super.key});

  @override
  ConsumerState<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen> {
  BalancePeriod period = BalancePeriod.month;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final entries = ref.watch(balanceEntriesProvider);
    final available = ref.watch(availableMoneyProvider);
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = s.currency;
    final now = ref.watch(clockProvider)();
    final totals = BalanceEngine.totals(
      entries,
      from: BalanceEngine.start(period, now),
      to: BalanceEngine.end(period, now),
      currency: cur,
    );
    final days = BalanceEngine.elapsedDays(period, now);
    final avgDaily = Money(totals.expense.minor ~/ days, cur);
    final runway = available == null ? null : BalanceEngine.runwayDays(available, avgDaily);
    final catById = {for (final x in cats) x.id: x};
    final byCat = totals.expenseByCategory.entries.toList()..sort((a, b) => b.value.minor.compareTo(a.value.minor));
    final monthTxns = ref.watch(monthTxnsProvider).value ?? const <Txn>[];
    final salaryLogged = monthTxns.any((t) => t.kind == 'income' && t.note == salaryNote);
    final canLogSalary = s.netIncome.minor > 0 && !salaryLogged;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi balance', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
            _hero(context, available, s),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in BalancePeriod.values)
                AltChip(p.label, selected: period == p, onTap: () => setState(() => period = p)),
            ]),
            const SizedBox(height: 14),
            AltCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Resumen ${_periodTitles[period]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                _row(c, 'briefcase', 'g', 'Entró', '+${totals.income.format()}', c.greenDark),
                _row(c, 'cart', 'r', 'Salió', '-${totals.expense.format()}', c.red),
                _row(c, 'sprout', 'g', 'Ahorraste', totals.saving.format(), c.ink),
                Divider(height: 18, thickness: 1.5, color: c.line),
                Row(children: [
                  const Expanded(child: Text('Quedó', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                  Text(totals.net.format(),
                      style: numStyle(20, weight: FontWeight.w900, color: totals.net.isNegative ? c.red : c.greenDark)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            AltCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('GASTO POR DÍA', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w900)),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(avgDaily.format(), style: numStyle(22))),
                      Text('promedio, $days ${days == 1 ? 'día' : 'días'}',
                          style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  if (runway != null)
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('TU DINERO ALCANZA', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w900)),
                        Text('$runway ${runway == 1 ? 'día' : 'días'}', style: numStyle(22)),
                        Text('a este ritmo', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            AltCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('En qué se fue la plata', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (byCat.isEmpty)
                  Text('Todavía no hay gastos ${_periodTitles[period]}.',
                      style: TextStyle(color: c.muted, fontWeight: FontWeight.w700))
                else
                  for (final e in byCat.take(6))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(children: [
                        Row(children: [
                          IconTile(catById[e.key]?.icon ?? 'tag', tone: catById[e.key]?.tone ?? 'p', size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(catById[e.key]?.name ?? 'Sin categoría',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          Text(e.value.format(), style: numStyle(14)),
                        ]),
                        const SizedBox(height: 5),
                        AltBar(value: totals.expense.minor == 0 ? 0 : e.value.minor / totals.expense.minor, height: 7),
                      ]),
                    ),
              ]),
            ),
            const SizedBox(height: 14),
            if (canLogSalary) ...[
              AltCard(
                onTap: () => _logSalary(s),
                child: Row(children: [
                  const IconTile('briefcase', tone: 'g', size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Ya cobré mi sueldo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('Anota ${s.netIncome.format()} como ingreso de este mes',
                          style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  Icon(Icons.add_circle_rounded, color: c.green),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            AltCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PeriodicScreen())),
              child: Row(children: [
                const IconTile('bus', tone: 'o', size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Mis gastos periódicos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Lo que gastás cada día, semana o mes',
                        style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted),
              ]),
            ),
            const SizedBox(height: 10),
            AltCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NetWorthScreen())),
              child: Row(children: [
                const IconTile('chart', tone: 'b', size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Patrimonio neto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Todo lo que tenés menos lo que debés',
                        style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted),
              ]),
            ),
            const SizedBox(height: 14),
            Text(
              'El dinero disponible parte de lo que vos declarás y se actualiza con cada ingreso, gasto y ahorro que anotás. '
              'Los movimientos con fecha anterior a la que lo declaraste no se cuentan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(AltColors c, String icon, String tone, String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          IconTile(icon, tone: tone, size: 34),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
          Text(value, style: numStyle(15, color: color)),
        ]),
      );

  Widget _hero(BuildContext context, Money? available, AppSettings s) {
    final c = context.alt;
    if (available == null) {
      return MintCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const FinnView(pose: FinnPose.think, size: 72),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '¿Cuánto dinero tenés ahora? Cargalo una vez y yo lo voy actualizando con lo que anotes.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          BigButton('CARGAR MI DINERO', onPressed: () => editAvailableMoney(context, ref)),
        ]),
      );
    }
    final at = s.openingAt!;
    return GestureDetector(
      onTap: () => editAvailableMoney(context, ref),
      child: MintCard(
        child: Row(children: [
          FinnView(pose: available.isNegative ? FinnPose.worry : FinnPose.happy, size: 82),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DINERO DISPONIBLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(available.format(), style: numStyle(32, color: available.isNegative ? c.red : null)),
              ),
              Text('Desde el ${at.day} de ${monthName(at)} · tocá para corregir',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _logSalary(AppSettings s) async {
    final db = ref.read(dbProvider);
    final now = ref.read(clockProvider)();
    await db.addTxn(TxnsCompanion.insert(
      kind: 'income',
      amountMinor: s.netIncome.minor,
      currency: s.currency.code,
      categoryId: const Value(null),
      note: const Value(salaryNote),
      date: now,
    ));
  }
}
