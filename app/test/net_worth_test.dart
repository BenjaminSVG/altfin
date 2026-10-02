import 'package:altfin/data/backup.dart';
import 'package:altfin/data/database.dart';
import 'package:altfin/domain/fx.dart';
import 'package:altfin/domain/money.dart';
import 'package:altfin/domain/net_worth.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pyg = Currency.pyg;
  const fx = Fx(7000);

  test('patrimonio = activos + metas − deudas, convirtiendo dólares', () {
    final nw = NetWorth.compute(
      items: const [
        NetItem(isLiability: false, amount: Money(5000000, pyg)),
        NetItem(isLiability: false, amount: Money(10000, Currency.usd)), // US$ 100 = ₲ 700.000
        NetItem(isLiability: true, amount: Money(1000000, pyg)),
      ],
      goalsSaved: const [Money(300000, pyg)],
      debts: const [Money(2000000, pyg)],
      fx: fx,
      cur: pyg,
    );
    expect(nw.assets.minor, 6000000);
    expect(nw.liabilities.minor, 3000000);
    expect(nw.net.minor, 3000000);
  });

  test('puede ser negativo y el cambio se calcula sobre la serie', () {
    final nw = NetWorth.compute(
      items: const [NetItem(isLiability: true, amount: Money(500, pyg))],
      goalsSaved: const [],
      debts: const [],
      fx: fx,
      cur: pyg,
    );
    expect(nw.net.minor, -500);
    expect(NetWorth.change([100, 150, 400]), 300);
    expect(NetWorth.change([100]), 0);
  });

  test('snapshot mensual se reemplaza y la copia de seguridad lo incluye', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.addHolding(HoldingsCompanion.insert(name: 'Cuenta', amountMinor: 900, currency: 'PYG'));
    await db.upsertNetSnapshot('2026-10', 100, 'PYG');
    await db.upsertNetSnapshot('2026-10', 250, 'PYG');
    await db.upsertNetSnapshot('2026-11', 300, 'PYG');
    final snaps = await db.select(db.netSnapshots).get();
    expect(snaps.map((s) => s.netMinor), [250, 300]);

    final copy = await Backup.toJsonString(db);
    final other = AppDatabase(NativeDatabase.memory());
    await Backup.restore(other, Backup.parse(copy));
    expect((await other.select(other.holdings).get()).single.name, 'Cuenta');
    expect((await other.select(other.netSnapshots).get()).length, 2);
    await db.close();
    await other.close();
  });
}
