import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/habit_rule.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

const _dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// Gastos repetitivos: el autobús, la merienda, el tereré...
/// Se define cuántas veces al día, a qué precio y en qué días; la app los anota sola.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    final habits = ref.watch(habitsProvider).value ?? const <Habit>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cur = s.currency;
    final now = ref.watch(clockProvider)();
    final catById = {for (final x in cats) x.id: x};

    int estimate(Habit h) => s.fx
        .convert(
          Money(
            HabitRule.monthlyEstimate(unitPrice: h.unitPriceMinor, timesPerDay: h.timesPerDay, mask: h.weekdays, month: now),
            Currency.fromCode(h.currency),
          ),
          cur,
        )
        .minor;
    final total = habits.where((h) => h.active).fold<int>(0, (a, h) => a + estimate(h));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos repetitivos', style: TextStyle(fontWeight: FontWeight.w900)),
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
              child: Row(children: [
                const FinnView(size: 74),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ESTE MES VAS A GASTAR (ESTIMADO)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    FittedBox(fit: BoxFit.scaleDown, child: Text(Money(total, cur).format(), style: numStyle(30))),
                    const Text('Se anotan solos cada día que corresponde.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            if (habits.isEmpty)
              AltCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('¿Tomás el bus todos los días?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Decime cuántas veces lo usás, cuánto cuesta el boleto y qué días, y lo anoto por vos. También sirve para la merienda, el café, etc.',
                      style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  BigButton('AGREGAR AUTOBÚS', onPressed: () => _openForm(context, ref, cats, cur, preset: _presets.first)),
                ]),
              ),
            for (final h in habits)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AltCard(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Opacity(
                    opacity: h.active ? 1 : .5,
                    child: Row(children: [
                      IconTile(h.icon, tone: h.tone, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(h.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(
                            '${h.timesPerDay} ${h.timesPerDay == 1 ? 'vez' : 'veces'} al día × ${Money(h.unitPriceMinor, Currency.fromCode(h.currency)).format()} = ${Money(HabitRule.perDay(h.unitPriceMinor, h.timesPerDay), Currency.fromCode(h.currency)).format()}',
                            style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Row(children: [
                            for (var d = 1; d <= 7; d++)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: h.weekdays & HabitRule.bit(d) != 0 ? c.green : c.line,
                                ),
                                child: Text(_dayLetters[d - 1],
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: h.weekdays & HabitRule.bit(d) != 0 ? Colors.white : c.muted)),
                              ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('≈ ${Money(estimate(h), cur).format()}/mes',
                                  overflow: TextOverflow.ellipsis,
                                  style: numStyle(12, color: c.greenDark, weight: FontWeight.w700)),
                            ),
                          ]),
                          if (catById[h.categoryId] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Categoría: ${catById[h.categoryId]!.name}',
                                  style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                        ]),
                      ),
                      Column(children: [
                        Switch(value: h.active, activeTrackColor: c.green, onChanged: (v) => ref.read(dbProvider).setHabitActive(h.id, v)),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: c.muted),
                          onPressed: () => ref.read(dbProvider).deleteHabit(h.id),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            if (habits.isNotEmpty)
              Text('Los gastos ya anotados se quedan en Movimientos aunque borres el hábito.',
                  textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref, List<Category> cats, Currency cur, {_Preset? preset}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _HabitForm(cats: cats, cur: cur, initial: preset, ref: ref),
    );
  }
}

class _Preset {
  const _Preset(this.label, this.name, this.icon, this.tone, this.category, this.times, this.mask);

  final String label, name, icon, tone, category;
  final int times, mask;
}

const _presets = [
  _Preset('Autobús', 'Autobús', 'bus', 'b', 'Transporte', 2, HabitRule.mondayToFriday),
  _Preset('Merienda', 'Merienda', 'food', 'o', 'Comida afuera', 1, HabitRule.mondayToFriday),
  _Preset('Almuerzo', 'Almuerzo afuera', 'food', 'o', 'Comida afuera', 1, HabitRule.mondayToFriday),
  _Preset('Café / tereré', 'Café', 'food', 'o', 'Comida afuera', 1, HabitRule.everyDay),
  _Preset('Otro', '', 'tag', 'p', 'Compras', 1, HabitRule.mondayToFriday),
];

class _HabitForm extends StatefulWidget {
  const _HabitForm({required this.cats, required this.cur, required this.ref, this.initial});

  final List<Category> cats;
  final Currency cur;
  final WidgetRef ref;
  final _Preset? initial;

  @override
  State<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<_HabitForm> {
  final name = TextEditingController();
  final price = TextEditingController();
  int times = 1;
  int mask = HabitRule.mondayToFriday;
  String icon = 'tag';
  String tone = 'p';
  int? categoryId;
  int preset = 4;

  @override
  void initState() {
    super.initState();
    _apply(widget.initial ?? _presets.last);
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    super.dispose();
  }

  void _apply(_Preset p) {
    preset = _presets.indexOf(p);
    name.text = p.name;
    icon = p.icon;
    tone = p.tone;
    times = p.times;
    mask = p.mask;
    final cat = widget.cats.where((x) => x.name == p.category);
    categoryId = cat.isEmpty ? null : cat.first.id;
  }

  int get unit => (int.tryParse(price.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) * widget.cur.factor;

  bool get valid => name.text.trim().isNotEmpty && unit > 0 && mask != 0;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final cur = widget.cur;
    final perDay = HabitRule.perDay(unit, times);
    final month = HabitRule.monthlyEstimate(unitPrice: unit, timesPerDay: times, mask: mask, month: DateTime.now());
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nuevo gasto repetitivo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in _presets) AltChip(p.label, selected: preset == _presets.indexOf(p), onTap: () => setState(() => _apply(p))),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Nombre', hintText: 'ej. Autobús al trabajo'),
          ),
          TextField(
            controller: price,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: 'Precio de UNA vez (ej. un boleto)', prefixText: '${cur.symbol} '),
          ),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(child: Text('¿Cuántas veces al día?', style: TextStyle(fontWeight: FontWeight.w800))),
            IconButton(onPressed: times > 1 ? () => setState(() => times--) : null, icon: const Icon(Icons.remove_circle_outline_rounded)),
            Text('$times', style: numStyle(22)),
            IconButton(onPressed: times < 10 ? () => setState(() => times++) : null, icon: const Icon(Icons.add_circle_outline_rounded)),
          ]),
          const SizedBox(height: 4),
          const Text('¿Qué días?', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var d = 1; d <= 7; d++)
              GestureDetector(
                onTap: () => setState(() => mask ^= HabitRule.bit(d)),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mask & HabitRule.bit(d) != 0 ? c.green : c.line,
                  ),
                  child: Text(_dayLetters[d - 1],
                      style: TextStyle(fontWeight: FontWeight.w900, color: mask & HabitRule.bit(d) != 0 ? Colors.white : c.muted)),
                ),
              ),
          ]),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            TextButton(onPressed: () => setState(() => mask = HabitRule.mondayToFriday), child: const Text('Lunes a viernes')),
            TextButton(onPressed: () => setState(() => mask = HabitRule.everyDay), child: const Text('Todos los días')),
          ]),
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
            child: Row(children: [
              Expanded(
                child: Text(
                  unit == 0
                      ? 'Poné el precio y te calculo cuánto gastás.'
                      : '${times == 1 ? '1 vez' : '$times veces'} al día = ${Money(perDay, cur).format()} por día\n≈ ${Money(month, cur).format()} este mes',
                  style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w800),
                ),
              ),
            ]),
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
    await db.addHabit(HabitsCompanion.insert(
      name: name.text.trim(),
      icon: Value(icon),
      tone: Value(tone),
      categoryId: Value(categoryId),
      unitPriceMinor: unit,
      currency: widget.cur.code,
      timesPerDay: Value(times),
      weekdays: Value(mask),
      createdOn: now,
    ));
    // Si hoy toca, se anota enseguida.
    await db.generateDueHabits(now);
    if (mounted) Navigator.of(context).pop();
  }
}
