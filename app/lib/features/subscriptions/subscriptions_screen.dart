import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/fx.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

/// Gastos que se repiten cada mes: alquiler, internet, Netflix...
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final items = ref.watch(recurringsProvider).value ?? const <Recurring>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final s = ref.watch(settingsProvider).value;
    final cur = s?.currency ?? Currency.pyg;
    final catById = {for (final x in cats) x.id: x};

    final fx = s?.fx ?? const Fx(Fx.defaultRate);
    var total = Money.zero(cur);
    for (final r in items.where((r) => r.active)) {
      total += fx.convert(Money(r.amountMinor, Currency.fromCode(r.currency)), cur);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos fijos', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(onTap: () => _add(context, ref, cats, cur), child: const Pill('+ Nuevo')),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        MintCard(
          child: Row(children: [
            const FinnView(size: 70),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TE COBRAN CADA MES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                FittedBox(fit: BoxFit.scaleDown, child: Text(total.format(), style: numStyle(30))),
                const Text('Se anotan solos el día de cobro.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          AltCard(
            child: Text('Agregá tu alquiler, internet o suscripciones y no te olvidás de anotarlos.',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
          ),
        for (final r in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AltCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(children: [
                IconTile(catById[r.categoryId]?.icon ?? 'tag', tone: catById[r.categoryId]?.tone ?? 'p'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Día ${r.dayOfMonth} · ${Money(r.amountMinor, Currency.fromCode(r.currency)).format()}',
                        style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
                Switch(
                  value: r.active,
                  activeTrackColor: c.green,
                  onChanged: (v) => ref.read(dbProvider).setRecurringActive(r.id, v),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: c.muted),
                  onPressed: () => ref.read(dbProvider).deleteRecurring(r.id),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, List<Category> cats, Currency cur) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var day = 1;
    int? cat = cats.isEmpty ? null : cats.firstWhere((x) => x.name == 'Suscripciones', orElse: () => cats.first).id;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nuevo gasto fijo'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(hintText: 'Nombre (ej. Netflix)')),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Monto'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Se cobra el día'),
                const Spacer(),
                DropdownButton<int>(
                  value: day,
                  items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                  onChanged: (v) => setS(() => day = v ?? 1),
                ),
              ]),
              DropdownButton<int>(
                isExpanded: true,
                value: cat,
                items: [for (final x in cats) DropdownMenuItem(value: x.id, child: Text(x.name))],
                onChanged: (v) => setS(() => cat = v),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final v = parseAmount(amount.text);
                if (name.text.trim().isEmpty || v == null || v <= 0) return;
                final db = ref.read(dbProvider);
                await db.addRecurring(RecurringsCompanion.insert(
                  name: name.text.trim(),
                  amountMinor: v * cur.factor,
                  currency: cur.code,
                  categoryId: Value(cat),
                  dayOfMonth: day,
                ));
                // Si el día de este mes ya pasó, se anota ahora.
                await db.generateDueRecurrings(ref.read(clockProvider)());
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
