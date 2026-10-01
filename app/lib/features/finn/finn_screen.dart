import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/gamification.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/icons/app_icon.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../settings/settings_screen.dart';

class FinnScreen extends ConsumerWidget {
  const FinnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final logged = ref.watch(loggedDaysProvider).value ?? const <DateTime>[];
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final summary = ref.watch(monthSummaryProvider).value;
    if (settings == null) return const Center(child: CircularProgressIndicator());
    final now = ref.watch(clockProvider)();
    final streak = Gamification.currentStreak(logged, now);
    final level = settings.level;
    final into = Gamification.xpIntoLevel(settings.xp);

    final badges = <(String, String, String, bool)>[
      ('Primer registro', 'note', 'o', logged.isNotEmpty),
      ('Primer ahorro', 'sprout', 'g', (summary?.saved.minor ?? 0) > 0),
      ('Racha de 7 días', 'flame', 'o', streak >= 7),
      ('Meta cumplida', 'trophy', 'b', goals.any((g) => g.savedMinor >= g.targetMinor && g.targetMinor > 0)),
      ('Racha de 30 días', 'medal', 'o', streak >= 30),
      ('Nivel 10', 'crown', 'o', level >= 10),
    ];
    final unlocked = badges.where((b) => b.$4).length;

    return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
      Row(children: [
        const Text('Finn', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          child: AltCard(padding: const EdgeInsets.all(8), child: Icon(Icons.settings_rounded, color: c.muted)),
        ),
      ]),
      const SizedBox(height: 12),
      MintCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(children: [
          FinnView(pose: level >= 40 ? FinnPose.rich : FinnPose.happy, size: 150),
          const SizedBox(height: 4),
          Text('${Gamification.finnStage(level)} · Nivel $level',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: into / Gamification.xpPerLevel,
              minHeight: 12,
              color: c.green,
              backgroundColor: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Text('$into / ${Gamification.xpPerLevel} XP para el nivel ${level + 1}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        _stat(context, 'flame', '$streak', 'días de racha'),
        const SizedBox(width: 10),
        _stat(context, 'medal', '$unlocked', 'insignias'),
        const SizedBox(width: 10),
        _stat(context, 'star', '${settings.xp}', 'XP total'),
      ]),
      const SizedBox(height: 14),
      AltCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Insignias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: .95,
            children: [
              for (final b in badges)
                Opacity(
                  opacity: b.$4 ? 1 : .4,
                  child: Column(children: [
                    ColorFiltered(
                      colorFilter: b.$4
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                          : const ColorFilter.matrix(<double>[
                              .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0,
                            ]),
                      child: IconTile(b.$2, tone: b.$3, size: 58),
                    ),
                    const SizedBox(height: 4),
                    Text(b.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ]),
                ),
            ],
          ),
        ]),
      ),
    ]);
  }

  Widget _stat(BuildContext context, String icon, String value, String label) {
    final c = context.alt;
    return Expanded(
      child: AltCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(children: [
          AppIcon(icon, size: 28),
          Text(value, style: numStyle(22)),
          Text(label, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
