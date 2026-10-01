import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/gamification.dart';
import '../../services/notification_service.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';
import '../budget/budget_screen.dart';
import '../finn/finn_screen.dart';
import '../goals/goals_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../transactions/add_txn_screen.dart';
import '../transactions/movements_screen.dart';

/// Marco de la app: barra inferior en celular, barra lateral en PC.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    // Anota los gastos fijos que vencieron (alquiler, suscripciones...).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dbProvider).generateDueRecurrings(ref.read(clockProvider)());
    });
  }

  bool _addOpen = false;

  // Atajos globales dentro de la app (no dependen de qué widget tiene el foco).
  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent || _addOpen || !mounted) return false;
    final kb = HardwareKeyboard.instance;
    final isG = e.logicalKey == LogicalKeyboardKey.keyG && kb.isControlPressed && kb.isAltPressed;
    final isN = e.logicalKey == LogicalKeyboardKey.keyN && kb.isControlPressed;
    if (!isG && !isN) return false;
    openAdd();
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  Future<void> openAdd() async {
    if (_addOpen) return;
    _addOpen = true;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTxnScreen()));
    _addOpen = false;
  }

  void _reschedule() {
    final s = ref.read(settingsProvider).value;
    final logged = ref.read(loggedDaysProvider).value;
    if (s == null || logged == null) return;
    final now = ref.read(clockProvider)();
    NotificationService.instance.reschedule(
      enabled: s.reminders,
      hour: s.reminderHour,
      loggedToday: logged.any((d) => dayOnly(d) == dayOnly(now)),
      streak: Gamification.currentStreak(logged, now),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cada vez que cambian los registros, se reprograman los recordatorios.
    ref.listen(loggedDaysProvider, (_, __) => _reschedule());
    ref.listen(settingsProvider, (a, b) {
      if (a?.value?.reminders != b.value?.reminders ||
          a?.value?.reminderHour != b.value?.reminderHour) {
        _reschedule();
      }
    });
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return wide ? _desktop(context) : _mobile(context);
  }

  // ---------- Celular ----------
  Widget _mobile(BuildContext context) {
    final c = context.alt;
    const pages = [HomeScreen(), MovementsScreen(), SizedBox(), GoalsScreen(), FinnScreen()];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[index == 2 ? 0 : index]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.line, width: 1.5))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(children: [
              _navItem(0, Icons.home_rounded, 'Inicio'),
              _navItem(1, Icons.format_list_bulleted_rounded, 'Movimientos'),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: openAdd,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.green,
                        boxShadow: [BoxShadow(color: c.greenDark, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
                    ),
                  ),
                ),
              ),
              _navItem(3, Icons.track_changes_rounded, 'Metas'),
              _navItem(4, Icons.sentiment_satisfied_alt_rounded, 'Finn'),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final c = context.alt;
    final on = index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => index = i),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: on ? c.greenDark : c.muted, size: 26),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: on ? c.greenDark : c.muted)),
        ]),
      ),
    );
  }

  // ---------- PC ----------
  Widget _desktop(BuildContext context) {
    final c = context.alt;
    const items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.format_list_bulleted_rounded, 'Movimientos'),
      (Icons.bar_chart_rounded, 'Presupuesto'),
      (Icons.track_changes_rounded, 'Metas'),
      (Icons.sentiment_satisfied_alt_rounded, 'Finn y logros'),
      (Icons.settings_rounded, 'Ajustes'),
    ];
    const pages = [
      HomeScreen(),
      MovementsScreen(),
      BudgetScreen(),
      GoalsScreen(),
      FinnScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      body: Row(children: [
        Container(
          width: 240,
          decoration: BoxDecoration(color: c.card, border: Border(right: BorderSide(color: c.line, width: 1.5))),
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
          child: Column(children: [
            Row(children: [
              const SizedBox(width: 8),
              const FinnView(size: 44),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w900, color: c.ink),
                  children: [const TextSpan(text: 'Alt'), TextSpan(text: 'Fin', style: TextStyle(color: c.greenDark))],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            for (var i = 0; i < items.length; i++)
              GestureDetector(
                onTap: () => setState(() => index = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: index == i ? c.greenSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Icon(items[i].$1, color: index == i ? c.greenDark : c.muted),
                    const SizedBox(width: 12),
                    Text(items[i].$2,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: index == i ? c.greenDark : c.muted)),
                  ]),
                ),
              ),
            const Spacer(),
            BigButton('+ ANOTAR GASTO', onPressed: openAdd),
            const SizedBox(height: 8),
            Text('Atajo: Ctrl + Alt + G', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: pages[index],
            ),
          ),
        ),
      ]),
    );
  }
}
