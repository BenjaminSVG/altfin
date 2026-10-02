import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';
import '../plan/profile_picker.dart';

/// Onboarding: bienvenida → sueldo → plan de ahorro.
/// Nada es obligatorio: el sueldo y el porcentaje de ahorro se pueden omitir
/// (por ejemplo, si la persona está desempleada) y cargar más tarde en Ajustes.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0;
  Currency currency = Currency.pyg;
  String frequency = 'monthly';
  int payDay = 1;
  PlanChoice plan = const PlanChoice();
  final salary = TextEditingController();

  int get salaryMinor {
    final digits = salary.text.replaceAll(RegExp(r'[^0-9]'), '');
    final v = int.tryParse(digits) ?? 0;
    return v * currency.factor;
  }

  @override
  void dispose() {
    salary.dispose();
    super.dispose();
  }

  /// Guarda y entra a la app. Con [skipIncome] no se guarda sueldo ni plan.
  Future<void> finish({bool skipIncome = false, bool noPlan = false}) async {
    final db = ref.read(dbProvider);
    final values = <String, String>{
      'currency': currency.code,
      'onboarded': '1',
      if (skipIncome) ...{
        'net_income': '0',
        'profile': 'none',
      } else ...{
        'net_income': '$salaryMinor',
        'frequency': frequency,
        'pay_day': '$payDay',
        ...(noPlan ? plan.copyWith(profileId: 'none') : plan).toSettings(),
      },
    };
    await saveSettings(db, values);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(children: [
                Row(children: [
                  if (step > 0)
                    IconButton(
                      onPressed: () => setState(() => step--),
                      icon: Icon(Icons.arrow_back_rounded, color: c.muted),
                    ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: (step + 1) / 3,
                        minHeight: 10,
                        color: c.green,
                        backgroundColor: c.line,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Expanded(child: _body(context)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) => switch (step) {
        0 => _welcome(context),
        1 => _salary(context),
        _ => _profile(context),
      };

  Widget _welcome(BuildContext context) {
    final c = context.alt;
    return Column(children: [
      const Spacer(),
      const FinnView(pose: FinnPose.celebrate, size: 230),
      const SizedBox(height: 26),
      const Text('¡Hola! Soy Finn', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Text(
        'Te ayudo a ahorrar la mitad de tu sueldo y a ver crecer tu plata, un día a la vez.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, height: 1.4, color: c.muted, fontWeight: FontWeight.w600),
      ),
      const Spacer(),
      BigButton('EMPEZAR', onPressed: () => setState(() => step = 1)),
      const SizedBox(height: 12),
    ]);
  }

  Widget _salary(BuildContext context) {
    final c = context.alt;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const FinnView(size: 90),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18)),
              child: const Text('¡Empecemos por lo básico! ¿Cuánto cobrás al mes?',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Text('TU SUELDO NETO (LO QUE TE LLEGA)',
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        AltCard(
          borderColor: c.green,
          child: Row(children: [
            Text('${currency.symbol} ', style: numStyle(34)),
            Expanded(
              child: TextField(
                controller: salary,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()],
                style: numStyle(34),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          AltChip('₲ Guaraníes', selected: currency == Currency.pyg, onTap: () => setState(() => currency = Currency.pyg)),
          AltChip('US\$ Dólares', selected: currency == Currency.usd, onTap: () => setState(() => currency = Currency.usd)),
        ]),
        const SizedBox(height: 18),
        Text('¿CADA CUÁNTO COBRÁS?', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final f in const [('monthly', 'Mensual'), ('biweekly', 'Quincenal'), ('weekly', 'Semanal'), ('variable', 'Variable')])
            AltChip(f.$2, selected: frequency == f.$1, onTap: () => setState(() => frequency = f.$1)),
        ]),
        const SizedBox(height: 18),
        Text('DÍA DE COBRO', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
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
        const SizedBox(height: 24),
        BigButton('CONTINUAR', onPressed: salaryMinor > 0 ? () => setState(() => step = 2) : null),
        const SizedBox(height: 10),
        BigButton('OMITIR POR AHORA', ghost: true, onPressed: () => finish(skipIncome: true)),
        const SizedBox(height: 8),
        Text('Si todavía no tenés ingresos, no hay problema: podés cargarlos cuando quieras en Ajustes.',
            textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _profile(BuildContext context) {
    final c = context.alt;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Elegí tu meta de ahorro', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Con un sueldo de ${Money(salaryMinor, currency).format()}. Podés cambiarlo cuando quieras.',
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 22),
        ProfilePicker(
          income: Money(salaryMinor, currency),
          value: plan,
          onChanged: (p) => setState(() => plan = p),
        ),
        const SizedBox(height: 24),
        BigButton(plan.buttonLabel, onPressed: () => finish()),
        const SizedBox(height: 10),
        BigButton('OMITIR', ghost: true, onPressed: () => finish(noPlan: true)),
      ]),
    );
  }
}
