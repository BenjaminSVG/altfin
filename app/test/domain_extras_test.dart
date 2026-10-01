import 'dart:math';

import 'package:altfin/domain/csv_export.dart';
import 'package:altfin/domain/money.dart';
import 'package:altfin/domain/pin.dart';
import 'package:altfin/domain/recurring_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringRule', () {
    test('toca cuando llegó el día y no se generó este mes', () {
      expect(RecurringRule.isDue(5, DateTime(2026, 10, 5), ''), isTrue);
      expect(RecurringRule.isDue(5, DateTime(2026, 10, 4), ''), isFalse);
      expect(RecurringRule.isDue(5, DateTime(2026, 10, 20), '2026-09'), isTrue);
    });
    test('no se duplica en el mismo mes', () {
      expect(RecurringRule.isDue(5, DateTime(2026, 10, 20), '2026-10'), isFalse);
    });
    test('día 31 en mes corto cae el último día', () {
      expect(RecurringRule.effectiveDay(31, DateTime(2026, 2, 10)), 28);
      expect(RecurringRule.isDue(31, DateTime(2026, 2, 27), ''), isFalse);
      expect(RecurringRule.isDue(31, DateTime(2026, 2, 28), ''), isTrue);
      expect(RecurringRule.dateFor(31, DateTime(2028, 2, 3)).day, 29);
    });
    test('clave de mes', () {
      expect(RecurringRule.monthKey(DateTime(2026, 3, 9)), '2026-03');
    });
  });

  group('CsvExport', () {
    test('formato de monto', () {
      expect(CsvExport.amount(18000, Currency.pyg), '18000');
      expect(CsvExport.amount(1250, Currency.usd), '12.50');
      expect(CsvExport.amount(5, Currency.usd), '0.05');
    });
    test('escapa comas y comillas, y lleva BOM', () {
      final csv = CsvExport.build([
        CsvRow(
          date: DateTime(2026, 10, 1),
          kind: 'expense',
          category: 'Comida afuera',
          note: 'Pizza, "grande"',
          amountMinor: 35000,
          currency: Currency.pyg,
        ),
        CsvRow(
          date: DateTime(2026, 10, 2),
          kind: 'income',
          category: '',
          note: 'Sueldo',
          amountMinor: 500000,
          currency: Currency.usd,
        ),
      ]);
      final lines = csv.split('\r\n');
      expect(csv.startsWith('﻿fecha,tipo,categoria,nota,monto,moneda'), isTrue);
      expect(lines[1], '2026-10-01,Gasto,Comida afuera,"Pizza, ""grande""",35000,PYG');
      expect(lines[2], '2026-10-02,Ingreso,,Sueldo,5000.00,USD');
    });
  });

  group('PinLock', () {
    test('valida formato', () {
      expect(PinLock.isValidFormat('1234'), isTrue);
      expect(PinLock.isValidFormat('123'), isFalse);
      expect(PinLock.isValidFormat('12a4'), isFalse);
    });
    test('verifica el PIN correcto y rechaza el incorrecto', () {
      final salt = PinLock.newSalt(Random(1));
      final h = PinLock.hash('4321', salt);
      expect(h, isNot(contains('4321')));
      expect(PinLock.verify('4321', salt, h), isTrue);
      expect(PinLock.verify('1234', salt, h), isFalse);
      expect(PinLock.verify('abcd', salt, h), isFalse);
    });
    test('la sal cambia el hash', () {
      expect(PinLock.hash('1111', 'a'), isNot(PinLock.hash('1111', 'b')));
    });
  });
}
