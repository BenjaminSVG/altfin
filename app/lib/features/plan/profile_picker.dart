import 'package:flutter/material.dart';

import '../../domain/finance_engine.dart';
import '../../domain/money.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Lo que eligió el usuario para repartir su sueldo.
class PlanChoice {
  const PlanChoice({this.profileId = 'rocket', this.needs = 40, this.wants = 10});

  /// rocket | balanced | custom | none
  final String profileId;

  /// Porcentajes del perfil personalizado (el ahorro es lo que sobra hasta 100).
  final int needs;
  final int wants;

  int get savings => 100 - needs - wants;

  PlanChoice copyWith({String? profileId, int? needs, int? wants}) =>
      PlanChoice(profileId: profileId ?? this.profileId, needs: needs ?? this.needs, wants: wants ?? this.wants);

  /// Ajustes para guardar en la base.
  Map<String, String> toSettings() => {
        'profile': profileId,
        'pct_needs': '$needs',
        'pct_wants': '$wants',
        'pct_savings': '$savings',
      };

  String get buttonLabel => switch (profileId) {
        'rocket' => 'ELEGIR MODO COHETE',
        'balanced' => 'ELEGIR EQUILIBRADO',
        'custom' => 'USAR MI PLAN PERSONALIZADO',
        _ => 'CONTINUAR SIN PORCENTAJE',
      };
}

/// Opciones para repartir el sueldo: Modo Cohete, Equilibrado, Personalizado
/// y "Sin porcentaje" (no fijar un porcentaje de ahorro/inversión).
class ProfilePicker extends StatelessWidget {
  const ProfilePicker({super.key, required this.income, required this.value, required this.onChanged});

  final Money income;
  final PlanChoice value;
  final ValueChanged<PlanChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _card(context, 'rocket', 'Modo Cohete', SavingsProfile.rocket, recommended: true),
      const SizedBox(height: 16),
      _card(context, 'balanced', 'Equilibrado', SavingsProfile.balanced),
      const SizedBox(height: 12),
      _custom(context),
      const SizedBox(height: 12),
      _none(context),
    ]);
  }

  bool _on(String id) => value.profileId == id;

  Widget _bar(AltColors c, int n, int w, int s) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Row(children: [
          if (n > 0) Expanded(flex: n, child: Container(height: 14, color: c.blue)),
          if (n > 0 && (w > 0 || s > 0)) const SizedBox(width: 2),
          if (w > 0) Expanded(flex: w, child: Container(height: 14, color: c.orange)),
          if (w > 0 && s > 0) const SizedBox(width: 2),
          if (s > 0) Expanded(flex: s, child: Container(height: 14, color: c.green)),
        ]),
      );

  Widget _legend(AltColors c, int n, int w, int s) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Necesidades $n%', style: TextStyle(color: c.blue, fontWeight: FontWeight.w800, fontSize: 12)),
        Text('Gustos $w%', style: TextStyle(color: c.orange, fontWeight: FontWeight.w800, fontSize: 12)),
        Text('Ahorro $s%', style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w800, fontSize: 12)),
      ]);

  Widget _card(BuildContext context, String id, String title, SavingsProfile p, {bool recommended = false}) {
    final c = context.alt;
    final split = BudgetSplit.compute(income, p);
    final selected = _on(id);
    return GestureDetector(
      onTap: () => onChanged(value.copyWith(profileId: id)),
      child: Stack(clipBehavior: Clip.none, children: [
        AltCard(
          borderColor: selected ? c.green : null,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${p.savingsPct}%', style: numStyle(22, color: selected ? c.greenDark : c.muted)),
            ]),
            const SizedBox(height: 10),
            _bar(c, p.needsPct, p.wantsPct, p.savingsPct),
            const SizedBox(height: 8),
            _legend(c, p.needsPct, p.wantsPct, p.savingsPct),
            if (income.minor > 0) ...[
              const SizedBox(height: 8),
              Row(children: [
                Text('Ahorrás por mes', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(split.savings.format(), style: numStyle(17)),
              ]),
            ],
          ]),
        ),
        if (recommended)
          Positioned(
            right: 14,
            top: -12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: c.green, borderRadius: BorderRadius.circular(99)),
              child: const Text('RECOMENDADO PARA ENRIQUECERTE',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
      ]),
    );
  }

  Widget _custom(BuildContext context) {
    final c = context.alt;
    final selected = _on('custom');
    final n = value.needs, w = value.wants, s = value.savings;
    final split = BudgetSplit.compute(income, SavingsProfile.byId('custom', needs: n, wants: w, savings: s));
    return GestureDetector(
      onTap: selected ? null : () => onChanged(value.copyWith(profileId: 'custom')),
      child: AltCard(
        borderColor: selected ? c.green : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Personalizado', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (selected) Text('$s%', style: numStyle(22, color: c.greenDark)) else const Icon(Icons.tune_rounded),
          ]),
          if (!selected)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Elegí vos cuánto va a cada cosa. Podés poner 0 % de ahorro.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
            )
          else ...[
            const SizedBox(height: 10),
            _bar(c, n, w, s),
            const SizedBox(height: 8),
            _legend(c, n, w, s),
            const SizedBox(height: 6),
            _slider(c, 'Necesidades', n, c.blue, (v) {
              final nn = v.round();
              onChanged(value.copyWith(needs: nn, wants: w > 100 - nn ? 100 - nn : w));
            }),
            _slider(c, 'Gustos', w, c.orange, (v) => onChanged(value.copyWith(wants: v.round())), max: 100 - n),
            Row(children: [
              Text('Ahorro e inversión (lo que sobra)', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('$s%', style: numStyle(15, color: c.greenDark)),
            ]),
            if (income.minor > 0) ...[
              const SizedBox(height: 6),
              Row(children: [
                Text('Ahorrás por mes', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(split.savings.format(), style: numStyle(17)),
              ]),
            ],
          ],
        ]),
      ),
    );
  }

  Widget _slider(AltColors c, String label, int v, Color color, ValueChanged<double> on, {int max = 100}) {
    return Column(children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Text('$v%', style: numStyle(15, color: color)),
      ]),
      Slider(
        value: v.toDouble().clamp(0, max.toDouble()),
        min: 0,
        max: max <= 0 ? 1 : max.toDouble(),
        divisions: max <= 0 ? 1 : (max ~/ 5 == 0 ? 1 : max ~/ 5),
        activeColor: color,
        inactiveColor: c.line,
        onChanged: max <= 0 ? null : (x) => on((x / 5).round() * 5.0),
      ),
    ]);
  }

  Widget _none(BuildContext context) {
    final c = context.alt;
    final selected = _on('none');
    return GestureDetector(
      onTap: () => onChanged(value.copyWith(profileId: 'none')),
      child: AltCard(
        borderColor: selected ? c.green : null,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sin porcentaje', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('No fijar un porcentaje de ahorro por ahora. Igual te muestro cuánto te queda para gastar.',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? c.green : c.muted),
        ]),
      ),
    );
  }
}
