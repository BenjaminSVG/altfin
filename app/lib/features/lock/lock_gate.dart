import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/pin.dart';
import '../../services/biometric_service.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Bloquea la app con PIN o contraseña al abrir y al volver tras 30 s en segundo
/// plano. Si está activada la biometría, pide la huella o el rostro enseguida;
/// el PIN o la contraseña siempre sirven de respaldo.
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
  bool showPassword = false;
  final password = TextEditingController();

  /// Intentos fallidos seguidos y hasta cuándo hay que esperar.
  int failed = 0;
  DateTime? waitUntil;
  Timer? _ticker;

  /// Ya se pidió la biometría en este bloqueo (para no insistir en bucle).
  bool _bioAsked = false;
  bool _bioBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    password.dispose();
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
          password.clear();
          _bioAsked = false;
        });
      }
    }
  }

  int get _waitLeft {
    final w = waitUntil;
    if (w == null) return 0;
    final left = w.difference(DateTime.now()).inSeconds + 1;
    return left > 0 ? left : 0;
  }

  void _unlock() {
    locked = false;
    entry = '';
    wrong = false;
    failed = 0;
    waitUntil = null;
    showPassword = false;
    password.clear();
    _ticker?.cancel();
  }

  void _fail() {
    wrong = true;
    entry = '';
    password.clear();
    failed++;
    final secs = AppLock.lockoutSeconds(failed);
    if (secs > 0) {
      waitUntil = DateTime.now().add(Duration(seconds: secs));
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_waitLeft == 0) {
            waitUntil = null;
            _ticker?.cancel();
          }
        });
      });
    }
    HapticFeedback.mediumImpact();
  }

  void _press(String k, AppSettings s) {
    if (_waitLeft > 0) return;
    setState(() {
      wrong = false;
      if (k == '⌫') {
        if (entry.isNotEmpty) entry = entry.substring(0, entry.length - 1);
        return;
      }
      if (entry.length >= PinLock.length) return;
      entry += k;
      if (entry.length == PinLock.length) {
        if (AppLock.verify(LockKind.pin, entry, s.pinSalt, s.pinHash)) {
          _unlock();
        } else {
          _fail();
        }
      }
    });
  }

  void _submitPassword(AppSettings s) {
    if (_waitLeft > 0) return;
    setState(() {
      if (AppLock.verify(LockKind.password, password.text, s.pinSalt, s.pinHash)) {
        _unlock();
      } else {
        _fail();
      }
    });
  }

  Future<void> _tryBiometric() async {
    if (_bioBusy || !mounted) return;
    _bioBusy = true;
    final ok = await ref.read(biometricProvider).authenticate('Desbloqueá AltFin para ver tu plata');
    _bioBusy = false;
    if (ok && mounted) setState(_unlock);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider).value;
    if (s == null || !s.hasPin || !locked) return widget.child;
    final c = context.alt;
    final isPin = s.lockKind == LockKind.pin;
    final left = _waitLeft;

    if (s.biometric && !_bioAsked) {
      _bioAsked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }

    final message = left > 0
        ? 'Demasiados intentos. Esperá $left s'
        : (wrong ? (isPin ? 'PIN incorrecto, probá de nuevo' : 'Contraseña incorrecta, probá de nuevo') : 'Tus datos están protegidos');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FinnView(pose: wrong ? FinnPose.worry : FinnPose.sleep, size: 130),
                  const SizedBox(height: 12),
                  Text(isPin ? 'Ingresá tu PIN' : 'Ingresá tu contraseña',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: wrong || left > 0 ? c.red : c.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  if (isPin) ...[
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
                  ] else ...[
                    TextField(
                      controller: password,
                      autofocus: !s.biometric,
                      enabled: left == 0,
                      obscureText: !showPassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (_) => setState(() => wrong = false),
                      onSubmitted: (_) => _submitPassword(s),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: c.muted),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BigButton('DESBLOQUEAR', onPressed: left == 0 && password.text.isNotEmpty ? () => _submitPassword(s) : null),
                  ],
                  if (s.biometric) ...[
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: _tryBiometric,
                      icon: Icon(Icons.fingerprint_rounded, color: c.greenDark, size: 28),
                      label: Text('Usar huella o rostro',
                          style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
