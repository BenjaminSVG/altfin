import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/pin.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';

/// Bloquea la app con PIN al abrir y al volver tras 30 s en segundo plano.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> with WidgetsBindingObserver {
  bool locked = true;
  DateTime? pausedAt;
  String entry = '';
  bool wrong = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final p = pausedAt;
      pausedAt = null;
      if (p != null && DateTime.now().difference(p) > const Duration(seconds: 30)) {
        setState(() {
          locked = true;
          entry = '';
        });
      }
    }
  }

  void _press(String k, AppSettings s) {
    setState(() {
      wrong = false;
      if (k == '⌫') {
        if (entry.isNotEmpty) entry = entry.substring(0, entry.length - 1);
        return;
      }
      if (entry.length >= PinLock.length) return;
      entry += k;
      if (entry.length == PinLock.length) {
        if (PinLock.verify(entry, s.pinSalt, s.pinHash)) {
          locked = false;
          entry = '';
        } else {
          wrong = true;
          entry = '';
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider).value;
    if (s == null || !s.hasPin || !locked) return widget.child;
    final c = context.alt;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FinnView(pose: wrong ? FinnPose.worry : FinnPose.sleep, size: 130),
                const SizedBox(height: 12),
                const Text('Ingresá tu PIN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(wrong ? 'PIN incorrecto, probá de nuevo' : 'Tus datos están protegidos',
                    style: TextStyle(color: wrong ? c.red : c.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < PinLock.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < entry.length ? c.green : c.line,
                      ),
                    ),
                ]),
                const SizedBox(height: 22),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final k in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'])
                      k.isEmpty
                          ? const SizedBox()
                          : GestureDetector(
                              onTap: () => _press(k, s),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18)),
                                child: k == '⌫' ? Icon(Icons.backspace_outlined, color: c.ink) : Text(k, style: numStyle(26)),
                              ),
                            ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
