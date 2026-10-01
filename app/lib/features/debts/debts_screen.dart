import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/debt_plan.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';

/// Plan de pago de deudas: avalancha (menos intereses) o bola de nieve (más motivación).
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = s.currency;
    final now = ref.watch(clockProvider)();
    final strategy = s.debtStrategy == 'snowball' ? DebtStrategy.snowball : DebtStrategy.avalanche;
    final extra = s.debtExtraMinor;

    int conv(int minor, String from) => s.fx.convert(Money(minor, Currency.fromCode(from)), cur).minor;
    final inputs = [
      for (final d in debts)
        DebtInput(
          id: d.id,
          name: d.name,
          balance: conv(d.balanceMinor, d.currency),
          annualRatePct: d.annualRatePct,
          minPayment: conv(d.minPaymentMinor, d.currency),
        ),
    ];
    final total = inputs.fold<int>(0, (a, d) => a + d.balance);
    final plan = DebtPlanner.simulate(inputs, strategy: strategy, extraMonthly: extra);
    final other = DebtPlanner.simulate(inputs,
        strategy: strategy == DebtStrategy.avalanche ? DebtStrategy.snowball : DebtStrategy.avalanche, extraMonthly: extra);
    final avalanche = strategy == DebtStrategy.avalanche ? plan : other;
    final snowball = strategy == DebtStrategy.snowball ? plan : other;
    final saving = (avalanche != null && snowball != null) ? snowball.totalInterest - avalanche.totalInterest : 0;
    final byId = {for (final d in debts) d.id: d};

    String when(int months) {
      final d = DateTime(now.year, now.month + months);
      return '${monthName(d).substring(0, 3)} ${d.year}';
    }

    final ordered = plan == null
        ? debts
        : [for (final id in plan.order) byId[id]!, ...debts.where((d) => !plan.order.contains(d.id))];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(onTap: () => _add(context, ref, cur), child: const Pill('+ Nueva')),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        if (debts.isEmpty)
          AltCard(
            child: Column(children: [
              const FinnView(pose: FinnPose.happy, size: 110),
              const SizedBox(height: 8),
              const Text('¡Sin deudas cargadas!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Si tenés tarjeta, préstamos o cuotas, cargalas y te armo un plan para salir de ellas lo antes posible.',
                  textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
            ]),
          )
        else ...[
          MintCard(
            child: Row(children: [
              FinnView(pose: plan == null ? FinnPose.worry : FinnPose.happy, size: 80),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('DEBÉS EN TOTAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(Money(total, cur).format(), style: numStyle(30))),
                  Text(
                    plan == null
                        ? 'Con estos pagos no se termina nunca: no alcanzan ni para los intereses.'
                        : (plan.months == 0
                            ? '¡Ya no debés nada!'
                            : 'Libre de deudas en ${plan.months} ${plan.months == 1 ? 'mes' : 'meses'} (${when(plan.months)}).'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          AltCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MÉTODO', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                AltChip('Avalancha', selected: strategy == DebtStrategy.avalanche, onTap: () => ref.read(dbProvider).setSetting('debt_strategy', 'avalanche')),
                AltChip('Bola de nieve', selected: strategy == DebtStrategy.snowball, onTap: () => ref.read(dbProvider).setSetting('debt_strategy', 'snowball')),
              ]),
              const SizedBox(height: 8),
              Text(
                strategy == DebtStrategy.avalanche
                    ? 'Pagás primero la deuda con más interés. Es la que menos plata te cuesta.'
                    : 'Pagás primero la deuda más chica. Das victorias rápidas y te motivás.',
                style: TextStyle(color: c.muted, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const Divider(height: 24),
              Row(children: [
                const Expanded(child: Text('Pago extra por mes', style: TextStyle(fontWeight: FontWeight.w800))),
                GestureDetector(
                  onTap: () => _editExtra(context, ref, cur, extra),
                  child: Pill(Money(extra, cur).format()),
                ),
              ]),
              if (plan != null && plan.months > 0) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Text('Intereses totales', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(Money(plan.totalInterest, cur).format(), style: numStyle(15)),
                ]),
              ],
              if (saving > 0) ...[
                const SizedBox(height: 10),
                Pill('Avalancha te ahorra ${Money(saving, cur).format()} en intereses', tone: 'g'),
              ],
            ]),
          ),
          const SizedBox(height: 14),
          for (final d in ordered)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AltCard(
                onTap: () => _actions(context, ref, d, cur),
                child: Row(children: [
                  const IconTile('card', tone: 'b', size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                        if (plan != null && plan.payoffMonth[d.id] != null)
                          Pill('${plan.order.indexOf(d.id) + 1}º · ${when(plan.payoffMonth[d.id]!)}', tone: plan.order.indexOf(d.id) == 0 ? 'g' : 'b'),
                      ]),
                      const SizedBox(height: 4),
                      Text(Money(d.balanceMinor, Currency.fromCode(d.currency)).format(), style: numStyle(18)),
                      Text('${d.annualRatePct.toStringAsFixed(d.annualRatePct == d.annualRatePct.roundToDouble() ? 0 : 1)} % anual · mínimo ${Money(d.minPaymentMinor, Currency.fromCode(d.currency)).format()}',
                          style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ),
            ),
          Text('Tocá una deuda para registrar un pago o borrarla. Simulación orientativa, no es asesoría financiera.',
              textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, Currency cur) async {
    final name = TextEditingController();
    final balance = TextEditingController();
    final rate = TextEditingController();
    final min = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva deuda'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Nombre (ej. Tarjeta)')),
            TextField(
              controller: balance,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Cuánto debés'),
            ),
            TextField(
              controller: rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(suffixText: '% anual', hintText: 'Tasa de interés (0 si no tiene)'),
            ),
            TextField(
              controller: min,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Pago mínimo por mes'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final b = int.tryParse(balance.text);
              final m = int.tryParse(min.text);
              final r = double.tryParse(rate.text.replaceAll(',', '.')) ?? 0;
              if (name.text.trim().isEmpty || b == null || b <= 0 || m == null || m <= 0 || r < 0) return;
              await ref.read(dbProvider).addDebt(DebtsCompanion.insert(
                    name: name.text.trim(),
                    balanceMinor: b * cur.factor,
                    currency: cur.code,
                    annualRatePct: Value(r),
                    minPaymentMinor: m * cur.factor,
                  ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _editExtra(BuildContext context, WidgetRef ref, Currency cur, int extraMinor) async {
    final ctl = TextEditingController(text: extraMinor == 0 ? '' : '${extraMinor ~/ cur.factor}');
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pago extra por mes'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: '0'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Guardar')),
        ],
      ),
    );
    if (res == null) return;
    await ref.read(dbProvider).setSetting('debt_extra', '${(int.tryParse(res) ?? 0) * cur.factor}');
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, Debt d, Currency cur) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.payments_rounded), title: const Text('Registrar un pago'), onTap: () => Navigator.pop(context, 'pay')),
          ListTile(leading: const Icon(Icons.delete_outline_rounded), title: const Text('Borrar deuda'), onTap: () => Navigator.pop(context, 'del')),
        ]),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'del') {
      await ref.read(dbProvider).deleteDebt(d.id);
    } else if (choice == 'pay') {
      final dc = Currency.fromCode(d.currency);
      final ctl = TextEditingController();
      final res = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Pago a "${d.name}"'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(prefixText: '${dc.symbol} '),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Registrar')),
          ],
        ),
      );
      final v = int.tryParse(res ?? '');
      if (v != null && v > 0) await ref.read(dbProvider).payDebt(d.id, v * dc.factor);
    }
  }
}
