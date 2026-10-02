import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/gamification.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Registro rápido: monto → categoría → guardar (3 toques).
class AddTxnScreen extends ConsumerStatefulWidget {
  const AddTxnScreen({super.key, this.initialKind = 'expense', this.fromWidget = false});

  /// expense | income | saving: lo que se anota al abrir (los widgets abren directo en el tipo que dicen).
  final String initialKind;

  /// Abierta desde un widget: al guardar se vuelve a donde estaba la persona (se cierra la app).
  final bool fromWidget;

  @override
  ConsumerState<AddTxnScreen> createState() => _AddTxnScreenState();
}

class _AddTxnScreenState extends ConsumerState<AddTxnScreen> {
  late String kind = widget.initialKind;
  String digits = '';
  Currency? currency;
  int? categoryId;
  bool yesterday = false;
  final note = TextEditingController();

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    note.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  /// En PC se puede escribir el monto con el teclado: números, Borrar,
  /// Enter para guardar y Esc para cerrar (salvo mientras se escribe la nota).
  bool _onKey(KeyEvent e) {
    if (e is KeyUpEvent || !mounted) return false;
    if (FocusManager.instance.primaryFocus?.context?.widget is EditableText) return false;
    final k = e.logicalKey;
    final ch = e.character;
    if (ch != null && RegExp(r'^[0-9]$').hasMatch(ch) && !HardwareKeyboard.instance.isControlPressed) {
      press(ch);
      return true;
    }
    if (k == LogicalKeyboardKey.backspace) {
      press('⌫');
      return true;
    }
    if (e is KeyDownEvent && (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter)) {
      if (value > 0) save(currency ?? ref.read(settingsProvider).value?.currency ?? Currency.pyg);
      return true;
    }
    if (e is KeyDownEvent && k == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return true;
    }
    return false;
  }

  int get value => int.tryParse(digits) ?? 0;

  /// PYG: los dígitos son guaraníes. USD: los dígitos son centavos.
  int minorFor(Currency cur) => value;

  void press(String k) {
    setState(() {
      if (k == '⌫') {
        if (digits.isNotEmpty) digits = digits.substring(0, digits.length - 1);
      } else if (digits.length < 12) {
        digits = (digits + k).replaceFirst(RegExp(r'^0+'), '');
      }
    });
  }

  Future<void> save(Currency cur) async {
    final db = ref.read(dbProvider);
    final now = ref.read(clockProvider)();
    final date = yesterday ? now.subtract(const Duration(days: 1)) : now;
    await db.addTxn(TxnsCompanion.insert(
      kind: kind,
      amountMinor: minorFor(cur),
      currency: cur.code,
      categoryId: Value(kind == 'expense' ? categoryId : null),
      note: Value(note.text.trim()),
      date: date,
    ));
    final xp = ref.read(settingsProvider).value?.xp ?? 0;
    await db.setSetting('xp', '${xp + Gamification.xpPerExpense}');
    if (!mounted) return;
    if (widget.fromWidget) {
      // Vino de un widget: vuelve a donde estaba la persona, sin pasar por la app.
      SystemNavigator.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    final cur = currency ?? settings?.currency ?? Currency.pyg;
    final amount = Money(minorFor(cur), cur);
    final canSave = value > 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Column(children: [
                Row(children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.arrow_back_rounded, color: c.muted)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(99)),
                    child: Row(children: [
                      for (final k in const [('expense', 'Gasto'), ('income', 'Ingreso'), ('saving', 'Ahorro')])
                        GestureDetector(
                          onTap: () => setState(() => kind = k.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: kind == k.$1 ? c.greenSoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(k.$2,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: kind == k.$1 ? c.greenDark : c.ink,
                                )),
                          ),
                        ),
                    ]),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ]),
                Text('MONTO', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
                FittedBox(child: Text(amount.format(), style: numStyle(52))),
                GestureDetector(
                  onTap: () => setState(() => currency = cur == Currency.pyg ? Currency.usd : Currency.pyg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: c.card, border: Border.all(color: c.line, width: 2), borderRadius: BorderRadius.circular(99)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(cur == Currency.pyg ? '₲ Guaraníes' : 'US\$ Dólares',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      Icon(Icons.swap_horiz_rounded, size: 16, color: c.muted),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                if (kind == 'expense')
                  SizedBox(
                    // En ventanas bajas se ve una sola fila (el resto se desliza).
                    height: MediaQuery.sizeOf(context).height >= 780 ? 172 : 88,
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 8,
                      childAspectRatio: .98,
                      children: [
                        for (final x in cats)
                          GestureDetector(
                            onTap: () => setState(() => categoryId = x.id),
                            child: Column(children: [
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: categoryId == x.id ? Border.all(color: c.green, width: 3) : null,
                                ),
                                child: IconTile(x.icon, tone: x.tone, size: 52),
                              ),
                              const SizedBox(height: 2),
                              Text(x.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 8),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: AltCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: note,
                        decoration: InputDecoration(border: InputBorder.none, hintText: 'Nota (opcional)', hintStyle: TextStyle(color: c.muted)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AltChip(yesterday ? 'Ayer' : 'Hoy', selected: true, onTap: () => setState(() => yesterday = !yesterday)),
                ]),
                const SizedBox(height: 8),
                // El teclado ocupa lo que sobra: 4 filas que se achican si la
                // ventana es baja (nunca quedan tapadas por el botón de guardar).
                Expanded(
                  child: LayoutBuilder(builder: (context, cons) {
                    const gap = 8.0;
                    final cellH = ((cons.maxHeight - gap * 3) / 4).clamp(28.0, 64.0);
                    final cellW = (cons.maxWidth - gap * 2) / 3;
                    return GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                      childAspectRatio: cellW / cellH,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final k in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', '⌫'])
                          GestureDetector(
                            onTap: () => press(k),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Color(0x14463214), blurRadius: 14, offset: Offset(0, 4))],
                              ),
                              child: Text(k, style: numStyle(cellH < 44 ? 18 : 24)),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                BigButton(
                  kind == 'expense' ? 'GUARDAR GASTO  ·  +10 XP' : (kind == 'income' ? 'GUARDAR INGRESO  ·  +10 XP' : 'GUARDAR AHORRO  ·  +10 XP'),
                  onPressed: canSave ? () => save(cur) : null,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
