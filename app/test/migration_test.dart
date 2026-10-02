import 'dart:io';

import 'package:altfin/data/database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('una base de la versión 4 con datos se actualiza a la 7 sin perder nada', () async {
    final dir = Directory.systemTemp.createTempSync('altfin_mig');
    final file = File('${dir.path}/old.sqlite');
    addTearDown(() => dir.deleteSync(recursive: true));

    // 1) Crea una base actual con datos y la "retrocede" a la versión 4:
    //    sin las tablas de patrimonio, amigos y retos.
    var db = AppDatabase(NativeDatabase(file));
    await db.addGoal(GoalsCompanion.insert(name: 'Viaje', icon: 'plane', targetMinor: 900, currency: 'PYG'));
    await db.addHabit(HabitsCompanion.insert(
        name: 'Autobús', unitPriceMinor: 2300, currency: 'PYG', createdOn: DateTime(2026, 10, 1)));
    await db.setSetting('net_income', '5000000');
    for (final t in ['holdings', 'net_snapshots', 'friends', 'share_entries', 'challenges']) {
      await db.customStatement('DROP TABLE $t');
    }
    await db.customStatement('PRAGMA user_version = 4');
    await db.close();

    // 2) Se abre con el código nuevo: debe migrar.
    db = AppDatabase(NativeDatabase(file));
    expect((await db.select(db.goals).get()).single.name, 'Viaje');
    expect((await db.select(db.habits).get()).single.unitPriceMinor, 2300);
    expect(await db.getSetting('net_income'), '5000000');
    expect((await db.select(db.categories).get()).length, 10);

    // Las tablas nuevas existen y funcionan.
    await db.addHolding(HoldingsCompanion.insert(name: 'Cuenta', amountMinor: 1, currency: 'PYG'));
    final f = await db.addFriend('Ana');
    await db.addShareEntry(ShareEntriesCompanion.insert(friendId: f, amountMinor: 5, currency: 'PYG', date: DateTime(2026, 10, 2)));
    await db.addChallenge(ChallengesCompanion.insert(name: 'Reto', days: 3, startedOn: DateTime(2026, 10, 2)));
    await db.upsertNetSnapshot('2026-10', 10, 'PYG');
    expect((await db.select(db.holdings).get()).length, 1);
    expect((await db.select(db.challenges).get()).length, 1);
    await db.close();
  });
}
