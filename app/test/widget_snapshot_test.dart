import 'package:altfin/domain/money.dart';
import 'package:altfin/services/widget_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('con sueldo: muestra cuánto podés gastar hoy y la racha', () {
    final s = WidgetSnapshot.build(
        hasIncome: true, dailyAllowance: const Money(120000, Currency.pyg), streak: 5, loggedToday: false);
    expect(s.todayValue, '₲ 120.000');
    expect(s.todayLabel, 'PODÉS GASTAR HOY');
    expect(s.streakValue, '5');
    expect(s.streakLabel, 'días de racha');
    expect(s.loggedLabel, 'Hoy falta anotar');
  });

  test('sin sueldo: invita a cargarlo; racha de 1 en singular y hoy ya anotado', () {
    final s = WidgetSnapshot.build(
        hasIncome: false, dailyAllowance: const Money.zero(Currency.pyg), streak: 1, loggedToday: true);
    expect(s.todayValue, 'Sin sueldo');
    expect(s.todayLabel, 'Cargá tu sueldo');
    expect(s.streakLabel, 'día de racha');
    expect(s.loggedLabel, 'Hoy ya anotaste');
    expect(s.toMap().keys, containsAll(['today_value', 'today_label', 'streak_value', 'streak_label', 'logged_label']));
  });
}
