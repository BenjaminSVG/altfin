import 'package:altfin/data/backup.dart';
import 'package:altfin/data/database.dart';
import 'package:altfin/domain/habit_rule.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<AppDatabase> dbWithBus() async {
    final db = AppDatabase(NativeDatabase.memory());
    // Categoría 2 = Transporte (semilla). Autobús: 2 veces al día × ₲ 2.300, lunes a viernes.
    await db.addHabit(HabitsCompanion.insert(
      name: 'Autobús',
      unitPriceMinor: 2300,
      currency: 'PYG',
      categoryId: const Value(2),
      timesPerDay: const Value(2),
      weekdays: const Value(HabitRule.mondayToFriday),
      createdOn: DateTime(2026, 10, 5, 9), // lunes
    ));
    return db;
  }

  test('anota un gasto por cada día hábil, con veces × precio', () async {
    final db = await dbWithBus();
    final n = await db.generateDueHabits(DateTime(2026, 10, 9, 15)); // viernes
    expect(n, 5, reason: 'lun 5 a vie 9');
    final txs = await db.allTxns();
    expect(txs.length, 5);
    expect(txs.every((t) => t.amountMinor == 4600 && t.categoryId == 2 && t.kind == 'expense'), isTrue);
    expect(txs.first.note, 'Autobús ×2');
    await db.close();
  });

  test('no duplica al abrir de nuevo el mismo día', () async {
    final db = await dbWithBus();
    await db.generateDueHabits(DateTime(2026, 10, 9, 15));
    expect(await db.generateDueHabits(DateTime(2026, 10, 9, 20)), 0);
    expect((await db.allTxns()).length, 5);
    await db.close();
  });

  test('el fin de semana no genera y el lunes retoma', () async {
    final db = await dbWithBus();
    await db.generateDueHabits(DateTime(2026, 10, 9, 15));
    expect(await db.generateDueHabits(DateTime(2026, 10, 11, 10)), 0, reason: 'domingo');
    expect(await db.generateDueHabits(DateTime(2026, 10, 12, 7)), 1, reason: 'lunes');
    await db.close();
  });

  test('un hábito pausado no genera', () async {
    final db = await dbWithBus();
    final h = (await db.select(db.habits).get()).single;
    await db.setHabitActive(h.id, false);
    expect(await db.generateDueHabits(DateTime(2026, 10, 9, 15)), 0);
    await db.close();
  });

  test('un movimiento de hoy antes de las 8 no queda en el futuro', () async {
    final db = await dbWithBus();
    final now = DateTime(2026, 10, 5, 6, 30);
    await db.generateDueHabits(now);
    final t = (await db.allTxns()).single;
    expect(t.date.isAfter(now), isFalse);
    await db.close();
  });

  test('un hábito de 1 vez al día usa solo el nombre en la nota', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.addHabit(HabitsCompanion.insert(
      name: 'Merienda', unitPriceMinor: 8000, currency: 'PYG', createdOn: DateTime(2026, 10, 5),
    ));
    await db.generateDueHabits(DateTime(2026, 10, 5, 12));
    final t = (await db.allTxns()).single;
    expect(t.note, 'Merienda');
    expect(t.amountMinor, 8000);
    await db.close();
  });

  test('los hábitos viajan en la copia de seguridad', () async {
    final a = await dbWithBus();
    final text = await Backup.toJsonString(a);
    final b = AppDatabase(NativeDatabase.memory());
    await Backup.restore(b, Backup.parse(text));
    final h = (await b.select(b.habits).get()).single;
    expect(h.name, 'Autobús');
    expect(h.timesPerDay, 2);
    expect(h.weekdays, HabitRule.mondayToFriday);
    await a.close();
    await b.close();
  });
}
