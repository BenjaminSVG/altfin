import 'package:altfin/data/database.dart';
import 'package:altfin/domain/emergency_fund.dart';
import 'package:altfin/domain/money.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pyg = Currency.pyg;

  test('fondo ideal = gasto esencial × meses', () {
    final t = EmergencyFund.target(const Money(3000000, pyg), 6);
    expect(t.minor, 18000000);
  });

  test('meses cubiertos y progreso', () {
    const monthly = Money(2000000, pyg);
    expect(EmergencyFund.monthsCovered(const Money(3000000, pyg), monthly), 1.5);
    expect(EmergencyFund.monthsCovered(const Money(1, pyg), Money.zero(pyg)), 0);
    expect(EmergencyFund.progress(const Money(9000000, pyg), const Money(6000000, pyg)), 1);
    expect(EmergencyFund.progress(const Money(1, pyg), Money.zero(pyg)), 0);
  });

  test('setGoalTarget actualiza la meta sin tocar lo ahorrado', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final id = await db.addGoal(GoalsCompanion.insert(
        name: 'Fondo de emergencia', icon: 'lifebuoy', targetMinor: 100, currency: 'PYG'));
    await db.addToGoal(id, 40);
    await db.setGoalTarget(id, 500);
    final g = (await db.select(db.goals).get()).single;
    expect((g.targetMinor, g.savedMinor), (500, 40));
    await db.close();
  });
}
