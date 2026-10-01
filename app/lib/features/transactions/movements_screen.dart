import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';
import '../home/home_screen.dart';

class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key});

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final txns = ref.watch(monthTxnsProvider).value ?? const <Txn>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final settings = ref.watch(settingsProvider).value;
    final catById = {for (final x in cats) x.id: x};
    final now = ref.watch(clockProvider)();
    final list = txns.where((t) => filter == 'all' || (filter == 'expense' ? t.kind == 'expense' : t.kind == 'income')).toList();

    final groups = <DateTime, List<Txn>>{};
    for (final t in list) {
      groups.putIfAbsent(dayOnly(t.date), () => []).add(t);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text('Movimientos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          AltChip('Todos', selected: filter == 'all', onTap: () => setState(() => filter = 'all')),
          AltChip('Gastos', selected: filter == 'expense', onTap: () => setState(() => filter = 'expense')),
          AltChip('Ingresos', selected: filter == 'income', onTap: () => setState(() => filter = 'income')),
          AltChip(monthTitle(now)),
        ]),
        const SizedBox(height: 14),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(child: Text('Sin movimientos todavía.', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700))),
          ),
        for (final d in days) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
            child: Row(children: [
              Text(dayLabel(d, now).toUpperCase(), style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
              const Spacer(),
              Text(_dayTotal(groups[d]!, settings), style: numStyle(12, color: c.muted, weight: FontWeight.w700)),
            ]),
          ),
          AltCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Dividers(children: [
              for (final t in groups[d]!)
                txnRow(t, catById[t.categoryId], now, onLongPress: () => _confirmDelete(context, t)),
            ]),
          ),
        ],
        if (list.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text('Mantené apretado un movimiento para borrarlo.',
                textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  String _dayTotal(List<Txn> items, AppSettings? s) {
    if (s == null) return '';
    var total = Money.zero(s.currency);
    for (final t in items) {
      final m = s.fx.convert(Money(t.amountMinor, Currency.fromCode(t.currency)), s.currency);
      if (t.kind == 'income') {
        total += m;
      } else if (t.kind == 'expense') {
        total -= m;
      }
    }
    return total.isZero ? '' : '${total.isNegative ? '−' : '+'}${Money(total.minor.abs(), s.currency).format()}';
  }

  Future<void> _confirmDelete(BuildContext context, Txn t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Borrar movimiento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true) await ref.read(dbProvider).deleteTxn(t.id);
  }
}
