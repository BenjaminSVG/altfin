import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/split_bill.dart';
import '../../state/providers.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

/// Pantalla para dividir un gasto entre amigos (cómoda con el teclado abierto).
class DivideScreen extends ConsumerStatefulWidget {
  const DivideScreen({super.key});

  @override
  ConsumerState<DivideScreen> createState() => _DivideScreenState();
}

class _DivideScreenState extends ConsumerState<DivideScreen> {
  final note = TextEditingController();
  final amount = TextEditingController();
  final newFriend = TextEditingController();
  final picked = <int>{};
  bool pickedInit = false;
  int? payer; // null = pagué yo
  bool asExpense = true;
  int? catId;

  @override
  void dispose() {
    note.dispose();
    amount.dispose();
    newFriend.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final n = newFriend.text.trim();
    if (n.isEmpty) return;
    final id = await ref.read(dbProvider).addFriend(n);
    newFriend.clear();
    setState(() => picked.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final friends = ref.watch(friendsProvider).value ?? const <Friend>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (settings == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = settings.currency;
    if (!pickedInit && friends.isNotEmpty) {
      pickedInit = true;
      picked.addAll(friends.map((f) => f.id));
    }
    catId ??= cats.isEmpty ? null : cats.first.id;

    final total = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final people = picked.length + (payer != null && !picked.contains(payer) ? 1 : 0) + 1;
    final shares = SplitBill.equalShares(total * cur.factor, people);
    final each = shares.isEmpty ? Money.zero(cur) : Money(shares.last, cur);

    return Scaffold(
      appBar: AppBar(title: const Text('Dividir gasto', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: note, decoration: const InputDecoration(hintText: 'Qué fue (ej. Cena)')),
            const SizedBox(height: 4),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: 'Total'),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('¿Quién pagó?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              ChoiceChip(label: const Text('Yo'), selected: payer == null, onSelected: (_) => setState(() => payer = null)),
              for (final f in friends)
                ChoiceChip(label: Text(f.name), selected: payer == f.id, onSelected: (_) => setState(() => payer = f.id)),
            ]),
            const SizedBox(height: 14),
            const Text('¿Entre quiénes? (vos siempre entrás)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              for (final f in friends)
                FilterChip(
                  label: Text(f.name),
                  selected: picked.contains(f.id),
                  onSelected: (v) => setState(() => v ? picked.add(f.id) : picked.remove(f.id)),
                ),
            ]),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: newFriend,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addFriend(),
                  decoration: const InputDecoration(hintText: 'Agregar amigo'),
                ),
              ),
              IconButton(icon: const Icon(Icons.person_add_alt_1_rounded), onPressed: _addFriend),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: asExpense,
              onChanged: (v) => setState(() => asExpense = v ?? true),
              title: const Text('Anotar mi parte como gasto', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            if (asExpense && cats.isNotEmpty)
              DropdownButton<int>(
                value: catId,
                isExpanded: true,
                items: [for (final k in cats) DropdownMenuItem(value: k.id, child: Text(k.name))],
                onChanged: (v) => setState(() => catId = v),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        if (total > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Cada uno: ${each.format()}  ·  $people personas',
                style: numStyle(15, weight: FontWeight.w900, color: c.greenDark)),
          ),
        BigButton('GUARDAR', onPressed: total <= 0 || (payer == null && picked.isEmpty) ? null : () => _save(cur, shares)),
      ]),
    );
  }

  Future<void> _save(Currency cur, List<int> shares) async {
    final db = ref.read(dbProvider);
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
    if (mounted) Navigator.of(context).pop();
  }
}
