import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/net_worth.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

const _icons = ['coin', 'cash', 'home', 'card', 'briefcase', 'chart', 'laptop', 'lock'];

const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// Patrimonio neto: lo que tenés (cuentas, efectivo, bienes, plata en metas)
/// menos lo que debés (deudas), y cómo evoluciona mes a mes.
class NetWorthScreen extends ConsumerWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final nw = ref.watch(netWorthProvider);
    final holdings = ref.watch(holdingsProvider).value ?? const <Holding>[];
    final snaps = ref.watch(netSnapshotsProvider).value ?? const <NetSnapshot>[];
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final debts = ref.watch(debtsProvider).value ?? const <Debt>[];
    if (settings == null || nw == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cur = settings.currency;
    final goalsSaved = goals.fold<Money>(
        Money.zero(cur), (a, g) => a + settings.fx.convert(Money(g.savedMinor, Currency.fromCode(g.currency)), cur));
    final debtsTotal = debts.fold<Money>(
        Money.zero(cur), (a, d) => a + settings.fx.convert(Money(d.balanceMinor, Currency.fromCode(d.currency)), cur));
    final series = [for (final s in snaps) s.netMinor];
    final delta = NetWorth.change(series);
    final negative = nw.net.minor < 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Patrimonio neto', style: TextStyle(fontWeight: FontWeight.w900))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, cur),
        backgroundColor: c.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('AGREGAR', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TU PATRIMONIO', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(nw.net.format(), style: numStyle(32, weight: FontWeight.w900, color: negative ? c.red : null)),
            if (series.length >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${delta >= 0 ? '+' : '-'} ${Money(delta.abs(), cur).format()} desde ${_label(snaps.first.month)}',
                  style: TextStyle(color: delta >= 0 ? c.greenDark : c.red, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _stat(c, 'Tenés', nw.assets.format(), c.greenDark)),
              Expanded(child: _stat(c, 'Debés', nw.liabilities.format(), c.red)),
            ]),
            if (snaps.length >= 2) ...[
              const SizedBox(height: 16),
              SizedBox(height: 90, child: _Bars(snaps: snaps)),
            ],
          ]),
        ),
        const SizedBox(height: 14),
        if (holdings.isEmpty && goalsSaved.minor == 0 && debtsTotal.minor == 0)
          AltCard(
            child: Row(children: [
              const FinnView(pose: FinnPose.think, size: 64),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sumá lo que tenés (efectivo, cuenta, un auto) y lo que debés. '
                  'Cada mes guardo tu patrimonio para que veas cómo crece.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ]),
          ),
        AltCard(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Column(children: [
            Row(children: [
              const Text('Detalle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('tocá para cambiar el monto', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            for (final h in holdings) _holdingRow(context, ref, h, cur),
            if (goalsSaved.minor > 0)
              _autoRow(c, 'coin', 'Ahorrado en metas', 'se suma solo', goalsSaved.format(), c.greenDark),
            if (debtsTotal.minor > 0)
              _autoRow(c, 'card', 'Deudas', 'de la pantalla Deudas', '- ${debtsTotal.format()}', c.red),
          ]),
        ),
      ]),
    );
  }

  String _label(String month) {
    final p = month.split('-');
    return '${_months[int.parse(p[1]) - 1]} ${p[0]}';
  }

  Widget _stat(AltColors c, String label, String value, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        Text(value, style: numStyle(16, weight: FontWeight.w900, color: color)),
      ]);

  Widget _autoRow(AltColors c, String icon, String name, String sub, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          IconTile(icon, tone: 'g', size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(sub, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          Text(value, style: numStyle(14, weight: FontWeight.w800, color: color)),
        ]),
      );

  Widget _holdingRow(BuildContext context, WidgetRef ref, Holding h, Currency main) {
    final c = context.alt;
    final m = Money(h.amountMinor, Currency.fromCode(h.currency));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _edit(context, ref, main, existing: h),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          IconTile(h.icon, tone: h.isLiability ? 'r' : 'g', size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(h.isLiability ? 'Debo' : 'Tengo', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
          Text('${h.isLiability ? '- ' : ''}${m.format()}',
              style: numStyle(14, weight: FontWeight.w800, color: h.isLiability ? c.red : c.greenDark)),
        ]),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Currency main, {Holding? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final amountCur = existing == null ? main : Currency.fromCode(existing.currency);
    final amount = TextEditingController(
        text: existing == null ? '' : Money(existing.amountMinor ~/ amountCur.factor, Currency.pyg).format(withSymbol: false));
    var liability = existing?.isLiability ?? false;
    var currency = amountCur;
    var icon = existing?.icon ?? _icons.first;
    final db = ref.read(dbProvider);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'Nuevo' : 'Editar'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                for (final opt in [(false, 'Tengo'), (true, 'Debo')])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Center(child: Text(opt.$2)),
                        selected: liability == opt.$1,
                        onSelected: (_) => setS(() => liability = opt.$1),
                      ),
                    ),
                  ),
              ]),
              TextField(controller: name, decoration: const InputDecoration(hintText: 'Nombre (ej. Cuenta, Efectivo)')),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: InputDecoration(prefixText: '${currency.symbol} ', hintText: 'Monto'),
              ),
              const SizedBox(height: 8),
              Row(children: [
                for (final cc in Currency.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Center(child: Text(cc.code)),
                        selected: currency == cc,
                        onSelected: (_) => setS(() => currency = cc),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final i in _icons)
                  GestureDetector(
                    onTap: () => setS(() => icon = i),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: icon == i ? ctx.alt.green : Colors.transparent, width: 3),
                      ),
                      child: IconTile(i, tone: 'g', size: 34),
                    ),
                  ),
              ]),
            ]),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () async {
                  await db.deleteHolding(existing.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Borrar'),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final v = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
                if (name.text.trim().isEmpty || v == null || v <= 0) return;
                final minor = v * currency.factor;
                if (existing == null) {
                  await db.addHolding(HoldingsCompanion.insert(
                    name: name.text.trim(),
                    icon: Value(icon),
                    isLiability: Value(liability),
                    amountMinor: minor,
                    currency: currency.code,
                  ));
                } else {
                  await (db.update(db.holdings)..where((t) => t.id.equals(existing.id))).write(HoldingsCompanion(
                    name: Value(name.text.trim()),
                    icon: Value(icon),
                    isLiability: Value(liability),
                    amountMinor: Value(minor),
                    currency: Value(currency.code),
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barras con el patrimonio de cada mes (hasta los últimos 12).
class _Bars extends StatelessWidget {
  const _Bars({required this.snaps});

  final List<NetSnapshot> snaps;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final list = snaps.length > 12 ? snaps.sublist(snaps.length - 12) : snaps;
    final maxAbs = list.map((s) => s.netMinor.abs()).fold<int>(1, (a, b) => b > a ? b : a);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (final s in list)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                height: 6 + 60 * (s.netMinor.abs() / maxAbs),
                decoration: BoxDecoration(
                  color: s.netMinor < 0 ? c.red : c.green,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Text(_months[int.parse(s.month.split('-')[1]) - 1],
                  style: TextStyle(color: c.muted, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
    ]);
  }
}
