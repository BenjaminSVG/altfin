import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/pin.dart';
import '../../services/biometric_service.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Seguridad: bloquear la app con PIN o contraseña, y desbloquearla con la
/// huella, el rostro o Windows Hello.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool? bioAvailable;

  @override
  void initState() {
    super.initState();
    ref.read(biometricProvider).isAvailable().then((v) {
      if (mounted) setState(() => bioAvailable = v);
    });
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /// Pide un PIN o una contraseña. null = canceló.
  Future<String?> _ask(String title, LockKind kind) {
    final ctl = TextEditingController();
    var visible = false;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctl,
            autofocus: true,
            obscureText: !visible,
            enableSuggestions: false,
            autocorrect: false,
            maxLength: kind == LockKind.pin ? PinLock.length : PasswordLock.maxLength,
            keyboardType: kind == LockKind.pin ? TextInputType.number : TextInputType.visiblePassword,
            inputFormatters: kind == LockKind.pin ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(
              hintText: kind == LockKind.pin ? '4 dígitos' : 'Al menos ${PasswordLock.minLength} caracteres',
              counterText: '',
              suffixIcon: kind == LockKind.pin
                  ? null
                  : IconButton(
                      icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setS(() => visible = !visible),
                    ),
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(ctx, ctl.text), child: const Text('Aceptar')),
          ],
        ),
      ),
    );
  }

  /// Verifica la clave actual. true = coincide.
  Future<bool> _confirmCurrent() async {
    final s = ref.read(settingsProvider).value;
    if (s == null) return false;
    final cur = await _ask('Ingresá tu ${s.lockKind.label} actual', s.lockKind);
    if (cur == null || !mounted) return false;
    if (!AppLock.verify(s.lockKind, cur, s.pinSalt, s.pinHash)) {
      _toast('${s.lockKind == LockKind.pin ? 'PIN incorrecto' : 'Contraseña incorrecta'}.');
      return false;
    }
    return true;
  }

  /// Elige un PIN/contraseña nuevo (con confirmación) y lo guarda.
  Future<void> _setNew(LockKind kind) async {
    final a = await _ask(kind == LockKind.pin ? 'Elegí un PIN' : 'Elegí una contraseña', kind);
    if (a == null || !mounted) return;
    if (!AppLock.isValidFormat(kind, a)) {
      return _toast(kind == LockKind.pin
          ? 'El PIN tiene que ser de 4 dígitos.'
          : 'La contraseña necesita al menos ${PasswordLock.minLength} caracteres.');
    }
    final b = await _ask(kind == LockKind.pin ? 'Repetí el PIN' : 'Repetí la contraseña', kind);
    if (b == null || !mounted) return;
    if (a != b) return _toast(kind == LockKind.pin ? 'Los PIN no coinciden. Probá de nuevo.' : 'Las contraseñas no coinciden. Probá de nuevo.');
    final salt = PinLock.newSalt();
    await saveSettings(ref.read(dbProvider), {
      'pin_salt': salt,
      'pin_hash': PinLock.hash(a, salt),
      'lock_kind': kind.id,
    });
    if (mounted) _toast('${kind == LockKind.pin ? 'PIN activado' : 'Contraseña activada'}. Se pedirá al abrir la app.');
  }

  Future<void> _change() async {
    if (!await _confirmCurrent() || !mounted) return;
    final kind = await showModalBottomSheet<LockKind>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('PIN de 4 dígitos'),
            onTap: () => Navigator.pop(ctx, LockKind.pin),
          ),
          ListTile(
            leading: const Icon(Icons.password_rounded),
            title: const Text('Contraseña'),
            onTap: () => Navigator.pop(ctx, LockKind.password),
          ),
        ]),
      ),
    );
    if (kind != null && mounted) await _setNew(kind);
  }

  Future<void> _remove() async {
    if (!await _confirmCurrent() || !mounted) return;
    await saveSettings(ref.read(dbProvider), {'pin_salt': '', 'pin_hash': '', 'lock_kind': 'pin', 'biometric': '0'});
    if (mounted) _toast('Bloqueo quitado. La app se abre sin clave.');
  }

  Future<void> _setBiometric(bool on) async {
    final db = ref.read(dbProvider);
    if (!on) {
      await db.setSetting('biometric', '0');
      return;
    }
    // Se confirma que funciona antes de activarlo, para no dejar una opción rota.
    final ok = await ref.read(biometricProvider).authenticate('Confirmá tu huella o rostro para activarlo');
    if (!mounted) return;
    if (!ok) return _toast('No se pudo confirmar. No se activó.');
    await db.setSetting('biometric', '1');
    if (mounted) _toast('Listo: ahora podés entrar con tu huella o rostro.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final on = s.hasPin;

    Widget row(String icon, String tone, String title, String sub, VoidCallback onTap) => AltCard(
          onTap: onTap,
          child: Row(children: [
            IconTile(icon, tone: tone, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(sub, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: c.muted),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
            MintCard(
              child: Row(children: [
                FinnView(pose: on ? FinnPose.happy : FinnPose.think, size: 78),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(on ? 'TU APP ESTÁ PROTEGIDA' : 'SIN BLOQUEO', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    Text(
                      on
                          ? 'Se pide ${s.lockKind == LockKind.pin ? 'tu PIN' : 'tu contraseña'}${s.biometric ? ' o tu huella' : ''} al abrir la app.'
                          : 'Cualquiera que tenga tu celular o tu compu puede ver tu plata. Protegela con un PIN o una contraseña.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            if (!on) ...[
              row('lock', 'b', 'Proteger con PIN', 'Un número de 4 dígitos, rápido de escribir', () => _setNew(LockKind.pin)),
              const SizedBox(height: 10),
              row('lock', 'p', 'Proteger con contraseña', 'Letras, números y símbolos: más segura', () => _setNew(LockKind.password)),
            ] else ...[
              row('lock', 'b', 'Cambiar PIN o contraseña', 'Primero te pido el actual', _change),
              const SizedBox(height: 10),
              row('lock', 'r', 'Quitar el bloqueo', 'La app se abrirá sin clave', _remove),
              const SizedBox(height: 14),
              AltCard(
                child: Row(children: [
                  const IconTile('lock', tone: 'g', size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Huella, rostro o Windows Hello', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(
                        bioAvailable == false
                            ? 'Este equipo no tiene huella, rostro o Windows Hello configurados.'
                            : 'Entrá sin escribir nada. Tu ${s.lockKind.label} sigue sirviendo de respaldo.',
                        style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ),
                  Switch(
                    value: s.biometric,
                    activeTrackColor: c.green,
                    onChanged: bioAvailable == true || s.biometric ? _setBiometric : null,
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Tu clave no se guarda: solo una huella digital cifrada de ella, en tu dispositivo. '
              'Si la olvidás no hay forma de recuperarla; por eso conviene hacer una copia de seguridad en Ajustes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ),
    );
  }
}
