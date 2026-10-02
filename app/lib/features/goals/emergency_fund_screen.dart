import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/emergency_fund.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/thousands_formatter.dart';
import '../../ui/widgets/widgets.dart';

const _fundName = 'Fondo de emergencia';

/// Calcula cuánta plata conviene tener guardada para imprevistos
/// (gasto esencial mensual × 3, 6 o 9 meses) y la convierte en una meta.
class EmergencyFundScreen extends ConsumerStatefulWidget {
  const EmergencyFundScreen({super.key});

  @override
  ConsumerState<EmergencyFundScreen> createState() => _EmergencyFundScreenState();
}

class _EmergencyFundScreenState extends ConsumerState<EmergencyFundScreen> {
  int months = 3;
  final essential = TextEditingController();
  bool seeded = false;

  @override
  void dispose() {
    essential.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final settings = ref.watch(settingsProvider).value;
    final summary = ref.watch(monthSummaryProvider).value;
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    if (settings == null || summary == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cur = settings.currency;

    // Punto de partida: lo que ya gastaste en necesidades este mes; si todavía
    // no hay gastos, la parte de necesidades del plan. Se puede editar.
    if (!seeded) {
      seeded = true;
      final guess = summary.spentNeeds.minor > 0 ? summary.spentNeeds : summary.split.needs;
      if (guess.minor > 0) essential.text = Money(guess.minor ~/ cur.factor, Currency.pyg).format(withSymbol: false);
    }
    final digits = int.tryParse(essential.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final monthly = Money(digits * cur.factor, cur);
    final target = EmergencyFund.target(monthly, months);
    final existing = goals.where((g) => g.name == _fundName).firstOrNull;
    final saved = Money(existing?.savedMinor ?? 0, cur);
    final covered = EmergencyFund.monthsCovered(saved, monthly);

    return Scaffold(
      appBar: AppBar(title: const Text('Fondo de emergencia', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        AltCard(
          child: Row(children: [
            const FinnView(pose: FinnPose.think, size: 64),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Es plata guardada para imprevistos (salud, perder el trabajo, una reparación). '
                'Se calcula con lo que no podés dejar de pagar.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gasto esencial por mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Alquiler, comida, transporte, servicios, salud, deudas.',
                style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: essential,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(prefixText: '${cur.symbol} ', hintText: '0'),
            ),
            const SizedBox(height: 14),
            const Text('Meses de cobertura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(children: [
              for (final m in EmergencyFund.options)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: m == EmergencyFund.options.last ? 0 : 8),
                    child: GestureDetector(
                      onTap: () => setState(() => months = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: months == m ? c.greenSoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: months == m ? c.green : c.line, width: 2),
                        ),
                        child: Text('$m meses',
                            style: TextStyle(fontWeight: FontWeight.w900, color: months == m ? c.greenDark : c.muted)),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            Text(
              switch (months) {
                3 => 'Ingreso estable y pocas obligaciones.',
                6 => 'Familia a cargo o compromisos grandes.',
                _ => 'Ingreso irregular o trabajo independiente.',
              },
              style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TU FONDO IDEAL', style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(monthly.minor == 0 ? '${cur.symbol} —' : target.format(), style: numStyle(30, weight: FontWeight.w900)),
            if (existing != null) ...[
              const SizedBox(height: 12),
              AltBar(value: EmergencyFund.progress(saved, target), tone: 'g', height: 12),
              const SizedBox(height: 6),
              Text(
                'Ahorrado ${saved.format()}: cubre ${covered.toStringAsFixed(1).replaceAll('.', ',')} de $months meses.',
                style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 14),
        BigButton(
          existing == null ? 'CREAR META' : 'ACTUALIZAR META',
          onPressed: monthly.minor == 0 ? null : () => _saveGoal(existing, target, cur),
        ),
      ]),
    );
  }

  Future<void> _saveGoal(Goal? existing, Money target, Currency cur) async {
    final db = ref.read(dbProvider);
    if (existing == null) {
      await db.addGoal(GoalsCompanion.insert(
        name: _fundName,
        icon: 'lifebuoy',
        tone: const Value('b'),
        targetMinor: target.minor,
        currency: cur.code,
      ));
    } else {
      await db.setGoalTarget(existing.id, target.minor);
    }
    if (mounted) Navigator.of(context).pop();
  }
}
