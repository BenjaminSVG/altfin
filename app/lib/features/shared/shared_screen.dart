import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/split_bill.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import 'divide_screen.dart';

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
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DivideScreen())),
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

}
