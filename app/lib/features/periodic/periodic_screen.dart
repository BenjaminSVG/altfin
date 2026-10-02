import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/balance.dart';
import '../../domain/habit_rule.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

const _dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// Un gasto periódico ya listo para mostrar (viene de Habits o de Recurrings).
class _Item {
  const _Item({
    required this.isHabit,
    required this.id,
    required this.name,
    required this.icon,
    required this.tone,
    required this.when,
    required this.detail,
    required this.amountMinor,
    required this.currency,
    required this.monthly,
    required this.active,
  });

  final bool isHabit;
  final int id;
  final String name, icon, tone, when, detail;
  final int amountMinor;
  final Currency currency;

  /// Costo de este mes, en la moneda principal.
  final int monthly;
  final bool active;
}

/// Gastos periódicos: lo que la persona gasta cada día, cada semana o cada mes,
/// cargado a mano. La app los anota sola cuando corresponde.
/// (Por dentro: diarios y semanales son "hábitos"; mensuales son gastos fijos.)
class PeriodicScreen extends ConsumerWidget {
  const PeriodicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    final habits = ref.watch(habitsProvider).value ?? const <Habit>[];
    final recs = ref.watch(recurringsProvider).value ?? const <Recurring>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = s.currency;
    final now = ref.watch(clockProvider)();
    final catById = {for (final x in cats) x.id: x};

    Money main(int minor, String code) => s.fx.convert(Money(minor, Currency.fromCode(code)), cur);

    final items = <_Item>[
      for (final h in habits)
        _Item(
          isHabit: true,
          id: h.id,
          name: h.name,
          icon: h.icon,
          tone: h.tone,
          when: _habitWhen(h),
          detail: h.timesPerDay > 1 ? '${h.timesPerDay} veces × ${Money(h.unitPriceMinor, Currency.fromCode(h.currency)).format()}' : '',
          amountMinor: h.unitPriceMinor,
          currency: Currency.fromCode(h.currency),
          monthly: main(
                  HabitRule.monthlyEstimate(unitPrice: h.unitPriceMinor, timesPerDay: h.timesPerDay, mask: h.weekdays, month: now),
                  h.currency)
              .minor,
          active: h.active,
        ),
      for (final r in recs)
        _Item(
          isHabit: false,
          id: r.id,
          name: r.name,
          icon: catById[r.categoryId]?.icon ?? 'card',
          tone: catById[r.categoryId]?.tone ?? 'p',
          when: PeriodicCost.label(Periodicity.monthly, dayOfMonth: r.dayOfMonth),
          detail: '',
          amountMinor: r.amountMinor,
          currency: Currency.fromCode(r.currency),
          monthly: main(r.amountMinor, r.currency).minor,
          active: r.active,
        ),
    ];
    final dim = DateTime(now.year, now.month + 1, 0).day;
    final perMonth = items.where((i) => i.active).fold<int>(0, (a, i) => a + i.monthly);
    final cost = PeriodicCost(perMonth: perMonth, daysInMonth: dim);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos periódicos', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(onTap: () => _openForm(context, ref, cats, cur), child: const Pill('+ Nuevo')),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
            MintCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const FinnView(size: 66),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('ASÍ GASTÁS CON LO QUE CARGASTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _stat('POR DÍA', Money(cost.perDay, cur)),
                  _stat('POR SEMANA', Money(cost.perWeek, cur)),
                  _stat('POR MES', Money(cost.perMonth, cur)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              AltCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Cargá lo que gastás siempre', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Poné el monto y cada cuánto lo gastás: todos los días (el almuerzo), una vez por semana '
                    '(la feria) o una vez por mes (el alquiler). Yo lo anoto solo.',
                    style: TextStyle(color: c.muted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  BigButton('AGREGAR UN GASTO', onPressed: () => _openForm(context, ref, cats, cur)),
                ]),
              ),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AltCard(
                  onTap: () => _editAmount(context, ref, i),
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Opacity(
                    opacity: i.active ? 1 : .5,
                    child: Row(children: [
                      IconTile(i.icon, tone: i.tone, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(i.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(i.when, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                          if (i.detail.isNotEmpty)
                            Text(i.detail, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${Money(i.amountMinor, i.currency).format()}  ·  ≈ ${Money(i.monthly, cur).format()} al mes',
                              style: numStyle(12, color: c.greenDark, weight: FontWeight.w800)),
                        ]),
                      ),
                      Switch(
                        value: i.active,
                        activeTrackColor: c.green,
                        onChanged: (v) => i.isHabit
                            ? ref.read(dbProvider).setHabitActive(i.id, v)
                            : ref.read(dbProvider).setRecurringActive(i.id, v),
                      ),
                    ]),
                  ),
                ),
              ),
            if (items.isNotEmpty)
              Text(
                'Tocá un gasto para cambiar el monto o borrarlo. Lo que ya se anotó queda en Movimientos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String label, Money m) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          FittedBox(fit: BoxFit.scaleDown, child: Text(m.format(), style: numStyle(17))),
        ]),
      );

  static String _habitWhen(Habit h) {
    if (h.weekdays == HabitRule.everyDay) return PeriodicCost.label(Periodicity.daily);
    final days = HabitRule.daysFromMask(h.weekdays);
    if (days.length == 1) return PeriodicCost.label(Periodicity.weekly, weekday: days.first);
    if (h.weekdays == HabitRule.mondayToFriday) return 'De lunes a viernes';
    return 'Los días: ${days.map((d) => _dayNames[d - 1]).join(' ')}';
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref, List<Category> cats, Currency cur) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PeriodicForm(cats: cats, cur: cur, ref: ref),
    );
  }

  Future<void> _editAmount(BuildContext context, WidgetRef ref, _Item i) async {
    final ctrl = TextEditingController(text: Money(i.amountMinor ~/ i.currency.factor, Currency.pyg).format(withSymbol: false));
    final db = ref.read(dbProvider);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i.name),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(labelText: 'Monto', prefixText: '${i.currency.symbol} '),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (i.isHabit) {
                await db.deleteHabit(i.id);
              } else {
                await db.deleteRecurring(i.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Borrar'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final v = parseAmount(ctrl.text);
              if (v == null || v <= 0) return;
              final minor = v * i.currency.factor;
              if (i.isHabit) {
                await db.setHabitPrice(i.id, minor);
              } else {
                await db.setRecurringAmount(i.id, minor);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _PeriodicForm extends StatefulWidget {
  const _PeriodicForm({required this.cats, required this.cur, required this.ref});

  final List<Category> cats;
  final Currency cur;
  final WidgetRef ref;

  @override
  State<_PeriodicForm> createState() => _PeriodicFormState();
}

class _PeriodicFormState extends State<_PeriodicForm> {
  final name = TextEditingController();
  final amount = TextEditingController();
  Periodicity freq = Periodicity.daily;
  late int weekday = widget.ref.read(clockProvider)().weekday;
  int dayOfMonth = 1;
  int? categoryId;

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  int get minor => (parseAmount(amount.text) ?? 0) * widget.cur.factor;

  bool get valid => name.text.trim().isNotEmpty && minor > 0;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final cur = widget.cur;
    final cost = PeriodicCost.of(frequency: freq, amount: minor, month: widget.ref.read(clockProvider)(), weekday: weekday);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nuevo gasto periódico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            AltChip('Cada día', selected: freq == Periodicity.daily, onTap: () => setState(() => freq = Periodicity.daily)),
            AltChip('Cada semana', selected: freq == Periodicity.weekly, onTap: () => setState(() => freq = Periodicity.weekly)),
            AltChip('Cada mes', selected: freq == Periodicity.monthly, onTap: () => setState(() => freq = Periodicity.monthly)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Nombre', hintText: 'ej. Almuerzo, Feria, Alquiler'),
          ),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsFormatter()],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: switch (freq) {
                Periodicity.daily => 'Cuánto gastás por día',
                Periodicity.weekly => 'Cuánto gastás por semana',
                Periodicity.monthly => 'Cuánto gastás por mes',
              },
              prefixText: '${cur.symbol} ',
            ),
          ),
          if (freq == Periodicity.weekly) ...[
            const SizedBox(height: 14),
            const Text('¿Qué día de la semana?', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var d = 1; d <= 7; d++)
                GestureDetector(
                  onTap: () => setState(() => weekday = d),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: weekday == d ? c.green : c.line),
                    child: Text(_dayNames[d - 1],
                        style: TextStyle(fontWeight: FontWeight.w900, color: weekday == d ? Colors.white : c.muted)),
                  ),
                ),
            ]),
          ],
          if (freq == Periodicity.monthly) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Expanded(child: Text('¿Qué día del mes?', style: TextStyle(fontWeight: FontWeight.w800))),
              IconButton(
                  onPressed: dayOfMonth > 1 ? () => setState(() => dayOfMonth--) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded)),
              Text('$dayOfMonth', style: numStyle(22)),
              IconButton(
                  onPressed: dayOfMonth < 31 ? () => setState(() => dayOfMonth++) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded)),
            ]),
          ],
          const SizedBox(height: 6),
          DropdownButton<int>(
            isExpanded: true,
            value: categoryId,
            hint: const Text('Categoría'),
            items: [for (final x in widget.cats) DropdownMenuItem(value: x.id, child: Text(x.name))],
            onChanged: (v) => setState(() => categoryId = v),
          ),
          const SizedBox(height: 10),
          AltCard(
            color: c.greenSoft,
            child: Text(
              minor == 0
                  ? 'Poné el monto y te calculo cuánto es por día, semana y mes.'
                  : '${PeriodicCost.label(freq, weekday: weekday, dayOfMonth: dayOfMonth)}\n'
                      '≈ ${Money(cost.perDay, cur).format()} por día  ·  ${Money(cost.perWeek, cur).format()} por semana\n'
                      '≈ ${Money(cost.perMonth, cur).format()} este mes',
              style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 14),
          BigButton('GUARDAR', onPressed: valid ? _save : null),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    final db = widget.ref.read(dbProvider);
    final now = widget.ref.read(clockProvider)();
    final cat = widget.cats.where((x) => x.id == categoryId);
    final icon = cat.isEmpty ? 'tag' : cat.first.icon;
    final tone = cat.isEmpty ? 'p' : cat.first.tone;
    if (freq == Periodicity.monthly) {
      await db.addRecurring(RecurringsCompanion.insert(
        name: name.text.trim(),
        amountMinor: minor,
        currency: widget.cur.code,
        categoryId: Value(categoryId),
        dayOfMonth: dayOfMonth,
      ));
      await db.generateDueRecurrings(now);
    } else {
      await db.addHabit(HabitsCompanion.insert(
        name: name.text.trim(),
        icon: Value(icon),
        tone: Value(tone),
        categoryId: Value(categoryId),
        unitPriceMinor: minor,
        currency: widget.cur.code,
        weekdays: Value(freq == Periodicity.daily ? HabitRule.everyDay : HabitRule.bit(weekday)),
        createdOn: now,
      ));
      await db.generateDueHabits(now);
    }
    if (mounted) Navigator.of(context).pop();
  }
}
