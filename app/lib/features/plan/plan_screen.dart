import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';
import 'profile_picker.dart';

/// Sueldo y plan de ahorro. Todo es opcional: se puede dejar sin sueldo
/// (desempleo) y sin porcentaje de ahorro.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  late Currency currency;
  late String frequency;
  late int payDay;
  late PlanChoice plan;
  final salary = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider).value ?? const AppSettings();
    currency = s.currency;
    frequency = s.frequency;
    payDay = s.payDay.clamp(1, 28);
    plan = PlanChoice(profileId: s.profileId, needs: s.customNeeds, wants: s.customWants);
    if (s.netIncomeMinor > 0) {
      salary.text = Money(s.netIncomeMinor ~/ currency.factor, Currency.pyg).format(withSymbol: false);
    }
  }

  @override
  void dispose() {
    salary.dispose();
    super.dispose();
  }

  int get salaryMinor => (int.tryParse(salary.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) * currency.factor;

  Future<void> _save({bool clear = false}) async {
    final values = clear
        ? {'net_income': '0', 'profile': 'none', 'currency': currency.code}
        : {
            'net_income': '$salaryMinor',
            'currency': currency.code,
            'frequency': frequency,
            'pay_day': '$payDay',
            ...(salaryMinor == 0 ? plan.copyWith(profileId: 'none') : plan).toSettings(),
          };
    await saveSettings(ref.read(dbProvider), values);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final hasIncome = salaryMinor > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Sueldo y plan de ahorro', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const FinnView(size: 76),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18)),
                  child: const Text('Todo esto es opcional. Si ahora no tenés ingresos, dejalo vacío y listo.',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Text('TU SUELDO NETO (LO QUE TE LLEGA)', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 8),
            AltCard(
              borderColor: c.green,
              child: Row(children: [
                Text('${currency.symbol} ', style: numStyle(30)),
                Expanded(
                  child: TextField(
                    controller: salary,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()],
                    style: numStyle(30),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Sin sueldo por ahora'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              AltChip('₲ Guaraníes', selected: currency == Currency.pyg, onTap: () => setState(() => currency = Currency.pyg)),
              AltChip('US\$ Dólares', selected: currency == Currency.usd, onTap: () => setState(() => currency = Currency.usd)),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in const [('monthly', 'Mensual'), ('biweekly', 'Quincenal'), ('weekly', 'Semanal'), ('variable', 'Variable')])
                AltChip(f.$2, selected: frequency == f.$1, onTap: () => setState(() => frequency = f.$1)),
            ]),
            const SizedBox(height: 12),
            AltCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const Text('Cada mes, el día', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                DropdownButton<int>(
                  value: payDay,
                  underline: const SizedBox(),
                  items: [for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                  onChanged: (v) => setState(() => payDay = v ?? 1),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Porcentaje de ahorro e inversión', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(hasIncome ? 'Elegí cómo repartir tu sueldo, o dejalo sin porcentaje.' : 'Sin sueldo no hay reparto: se activa cuando cargues uno.',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            Opacity(
              opacity: hasIncome ? 1 : .5,
              child: IgnorePointer(
                ignoring: !hasIncome,
                child: ProfilePicker(income: Money(salaryMinor, currency), value: plan, onChanged: (p) => setState(() => plan = p)),
              ),
            ),
            const SizedBox(height: 24),
            BigButton('GUARDAR', onPressed: () => _save()),
            const SizedBox(height: 10),
            BigButton('QUITAR SUELDO Y PORCENTAJES', ghost: true, onPressed: () => _save(clear: true)),
          ]),
        ),
      ),
    );
  }
}
