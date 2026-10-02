import 'package:altfin/data/backup.dart';
import 'package:altfin/data/database.dart';
import 'package:altfin/domain/split_bill.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las partes siempre suman el total', () {
    expect(SplitBill.equalShares(100000, 4), [25000, 25000, 25000, 25000]);
    final s = SplitBill.equalShares(100001, 3);
    expect(s.fold(0, (a, b) => a + b), 100001);
    expect(s, [33334, 33334, 33333]);
    expect(SplitBill.equalShares(500, 0), isEmpty);
  });

  test('texto del saldo', () {
    expect(SplitBill.describe('Ana', 5000, '₲ 5.000'), 'Ana te debe ₲ 5.000');
    expect(SplitBill.describe('Ana', -5000, '₲ 5.000'), 'Le debés ₲ 5.000 a Ana');
    expect(SplitBill.describe('Ana', 0, ''), 'Están a mano con Ana');
  });

  test('amigos, historial, liquidación, borrado y copia de seguridad', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final ana = await db.addFriend('Ana');
    await db.addShareEntry(ShareEntriesCompanion.insert(
        friendId: ana, amountMinor: 30000, currency: 'PYG', date: DateTime(2026, 10, 1)));
    await db.addShareEntry(ShareEntriesCompanion.insert(
        friendId: ana, amountMinor: -10000, currency: 'PYG', date: DateTime(2026, 10, 2)));
    final entries = await db.select(db.shareEntries).get();
    expect(entries.fold(0, (a, e) => a + e.amountMinor), 20000);

    final copy = await Backup.toJsonString(db);
    final other = AppDatabase(NativeDatabase.memory());
    await Backup.restore(other, Backup.parse(copy));
    expect((await other.select(other.friends).get()).single.name, 'Ana');
    expect((await other.select(other.shareEntries).get()).length, 2);

    await db.deleteFriend(ana);
    expect(await db.select(db.friends).get(), isEmpty);
    expect(await db.select(db.shareEntries).get(), isEmpty);
    await db.close();
    await other.close();
  });
}
