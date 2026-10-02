import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/habit_rule.dart';
import '../domain/recurring_rule.dart';

part 'database.g.dart';

/// Categorías de gasto. [block] = need | want | saving.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();

  /// Color suave del icono: b, o, g, r, p.
  TextColumn get tone => text().withDefault(const Constant('g'))();
  TextColumn get block => text().withDefault(const Constant('need'))();

  /// Límite mensual en unidades mínimas (null = sin límite).
  IntColumn get monthlyLimitMinor => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Movimientos de dinero. [kind] = expense | income.
class Txns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get tone => text().withDefault(const Constant('g'))();
  IntColumn get targetMinor => integer()();
  IntColumn get savedMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
}

/// Gastos que se repiten cada mes (alquiler, Netflix, internet...).
class Recurrings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();

  /// Día del mes en que se cobra (1-31; en meses cortos cae el último día).
  IntColumn get dayOfMonth => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// Último mes generado, "2026-10". Evita duplicar el gasto.
  TextColumn get lastMonth => text().withDefault(const Constant(''))();
}

/// Gastos repetitivos (autobús, merienda...): veces al día × precio, en los
/// días de la semana elegidos. Se anotan solos cada día.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('tag'))();
  TextColumn get tone => text().withDefault(const Constant('o'))();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();

  /// Precio de UNA vez (un boleto, una merienda).
  IntColumn get unitPriceMinor => integer()();
  TextColumn get currency => text()();
  IntColumn get timesPerDay => integer().withDefault(const Constant(1))();

  /// Días de la semana en bits: lun = 1 ... dom = 64 (ver HabitRule).
  IntColumn get weekdays => integer().withDefault(const Constant(31))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdOn => dateTime()();

  /// Último día generado, "2026-10-12" (vacío = todavía ninguno).
  TextColumn get lastGenerated => text().withDefault(const Constant(''))();
}

/// Deudas (tarjeta, préstamo...) para el plan de pago.
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get balanceMinor => integer()();
  TextColumn get currency => text()();

  /// Tasa de interés anual en % (36 = 36 %).
  RealColumn get annualRatePct => real().withDefault(const Constant(0))();
  IntColumn get minPaymentMinor => integer()();
}

/// Activos y deudas cargados a mano para el patrimonio neto.
class Holdings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('coin'))();

  /// true = deuda (resta), false = activo (suma).
  BoolColumn get isLiability => boolean().withDefault(const Constant(false))();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
}

/// Patrimonio neto de cada mes (en la moneda principal), para ver la evolución.
class NetSnapshots extends Table {
  /// "2026-10".
  TextColumn get month => text()();
  IntColumn get netMinor => integer()();
  TextColumn get currency => text()();

  @override
  Set<Column> get primaryKey => {month};
}

/// Amigos con los que se comparten gastos.
class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

/// Movimiento de deuda con un amigo. [amountMinor] > 0: el amigo te debe
/// (pagaste vos); < 0: le debés (pagó él/ella o le diste algo).
class ShareEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get friendId => integer().references(Friends, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
}

/// Retos sin gasto. [categoryId] null = todos los gastos de "gustos".
class Challenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get days => integer()();
  DateTimeColumn get startedOn => dateTime()();

  /// Ya se entregó el XP de premio.
  BoolColumn get rewarded => boolean().withDefault(const Constant(false))();
}

/// Días en que el usuario confirmó "hoy no gasté" (cuentan para la racha).
class DayChecks extends Table {
  DateTimeColumn get day => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Ajustes simples clave/valor (sueldo, moneda, perfil, XP, etc.).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Categories, Txns, Goals, DayChecks, Settings, Recurrings, Debts, Habits, Holdings, NetSnapshots, Friends, ShareEntries, Challenges])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'altfin'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(recurrings);
          if (from < 3) await m.createTable(debts);
          if (from < 4) await m.createTable(habits);
          if (from < 5) {
            await m.createTable(holdings);
            await m.createTable(netSnapshots);
          }
          if (from < 6) {
            await m.createTable(friends);
            await m.createTable(shareEntries);
          }
          if (from < 7) await m.createTable(challenges);
        },
      );

  // ---- Gastos compartidos ----
  Stream<List<Friend>> watchFriends() => select(friends).watch();

  Stream<List<ShareEntry>> watchShareEntries() =>
      (select(shareEntries)..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.id)])).watch();

  Future<int> addFriend(String name) => into(friends).insert(FriendsCompanion.insert(name: name));

  /// Borra al amigo y su historial.
  Future<void> deleteFriend(int id) => transaction(() async {
        await (delete(shareEntries)..where((t) => t.friendId.equals(id))).go();
        await (delete(friends)..where((t) => t.id.equals(id))).go();
      });

  Future<int> addShareEntry(ShareEntriesCompanion e) => into(shareEntries).insert(e);

  // ---- Retos sin gasto ----
  Stream<List<Challenge>> watchChallenges() => select(challenges).watch();

  Future<int> addChallenge(ChallengesCompanion c) => into(challenges).insert(c);

  Future<void> deleteChallenge(int id) => (delete(challenges)..where((t) => t.id.equals(id))).go();

  Future<void> markChallengeRewarded(int id) =>
      (update(challenges)..where((t) => t.id.equals(id))).write(const ChallengesCompanion(rewarded: Value(true)));

  // ---- Patrimonio neto ----
  Stream<List<Holding>> watchHoldings() => select(holdings).watch();

  Future<int> addHolding(HoldingsCompanion h) => into(holdings).insert(h);

  Future<void> setHoldingAmount(int id, int amountMinor) =>
      (update(holdings)..where((t) => t.id.equals(id))).write(HoldingsCompanion(amountMinor: Value(amountMinor)));

  Future<void> deleteHolding(int id) => (delete(holdings)..where((t) => t.id.equals(id))).go();

  Stream<List<NetSnapshot>> watchNetSnapshots() =>
      (select(netSnapshots)..orderBy([(t) => OrderingTerm.asc(t.month)])).watch();

  /// Guarda (o reemplaza) el patrimonio del mes. Solo escribe si cambió.
  Future<void> upsertNetSnapshot(String month, int netMinor, String currency) async {
    final cur = await (select(netSnapshots)..where((t) => t.month.equals(month))).getSingleOrNull();
    if (cur != null && cur.netMinor == netMinor && cur.currency == currency) return;
    await into(netSnapshots).insertOnConflictUpdate(
        NetSnapshotsCompanion.insert(month: month, netMinor: netMinor, currency: currency));
  }

  // ---- Hábitos de gasto (autobús, merienda...) ----
  Stream<List<Habit>> watchHabits() => select(habits).watch();

  Future<int> addHabit(HabitsCompanion h) => into(habits).insert(h);

  Future<void> deleteHabit(int id) => (delete(habits)..where((t) => t.id.equals(id))).go();

  Future<void> setHabitActive(int id, bool active) =>
      (update(habits)..where((t) => t.id.equals(id))).write(HabitsCompanion(active: Value(active)));

  /// Anota los gastos de los hábitos que ya tocan (hasta hoy, incluido) y que
  /// todavía no se generaron. Un movimiento por día: veces al día × precio.
  /// Devuelve cuántos movimientos creó.
  Future<int> generateDueHabits(DateTime now) async {
    final all = await (select(habits)..where((t) => t.active.equals(true))).get();
    var created = 0;
    for (final h in all) {
      final days = HabitRule.daysToGenerate(
        mask: h.weekdays,
        createdOn: h.createdOn,
        lastGenerated: HabitRule.parseDayKey(h.lastGenerated),
        today: now,
      );
      for (final d in days) {
        final isToday = HabitRule.dayOnly(d) == HabitRule.dayOnly(now);
        // A las 8 de la mañana, salvo hoy si todavía no son las 8 (no queda en el futuro).
        final at = isToday && now.hour < 8 ? now : DateTime(d.year, d.month, d.day, 8);
        await into(txns).insert(TxnsCompanion.insert(
          kind: 'expense',
          amountMinor: HabitRule.perDay(h.unitPriceMinor, h.timesPerDay),
          currency: h.currency,
          categoryId: Value(h.categoryId),
          note: Value(h.timesPerDay > 1 ? '${h.name} ×${h.timesPerDay}' : h.name),
          date: at,
        ));
        created++;
      }
      await (update(habits)..where((t) => t.id.equals(h.id)))
          .write(HabitsCompanion(lastGenerated: Value(HabitRule.dayKey(now))));
    }
    return created;
  }

  // ---- Deudas ----
  Stream<List<Debt>> watchDebts() => select(debts).watch();

  Future<int> addDebt(DebtsCompanion d) => into(debts).insert(d);

  Future<void> deleteDebt(int id) => (delete(debts)..where((t) => t.id.equals(id))).go();

  /// Registra un pago: baja el saldo (nunca por debajo de 0).
  Future<void> payDebt(int id, int amountMinor) async {
    final d = await (select(debts)..where((t) => t.id.equals(id))).getSingle();
    final next = d.balanceMinor - amountMinor;
    await (update(debts)..where((t) => t.id.equals(id)))
        .write(DebtsCompanion(balanceMinor: Value(next < 0 ? 0 : next)));
  }

  // ---- Recurrentes ----
  Stream<List<Recurring>> watchRecurrings() => select(recurrings).watch();

  Future<int> addRecurring(RecurringsCompanion r) => into(recurrings).insert(r);

  Future<void> deleteRecurring(int id) =>
      (delete(recurrings)..where((t) => t.id.equals(id))).go();

  Future<void> setRecurringActive(int id, bool active) =>
      (update(recurrings)..where((t) => t.id.equals(id)))
          .write(RecurringsCompanion(active: Value(active)));

  /// Crea los gastos del mes que ya vencieron y todavía no se generaron.
  /// Devuelve cuántos creó.
  Future<int> generateDueRecurrings(DateTime now) async {
    final all = await (select(recurrings)..where((t) => t.active.equals(true))).get();
    var created = 0;
    for (final r in all) {
      if (!RecurringRule.isDue(r.dayOfMonth, now, r.lastMonth)) continue;
      await into(txns).insert(TxnsCompanion.insert(
        kind: 'expense',
        amountMinor: r.amountMinor,
        currency: r.currency,
        categoryId: Value(r.categoryId),
        note: Value(r.name),
        date: RecurringRule.dateFor(r.dayOfMonth, now),
      ));
      await (update(recurrings)..where((t) => t.id.equals(r.id)))
          .write(RecurringsCompanion(lastMonth: Value(RecurringRule.monthKey(now))));
      created++;
    }
    return created;
  }

  /// Todos los movimientos (para informes y exportar).
  Future<List<Txn>> allTxns() => (select(txns)
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();

  /// Movimientos desde [from] (stream, para informes).
  Stream<List<Txn>> watchTxnsSince(DateTime from) =>
      (select(txns)..where((t) => t.date.isBiggerOrEqualValue(from))).watch();

  Future<void> _seedCategories() async {
    const seed = [
      // Las de uso diario primero (aparecen arriba al anotar un gasto).
      ('Comida afuera', 'food', 'o', 'want'),
      ('Transporte', 'bus', 'b', 'need'),
      ('Súper', 'cart', 'g', 'need'),
      ('Ocio', 'clapper', 'p', 'want'),
      ('Alquiler', 'home', 'b', 'need'),
      ('Servicios', 'bulb', 'r', 'need'),
      ('Salud', 'health', 'r', 'need'),
      ('Educación', 'book', 'b', 'need'),
      ('Suscripciones', 'tv', 'p', 'want'),
      ('Compras', 'tag', 'p', 'want'),
    ];
    var i = 0;
    for (final s in seed) {
      await into(categories).insert(CategoriesCompanion.insert(
        name: s.$1,
        icon: s.$2,
        tone: Value(s.$3),
        block: Value(s.$4),
        sortOrder: Value(i++),
      ));
    }
  }

  // ---- Ajustes ----
  Future<String?> getSetting(String key) async {
    final row = await (select(settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Stream<Map<String, String>> watchSettings() => select(settings)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});

  // ---- Movimientos ----
  Stream<List<Txn>> watchTxnsBetween(DateTime from, DateTime to) =>
      (select(txns)
            ..where((t) => t.date.isBiggerOrEqualValue(from) & t.date.isSmallerThanValue(to))
            ..orderBy([
              (t) => OrderingTerm.desc(t.date),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  Future<int> addTxn(TxnsCompanion entry) => into(txns).insert(entry);

  Future<void> deleteTxn(int id) =>
      (delete(txns)..where((t) => t.id.equals(id))).go();

  // ---- Categorías ----
  Stream<List<Category>> watchCategories() => (select(categories)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<void> setCategoryLimit(int id, int? limitMinor) =>
      (update(categories)..where((t) => t.id.equals(id)))
          .write(CategoriesCompanion(monthlyLimitMinor: Value(limitMinor)));

  // ---- Metas ----
  Stream<List<Goal>> watchGoals() => select(goals).watch();

  Future<int> addGoal(GoalsCompanion g) => into(goals).insert(g);

  Future<void> addToGoal(int id, int amountMinor) async {
    final g = await (select(goals)..where((t) => t.id.equals(id))).getSingle();
    await (update(goals)..where((t) => t.id.equals(id)))
        .write(GoalsCompanion(savedMinor: Value(g.savedMinor + amountMinor)));
  }

  Future<void> setGoalTarget(int id, int targetMinor) =>
      (update(goals)..where((t) => t.id.equals(id))).write(GoalsCompanion(targetMinor: Value(targetMinor)));

  // ---- Días ----
  Stream<List<DateTime>> watchLoggedDays() => customSelect(
        'SELECT date AS d FROM txns UNION SELECT day AS d FROM day_checks',
        readsFrom: {txns, dayChecks},
      ).watch().map((rows) => [
            for (final r in rows)
              DateTime.fromMillisecondsSinceEpoch(r.read<int>('d') * 1000),
          ]);

  Future<void> markNoSpendDay(DateTime day) => into(dayChecks).insert(
        DayChecksCompanion.insert(day: DateTime(day.year, day.month, day.day)),
        mode: InsertMode.insertOrIgnore,
      );
}
