import 'package:altfin/domain/finance_engine.dart';
import 'package:altfin/domain/habit_rule.dart';
import 'package:altfin/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavingsProfile: personalizado y sin porcentaje', () {
    test('"sin porcentaje" no tiene plan y no reparte el sueldo', () {
      expect(SavingsProfile.none.hasPlan, isFalse);
      final s = BudgetSplit.compute(const Money(5000000, Currency.pyg), SavingsProfile.none);
      expect(s.needs.isZero && s.wants.isZero && s.savings.isZero, isTrue);
    });
    test('byId construye el personalizado con los porcentajes guardados', () {
      final p = SavingsProfile.byId('custom', needs: 30, wants: 30, savings: 40);
      expect(p.id, 'custom');
      expect(p.savingsPct, 40);
      final s = BudgetSplit.compute(const Money(1000000, Currency.pyg), p);
      expect(s.savings.minor, 400000);
      expect(s.total.minor, 1000000);
    });
    test('personalizado con ahorro 0 % es válido (omitir el ahorro)', () {
      final p = SavingsProfile.byId('custom', needs: 70, wants: 30, savings: 0);
      expect(p.hasPlan, isTrue);
      expect(BudgetSplit.compute(const Money(1000000, Currency.pyg), p).savings.minor, 0);
    });
    test('personalizado inválido (no suma 100) cae a Modo Cohete', () {
      expect(SavingsProfile.byId('custom', needs: 50, wants: 50, savings: 50).id, 'rocket');
    });
    test('los perfiles de siempre siguen igual', () {
      expect(SavingsProfile.byId('rocket').savingsPct, 50);
      expect(SavingsProfile.byId('none').id, 'none');
      expect(() => SavingsProfile.byId('xyz'), throwsArgumentError);
    });
  });

  group('HabitRule', () {
    test('máscara de días', () {
      expect(HabitRule.maskFromDays([1, 2, 3, 4, 5]), HabitRule.mondayToFriday);
      expect(HabitRule.daysFromMask(HabitRule.everyDay), [1, 2, 3, 4, 5, 6, 7]);
      expect(HabitRule.occursOn(HabitRule.mondayToFriday, DateTime(2026, 10, 10)), isFalse, reason: 'sábado');
      expect(HabitRule.occursOn(HabitRule.mondayToFriday, DateTime(2026, 10, 12)), isTrue, reason: 'lunes');
      expect(() => HabitRule.bit(0), throwsArgumentError);
    });

    test('autobús: 2 veces al día × ₲ 2.300, lunes a viernes', () {
      expect(HabitRule.perDay(2300, 2), 4600);
      expect(HabitRule.weekly(2300, 2, HabitRule.mondayToFriday), 23000);
    });

    test('estimado del mes cuenta los días reales', () {
      // Octubre 2026 tiene 22 días de lunes a viernes.
      expect(
        HabitRule.monthlyEstimate(unitPrice: 2300, timesPerDay: 2, mask: HabitRule.mondayToFriday, month: DateTime(2026, 10)),
        4600 * 22,
      );
      // Febrero 2026: 28 días = 20 hábiles.
      expect(
        HabitRule.monthlyEstimate(unitPrice: 1000, timesPerDay: 1, mask: HabitRule.mondayToFriday, month: DateTime(2026, 2)),
        20000,
      );
      expect(
        HabitRule.monthlyEstimate(unitPrice: 1000, timesPerDay: 3, mask: 0, month: DateTime(2026, 10)),
        0,
        reason: 'sin días elegidos no hay gasto',
      );
    });

    test('días a generar: desde el siguiente al último, solo días de la máscara', () {
      // Hoy lunes 12; último generado jueves 8; días L-V: viernes 9 y lunes 12.
      final d = HabitRule.daysToGenerate(
        mask: HabitRule.mondayToFriday,
        createdOn: DateTime(2026, 9, 1),
        lastGenerated: DateTime(2026, 10, 8),
        today: DateTime(2026, 10, 12, 15),
      );
      expect(d, [DateTime(2026, 10, 9), DateTime(2026, 10, 12)]);
    });

    test('un hábito nuevo empieza el día en que se crea (incluye hoy)', () {
      final d = HabitRule.daysToGenerate(
        mask: HabitRule.everyDay,
        createdOn: DateTime(2026, 10, 12, 9),
        lastGenerated: null,
        today: DateTime(2026, 10, 12, 18),
      );
      expect(d, [DateTime(2026, 10, 12)]);
    });

    test('no repite un día ya generado', () {
      final d = HabitRule.daysToGenerate(
        mask: HabitRule.everyDay,
        createdOn: DateTime(2026, 10, 1),
        lastGenerated: DateTime(2026, 10, 12),
        today: DateTime(2026, 10, 12),
      );
      expect(d, isEmpty);
    });

    test('limita el relleno cuando la app estuvo mucho tiempo cerrada', () {
      final d = HabitRule.daysToGenerate(
        mask: HabitRule.everyDay,
        createdOn: DateTime(2025, 1, 1),
        lastGenerated: null,
        today: DateTime(2026, 10, 12),
      );
      expect(d.length, 32, reason: '31 días atrás + hoy');
      expect(d.first, DateTime(2026, 9, 11));
    });

    test('clave de día', () {
      expect(HabitRule.dayKey(DateTime(2026, 3, 9)), '2026-03-09');
      expect(HabitRule.parseDayKey('2026-03-09'), DateTime(2026, 3, 9));
      expect(HabitRule.parseDayKey('xx'), isNull);
    });
  });
}
