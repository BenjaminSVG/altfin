import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/split_bill.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

/// Gastos compartidos con amigos (estilo Splitwise): quién le debe a quién.
class SharedScreen extends ConsumerWidget {
  const SharedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final friends = ref.watch(friendsProvider).value ?? const <Friend>[];
    final entries = ref.watch(shareEntriesProvider).value ?? const <ShareEntry>[];
    if (settings == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = settings.currency;

    int balanceOf(int friendId) => entries
        .where((e) => e.friendId == friendId)
        .fold(0, (a, e) => a + settings.fx.convert(Money(e.amountMinor, Currency.fromCode(e.currency)), cur).minor);
    final balances = {for (final f in friends) f.id: balanceOf(f.id)};
    final owedToMe = balances.values.where((b) => b > 0).fold(0, (a, b) => a + b);
    final iOwe = -balances.values.where((b) => b < 0).fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos compartidos', style: TextStyle(fontWeight: FontWeight.w900))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _divide(context, ref, cur, friends),
        backgroundColor: c.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.call_split_rounded),
        label: const Text('DIVIDIR GASTO', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
        AltCard(
          child: Row(children: [
            Expanded(child: _stat(c, 'Te deben', Money(owedToMe, cur).format(), c.greenDark)),
            Expanded(child: _stat(c, 'Debés', Money(iOwe, cur).format(), c.red)),
          ]),
        ),
        const SizedBox(height: 14),
        if (friends.isEmpty)
          AltCard(
            child: Row(children: [
              const FinnView(pose: FinnPose.think, size: 64),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Salieron a comer o pagaron un Uber entre varios? Tocá "Dividir gasto", '
                  'sumá a tus amigos y yo llevo la cuenta de quién le debe a quién.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ]),
          ),
        for (final f in friends) ...[
          AltCard(
            onTap: () => _detail(context, ref, f, entries.where((e) => e.friendId == f.id).toList(), balances[f.id]!, cur),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: c.greenSoft,
                child: Text(f.name.characters.first.toUpperCase(),
                    style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(SplitBill.describe(f.name, balances[f.id]!, Money(balances[f.id]!.abs(), cur).format()),
                      style: TextStyle(
                          color: balances[f.id]! > 0 ? c.greenDark : (balances[f.id]! < 0 ? c.red : c.muted),
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded),
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ]),
    );
  }

  Widget _stat(AltColors c, String label, String value, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: TextStyle(color: c.muted, fontWeight: FontWeight.w900, fontSize: 12)),
        Text(value, style: numStyle(20, weight: FontWeight.w900, color: color)),
      ]);

  // ---- Detalle de un amigo: historial, liquidar y borrar ----
  Future<void> _detail(
      BuildContext context, WidgetRef ref, Friend f, List<ShareEntry> list, int balance, Currency cur) async {
    final db = ref.read(dbProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final c = ctx.alt;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(SplitBill.describe(f.name, balance, Money(balance.abs(), cur).format()),
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView(shrinkWrap: true, children: [
                  for (final e in list)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.note.isEmpty ? 'Movimiento' : e.note, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${e.date.day}/${e.date.month}/${e.date.year}'),
                      trailing: Text(
                        '${e.amountMinor > 0 ? '+' : '-'} ${Money(e.amountMinor.abs(), Currency.fromCode(e.currency)).format()}',
                        style: numStyle(14, weight: FontWeight.w800, color: e.amountMinor > 0 ? c.greenDark : c.red),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 10),
              if (balance != 0)
                BigButton(balance > 0 ? 'ME PAGÓ' : 'LE PAGUÉ', onPressed: () async {
                  await db.addShareEntry(ShareEntriesCompanion.insert(
                    friendId: f.id,
                    amountMinor: -balance,
                    currency: cur.code,
                    note: const Value('Liquidación'),
                    date: DateTime.now(),
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                }),
              TextButton(
                onPressed: () async {
                  await db.deleteFriend(f.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text('Borrar a ${f.name} y su historial', style: TextStyle(color: c.red)),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ---- Dividir un gasto ----
  Future<void> _divide(BuildContext context, WidgetRef ref, Currency cur, List<Friend> friends) async {
    final db = ref.read(dbProvider);
    final cats = ref.read(categoriesProvider).value ?? const <Category>[];
    final note = TextEditingController();
    final amount = TextEditingController();
    final newFriend = TextEditingController();
    var list = [...friends];
    final picked = <int>{for (final f in friends) f.id};
    int? payer; // null = pagué yo
    var asExpense = true;
    var catId = cats.isEmpty ? null : cats.first.id;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final total = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final people = picked.length + (payer != null && !picked.contains(payer) ? 1 : 0) + 1;
          final shares = SplitBill.equalShares(total * cur.factor, people);
          final each = shares.isEmpty ? Money.zero(cur) : Money(shares.last, cur);
          return AlertDialog(
            title: const Text('Dividir gasto'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(controller: note, decoration: const InputDecoration(hintText: 'Qué fue (ej. Cena)')),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsFormatter()],
                  onChanged: (_) => setS(() {}),
                  decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Total'),
                ),
                const SizedBox(height: 12),
                const Text('¿Quién pagó?', style: TextStyle(fontWeight: FontWeight.w800)),
                Wrap(spacing: 6, children: [
                  ChoiceChip(label: const Text('Yo'), selected: payer == null, onSelected: (_) => setS(() => payer = null)),
                  for (final f in list)
                    ChoiceChip(
                        label: Text(f.name), selected: payer == f.id, onSelected: (_) => setS(() => payer = f.id)),
                ]),
                const SizedBox(height: 12),
                const Text('¿Entre quiénes? (vos siempre entrás)', style: TextStyle(fontWeight: FontWeight.w800)),
                Wrap(spacing: 6, children: [
                  for (final f in list)
                    FilterChip(
                      label: Text(f.name),
                      selected: picked.contains(f.id),
                      onSelected: (v) => setS(() => v ? picked.add(f.id) : picked.remove(f.id)),
                    ),
                ]),
                Row(children: [
                  Expanded(child: TextField(controller: newFriend, decoration: const InputDecoration(hintText: 'Agregar amigo'))),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    onPressed: () async {
                      final n = newFriend.text.trim();
                      if (n.isEmpty) return;
                      final id = await db.addFriend(n);
                      newFriend.clear();
                      setS(() {
                        list = [...list, Friend(id: id, name: n)];
                        picked.add(id);
                      });
                    },
                  ),
                ]),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: asExpense,
                  onChanged: (v) => setS(() => asExpense = v ?? true),
                  title: const Text('Anotar mi parte como gasto'),
                ),
                if (asExpense && cats.isNotEmpty)
                  DropdownButton<int>(
                    value: catId,
                    isExpanded: true,
                    items: [for (final k in cats) DropdownMenuItem(value: k.id, child: Text(k.name))],
                    onChanged: (v) => setS(() => catId = v),
                  ),
                if (total > 0) Text('Cada uno: ${each.format()}', style: numStyle(14, weight: FontWeight.w900)),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () async {
                  if (total <= 0 || (payer == null && picked.isEmpty)) return;
                  final now = DateTime.now();
                  final label = note.text.trim().isEmpty ? 'Gasto compartido' : note.text.trim();
                  // Partes: la mía primero, después una por cada amigo que participa.
                  final mine = shares.first;
                  if (payer == null) {
                    // Pagué yo: cada amigo me debe su parte.
                    final ids = picked.toList();
                    for (var i = 0; i < ids.length; i++) {
                      await db.addShareEntry(ShareEntriesCompanion.insert(
                        friendId: ids[i],
                        amountMinor: shares[i + 1],
                        currency: cur.code,
                        note: Value(label),
                        date: now,
                      ));
                    }
                  } else {
                    // Pagó un amigo: le debo mi parte.
                    await db.addShareEntry(ShareEntriesCompanion.insert(
                      friendId: payer!,
                      amountMinor: -mine,
                      currency: cur.code,
                      note: Value(label),
                      date: now,
                    ));
                  }
                  if (asExpense) {
                    await db.addTxn(TxnsCompanion.insert(
                      kind: 'expense',
                      amountMinor: mine,
                      currency: cur.code,
                      categoryId: Value(catId),
                      note: Value('$label (mi parte)'),
                      date: now,
                    ));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
