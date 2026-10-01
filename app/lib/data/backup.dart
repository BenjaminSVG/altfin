import 'dart:convert';

import 'database.dart';

/// Copia de seguridad completa en un archivo JSON (todo se guarda local,
/// así que esta copia es la única forma de no perder los datos al cambiar de equipo).
class Backup {
  const Backup._();

  static const format = 'altfin-backup';
  static const version = 1;

  static Future<Map<String, dynamic>> toMap(AppDatabase db) async => {
        'format': format,
        'version': version,
        'createdAt': DateTime.now().toIso8601String(),
        'categories': [for (final r in await db.select(db.categories).get()) r.toJson()],
        'txns': [for (final r in await db.select(db.txns).get()) r.toJson()],
        'goals': [for (final r in await db.select(db.goals).get()) r.toJson()],
        'dayChecks': [for (final r in await db.select(db.dayChecks).get()) r.toJson()],
        'settings': [for (final r in await db.select(db.settings).get()) r.toJson()],
        'recurrings': [for (final r in await db.select(db.recurrings).get()) r.toJson()],
        'debts': [for (final r in await db.select(db.debts).get()) r.toJson()],
      };

  static Future<String> toJsonString(AppDatabase db) async =>
      const JsonEncoder.withIndent(' ').convert(await toMap(db));

  /// Valida que el texto sea una copia de AltFin. Lanza [FormatException] si no.
  static Map<String, dynamic> parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw const FormatException('El archivo no es una copia de AltFin.');
    }
    if (decoded is! Map<String, dynamic> || decoded['format'] != format) {
      throw const FormatException('El archivo no es una copia de AltFin.');
    }
    final v = decoded['version'];
    if (v is! int || v > version) {
      throw const FormatException('La copia es de una versión más nueva de AltFin.');
    }
    for (final k in const ['categories', 'txns', 'goals', 'dayChecks', 'settings', 'recurrings']) {
      if (decoded[k] is! List) throw FormatException('Copia incompleta: falta "$k".');
    }
    return decoded;
  }

  /// Reemplaza TODOS los datos actuales por los de la copia (en una sola
  /// transacción: si algo falla, no se pierde nada).
  static Future<void> restore(AppDatabase db, Map<String, dynamic> m) async {
    // 'debts' puede faltar en copias hechas con versiones anteriores.
    List<Map<String, dynamic>> rows(String k) =>
        [for (final e in (m[k] as List? ?? const [])) Map<String, dynamic>.from(e as Map)];
    await db.transaction(() async {
      await db.delete(db.txns).go();
      await db.delete(db.recurrings).go();
      await db.delete(db.debts).go();
      await db.delete(db.goals).go();
      await db.delete(db.dayChecks).go();
      await db.delete(db.settings).go();
      await db.delete(db.categories).go();
      await db.batch((b) {
        b.insertAll(db.categories, [for (final r in rows('categories')) Category.fromJson(r).toCompanion(true)]);
        b.insertAll(db.txns, [for (final r in rows('txns')) Txn.fromJson(r).toCompanion(true)]);
        b.insertAll(db.goals, [for (final r in rows('goals')) Goal.fromJson(r).toCompanion(true)]);
        b.insertAll(db.dayChecks, [for (final r in rows('dayChecks')) DayCheck.fromJson(r).toCompanion(true)]);
        b.insertAll(db.settings, [for (final r in rows('settings')) Setting.fromJson(r).toCompanion(true)]);
        b.insertAll(db.debts, [for (final r in rows('debts')) Debt.fromJson(r).toCompanion(true)]);
        b.insertAll(db.recurrings, [for (final r in rows('recurrings')) Recurring.fromJson(r).toCompanion(true)]);
      });
    });
  }
}
