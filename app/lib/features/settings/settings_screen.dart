import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup.dart';
import '../../domain/csv_export.dart';
import '../../domain/money.dart';
import '../../domain/pin.dart';
import '../../services/notification_service.dart';
import '../../state/providers.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../debts/debts_screen.dart';
import '../reports/reports_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final db = ref.read(dbProvider);

    Future<void> set(Map<String, String> v) async {
      await saveSettings(db, v);
      final ns = AppSettings.fromMap({
        ...{
          'reminders': s.reminders ? '1' : '0',
          'reminder_hour': '${s.reminderHour}',
        },
        ...v,
      });
      await NotificationService.instance.reschedule(
        enabled: ns.reminders,
        hour: ns.reminderHour,
        loggedToday: false,
        streak: 0,
      );
    }

    Widget toggle(String title, String sub, bool v, ValueChanged<bool> on) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(sub, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            Switch(value: v, onChanged: on, activeTrackColor: c.green),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        Text('ASÍ TE RECUERDA FINN', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        AltCard(
          child: Column(children: [
            toggle('Recordatorio diario', 'Solo si todavía no anotaste hoy', s.reminders, (v) async {
              if (v) await NotificationService.instance.requestPermission();
              await set({'reminders': v ? '1' : '0'});
            }),
            Divider(color: c.line),
            Row(children: [
              const Expanded(child: Text('Hora del recordatorio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: s.reminderHour, minute: 0));
                  if (t != null) await set({'reminder_hour': '${t.hour}'});
                },
                child: Pill('${s.reminderHour.toString().padLeft(2, '0')}:00'),
              ),
            ]),
            const SizedBox(height: 10),
            BigButton('PROBAR NOTIFICACIÓN', ghost: true, onPressed: () => NotificationService.instance.showTest()),
          ]),
        ),
        const SizedBox(height: 16),
        Text('HERRAMIENTAS', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        AltCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Dividers(children: [
            _navRow(c, 'tv', 'p', 'Gastos fijos y suscripciones', 'Alquiler, internet, Netflix...',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionsScreen()))),
            _navRow(c, 'card', 'b', 'Deudas', 'Plan de pago: avalancha o bola de nieve',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebtsScreen()))),
            _navRow(c, 'chart', 'b', 'Informe', 'Últimos 6 meses y categorías',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            _navRow(c, 'save', 'o', 'Exportar a CSV', 'Abrilo en Excel o Google Sheets', () => _export(context, ref)),
            _navRow(c, 'save', 'g', 'Copia de seguridad', 'Guardá todos tus datos en un archivo', () => _backup(context, ref)),
            _navRow(c, 'sprout', 'g', 'Restaurar copia', 'Recuperá tus datos desde un archivo', () => _restore(context, ref)),
            _navRow(c, 'lock', 'b', s.hasPin ? 'Quitar PIN' : 'Proteger con PIN',
                s.hasPin ? 'La app se abre sin PIN' : 'Pedir PIN de 4 dígitos al abrir',
                () => s.hasPin ? _removePin(context, ref) : _setPin(context, ref)),
          ]),
        ),
        const SizedBox(height: 16),
        Text('APARIENCIA Y PERFIL', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        AltCard(
          child: Column(children: [
            toggle('Modo oscuro', 'Cuida tus ojos de noche', s.dark, (v) => set({'dark': v ? '1' : '0'})),
            Divider(color: c.line),
            Row(children: [
              const Expanded(child: Text('Tu nombre', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
              GestureDetector(
                onTap: () => _editText(context, 'Tu nombre', s.name, (v) => set({'name': v})),
                child: Pill(s.name.isEmpty ? 'Agregar' : s.name),
              ),
            ]),
            Divider(color: c.line),
            Row(children: [
              const Expanded(child: Text('Tasa dólar (₲ por US\$ 1)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
              GestureDetector(
                onTap: () => _editText(context, 'Guaraníes por dólar', '${s.pygPerUsd.round()}', (v) {
                  final d = double.tryParse(v);
                  if (d != null && d > 0) set({'usd_rate': '$d'});
                }, number: true),
                child: Pill('₲ ${s.pygPerUsd.round()}'),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        AltCard(
          child: Row(children: [
            const Icon(Icons.lock_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Todos tus datos se guardan solo en este dispositivo. Nada se envía a internet.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _navRow(AltColors c, String icon, String tone, String title, String sub, VoidCallback onTap) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            IconTile(icon, tone: tone, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(sub, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: c.muted),
          ]),
        ),
      );

  Future<String?> _askPin(BuildContext context, String title) {
    final ctl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctl,
          autofocus: true,
          obscureText: true,
          maxLength: PinLock.length,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '4 dígitos'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final a = await _askPin(context, 'Elegí un PIN');
    if (a == null || !PinLock.isValidFormat(a) || !context.mounted) return;
    final b = await _askPin(context, 'Repetí el PIN');
    if (!context.mounted) return;
    if (a != b) return _toast(context, 'Los PIN no coinciden. Probá de nuevo.');
    final salt = PinLock.newSalt();
    await saveSettings(ref.read(dbProvider), {'pin_salt': salt, 'pin_hash': PinLock.hash(a, salt)});
    if (context.mounted) _toast(context, 'PIN activado. Se pedirá al abrir la app.');
  }

  Future<void> _removePin(BuildContext context, WidgetRef ref) async {
    final s = ref.read(settingsProvider).value;
    final pin = await _askPin(context, 'Ingresá tu PIN actual');
    if (pin == null || s == null || !context.mounted) return;
    if (!PinLock.verify(pin, s.pinSalt, s.pinHash)) return _toast(context, 'PIN incorrecto.');
    await saveSettings(ref.read(dbProvider), {'pin_salt': '', 'pin_hash': ''});
    if (context.mounted) _toast(context, 'PIN quitado.');
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final all = await db.allTxns();
    final cats = {for (final x in await (db.select(db.categories)).get()) x.id: x.name};
    final csv = CsvExport.build([
      for (final t in all)
        CsvRow(
          date: t.date,
          kind: t.kind,
          category: cats[t.categoryId] ?? '',
          note: t.note,
          amountMinor: t.amountMinor,
          currency: Currency.fromCode(t.currency),
        ),
    ]);
    final dir = await getApplicationDocumentsDirectory();
    final now = ref.read(clockProvider)();
    final name = 'altfin_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(csv);
    if (!context.mounted) return;
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Mis movimientos de AltFin'));
    } else {
      _toast(context, 'Guardado en ${file.path}');
    }
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final text = await Backup.toJsonString(ref.read(dbProvider));
    final dir = await getApplicationDocumentsDirectory();
    final n = ref.read(clockProvider)();
    final name = 'altfin_copia_${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}.json';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(text);
    if (!context.mounted) return;
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Copia de seguridad de AltFin'));
    } else {
      _toast(context, 'Copia guardada en ${file.path}');
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (files.isEmpty || !context.mounted) return;
    final f = files.first;
    Map<String, dynamic> data;
    try {
      final text = utf8.decode(await File(f.path!).readAsBytes());
      data = Backup.parse(text);
    } on FormatException catch (e) {
      if (context.mounted) _toast(context, e.message);
      return;
    }
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Restaurar esta copia?'),
        content: const Text('Se van a reemplazar TODOS los datos que tenés ahora por los de la copia.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (ok != true) return;
    await Backup.restore(ref.read(dbProvider), data);
    if (context.mounted) _toast(context, 'Copia restaurada.');
  }

  Future<void> _editText(BuildContext context, String title, String initial, void Function(String) on, {bool number = false}) async {
    final ctl = TextEditingController(text: initial);
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctl, autofocus: true, keyboardType: number ? TextInputType.number : TextInputType.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (res != null) on(res);
  }
}
