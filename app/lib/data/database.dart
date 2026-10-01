import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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

@DriftDatabase(tables: [Categories, Txns, Goals, DayChecks, Settings, Recurrings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'altfin'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(recurrings);
        },
      );

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
