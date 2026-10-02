import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/challenge_rule.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Retos sin gasto: "7 días sin comer afuera". Dan XP al completarse.
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final views = ref.watch(challengeViewsProvider);
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Retos sin gasto', style: TextStyle(fontWeight: FontWeight.w900))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref, cats),
        backgroundColor: c.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('NUEVO RETO', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 90), children: [
        AltCard(
          child: Row(children: [
            const FinnView(pose: FinnPose.celebrate, size: 64),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Elegí algo que querés gastar menos y cuántos días aguantás. '
                'Si lo cumplís, ganás ${ChallengeRule.xpReward} XP.',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        for (final v in views) ...[
          _card(context, ref, v),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, ChallengeView v) {
    final c = context.alt;
    final p = v.progress;
    final (label, tone) = p.completed
        ? ('¡Cumplido!', 'g')
        : p.failed
            ? ('Perdido', 'r')
            : ('Faltan ${p.daysLeft} ${p.daysLeft == 1 ? 'día' : 'días'}', 'b');
    return AltCard(
      onTap: () => _options(context, ref, v),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(v.challenge.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          Pill(label, tone: tone),
        ]),
        const SizedBox(height: 10),
        AltBar(value: p.ratio, tone: p.failed ? 'r' : 'g', height: 12),
        const SizedBox(height: 6),
        Text(
          p.failed
              ? 'Gastaste el ${p.failedOn!.day}/${p.failedOn!.month}. Podés empezar de nuevo.'
              : p.completed
                  ? '${p.days} días sin gastar. ¡Muy bien!'
                  : '${p.cleanDays} de ${p.days} días${p.todayClean ? ', hoy vas bien' : ''}',
          style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }

  Future<void> _options(BuildContext context, WidgetRef ref, ChallengeView v) async {
    final db = ref.read(dbProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (v.progress.failed)
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Empezar de nuevo'),
              onTap: () async {
                await db.deleteChallenge(v.challenge.id);
                await db.addChallenge(ChallengesCompanion.insert(
                  name: v.challenge.name,
                  categoryId: Value(v.challenge.categoryId),
                  days: v.challenge.days,
                  startedOn: ref.read(clockProvider)(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('Borrar reto'),
            onTap: () async {
              await db.deleteChallenge(v.challenge.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref, List<Category> cats) async {
    final wants = cats.where((x) => x.block == 'want').toList();
    int? catId = wants.isEmpty ? null : wants.first.id;
    var days = 7;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nuevo reto'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('¿Sin gastar en qué?', style: TextStyle(fontWeight: FontWeight.w800)),
            DropdownButton<int?>(
              value: catId,
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Todos los gustos')),
                for (final k in cats) DropdownMenuItem<int?>(value: k.id, child: Text(k.name)),
              ],
              onChanged: (v) => setS(() => catId = v),
            ),
            const SizedBox(height: 10),
            const Text('¿Cuántos días?', style: TextStyle(fontWeight: FontWeight.w800)),
            Wrap(spacing: 6, children: [
              for (final d in const [3, 7, 14, 30])
                ChoiceChip(label: Text('$d'), selected: days == d, onSelected: (_) => setS(() => days = d)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final scope = catId == null ? 'gustos' : cats.firstWhere((k) => k.id == catId).name.toLowerCase();
                final now = ref.read(clockProvider)();
                await ref.read(dbProvider).addChallenge(ChallengesCompanion.insert(
                      name: '$days días sin $scope',
                      categoryId: Value(catId),
                      days: days,
                      startedOn: DateTime(now.year, now.month, now.day),
                    ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}
