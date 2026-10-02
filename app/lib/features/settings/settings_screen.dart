import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup.dart';
import '../../domain/csv_export.dart';
import '../../domain/reminder_times.dart';
import '../../domain/money.dart';
import '../security/security_screen.dart';
import '../../services/notification_service.dart';
import '../../state/providers.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../debts/debts_screen.dart';
import '../habits/habits_screen.dart';
import '../plan/plan_screen.dart';
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
          'reminder_times': ReminderTimes.encode(s.reminderTimes),
        },
        ...v,
      });
      await NotificationService.instance.reschedule(
        enabled: ns.reminders,
        times: ns.reminderTimes,
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
            toggle('Recordatorios diarios', 'Solo si todavía no anotaste hoy', s.reminders, (v) async {
              if (v) await NotificationService.instance.requestPermission();
              await set({'reminders': v ? '1' : '0'});
            }),
            Divider(color: c.line),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('A estas horas', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in s.reminderTimes)
                GestureDetector(
                  onTap: () async {
                    final p = await showTimePicker(
                        context: context, initialTime: TimeOfDay(hour: t ~/ 60, minute: t % 60));
                    if (p != null) {
                      await set({'reminder_times': ReminderTimes.encode(ReminderTimes.replace(s.reminderTimes, t, p.hour * 60 + p.minute))});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                    decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(99)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(ReminderTimes.format(t), style: numStyle(15, color: c.greenDark, weight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      if (s.reminderTimes.length > 1)
                        GestureDetector(
                          onTap: () => set({'reminder_times': ReminderTimes.encode(ReminderTimes.remove(s.reminderTimes, t))}),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.close_rounded, size: 18, color: c.greenDark),
                          ),
                        )
                      else
                        const SizedBox(width: 8),
                    ]),
                  ),
                ),
              if (s.reminderTimes.length < ReminderTimes.max)
                GestureDetector(
                  onTap: () async {
                    final p = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
                    if (p != null) {
                      await set({'reminder_times': ReminderTimes.encode(ReminderTimes.add(s.reminderTimes, p.hour * 60 + p.minute))});
                    }
                  },
                  child: const Pill('+ Agregar hora'),
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
            _navRow(c, 'cash', 'g', 'Sueldo y plan de ahorro', 'Todo opcional: sueldo, porcentaje o ninguno',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen()))),
            _navRow(c, 'bus', 'b', 'Autobús y gastos repetitivos', 'Veces al día, precio y días',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HabitsScreen()))),
            _navRow(c, 'tv', 'p', 'Gastos fijos y suscripciones', 'Alquiler, internet, Netflix...',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionsScreen()))),
            _navRow(c, 'card', 'b', 'Deudas', 'Plan de pago: avalancha o bola de nieve',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebtsScreen()))),
            _navRow(c, 'chart', 'b', 'Informe', 'Últimos 6 meses y categorías',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            _navRow(c, 'save', 'o', 'Exportar a CSV', 'Abrilo en Excel o Google Sheets', () => _export(context, ref)),
            _navRow(c, 'save', 'g', 'Copia de seguridad', 'Guardá todos tus datos en un archivo', () => _backup(context, ref)),
            _navRow(c, 'sprout', 'g', 'Restaurar copia', 'Recuperá tus datos desde un archivo', () => _restore(context, ref)),
            _navRow(
                c,
                'lock',
                'b',
                'Seguridad',
                s.hasPin
                    ? 'Protegida con ${s.lockKind.label}${s.biometric ? ' y huella' : ''}'
                    : 'PIN, contraseña o huella para abrir la app',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen()))),
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

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
