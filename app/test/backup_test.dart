import 'dart:convert';

import 'package:altfin/data/backup.dart';
import 'package:altfin/data/database.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  test('copia y restauración: ida y vuelta sin perder datos', () async {
    final a = AppDatabase(NativeDatabase.memory());
    await a.setSetting('net_income', '5000000');
    await a.setSetting('name', 'Beni');
    await a.addTxn(TxnsCompanion.insert(
        kind: 'expense', amountMinor: 35000, currency: 'PYG', categoryId: const Value(1), note: const Value('Tereré, "chipa"'), date: DateTime(2026, 10, 1, 9)));
    await a.addTxn(TxnsCompanion.insert(kind: 'income', amountMinor: 5000000, currency: 'PYG', date: DateTime(2026, 10, 1)));
    await a.addGoal(GoalsCompanion.insert(name: 'Viaje', icon: 'plane', targetMinor: 5000000, savedMinor: const Value(3400000), currency: 'PYG'));
    await a.addRecurring(RecurringsCompanion.insert(name: 'Netflix', amountMinor: 45000, currency: 'PYG', dayOfMonth: 10));
    await a.markNoSpendDay(DateTime(2026, 9, 30));
    await a.addDebt(DebtsCompanion.insert(name: 'Tarjeta', balanceMinor: 1000000, currency: 'PYG', annualRatePct: const Value(36), minPaymentMinor: 60000));

    final text = await Backup.toJsonString(a);

    // Una base nueva y distinta: se parece a un equipo recién instalado.
    final b = AppDatabase(NativeDatabase.memory());
    await b.setSetting('name', 'Otro');
    await b.addTxn(TxnsCompanion.insert(kind: 'expense', amountMinor: 1, currency: 'PYG', date: DateTime(2026, 1, 1)));
    await Backup.restore(b, Backup.parse(text));

    expect(await b.getSetting('name'), 'Beni');
    expect(await b.getSetting('net_income'), '5000000');
    final txs = await b.allTxns();
    expect(txs.length, 2, reason: 'el gasto viejo de prueba se reemplazó');
    final tere = txs.firstWhere((t) => t.kind == 'expense');
    expect(tere.amountMinor, 35000);
    expect(tere.note, 'Tereré, "chipa"');
    expect(tere.date, DateTime(2026, 10, 1, 9));
    final goals = await b.select(b.goals).get();
    expect(goals.single.savedMinor, 3400000);
    expect((await b.select(b.recurrings).get()).single.name, 'Netflix');
    expect((await b.select(b.dayChecks).get()).length, 1);
    final debt = (await b.select(b.debts).get()).single;
    expect(debt.name, 'Tarjeta');
    expect(debt.annualRatePct, 36);
    expect((await b.select(b.categories).get()).length, 10);

    await a.close();
    await b.close();
  });

  test('una copia vieja sin deudas igual se restaura', () async {
    final a = AppDatabase(NativeDatabase.memory());
    await a.setSetting('name', 'Beni');
    final map = await Backup.toMap(a);
    map.remove('debts'); // como las copias hechas antes de existir las deudas
    final b = AppDatabase(NativeDatabase.memory());
    await b.addDebt(DebtsCompanion.insert(name: 'x', balanceMinor: 1, currency: 'PYG', minPaymentMinor: 1));
    await Backup.restore(b, Backup.parse(jsonEncode(map)));
    expect(await b.getSetting('name'), 'Beni');
    expect(await b.select(b.debts).get(), isEmpty);
    await a.close();
    await b.close();
  });

  test('rechaza archivos que no son copias de AltFin', () {
    expect(() => Backup.parse('hola'), throwsFormatException);
    expect(() => Backup.parse('{"format":"otra-cosa"}'), throwsFormatException);
    expect(() => Backup.parse('{"format":"altfin-backup","version":99}'), throwsFormatException);
    expect(() => Backup.parse('{"format":"altfin-backup","version":1}'), throwsFormatException);
  });
}
