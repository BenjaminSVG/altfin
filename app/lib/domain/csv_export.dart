import 'money.dart';

/// Una fila para exportar (independiente de la base de datos).
class CsvRow {
  const CsvRow({
    required this.date,
    required this.kind,
    required this.category,
    required this.note,
    required this.amountMinor,
    required this.currency,
  });

  final DateTime date;
  final String kind; // expense | income | saving
  final String category;
  final String note;
  final int amountMinor;
  final Currency currency;
}

class CsvExport {
  const CsvExport._();

  static String _kindLabel(String k) => switch (k) {
        'income' => 'Ingreso',
        'saving' => 'Ahorro',
        _ => 'Gasto',
      };

  static String _cell(String s) {
    final needsQuotes = s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    final escaped = s.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  /// Monto con punto decimal y sin separador de miles (lo entiende Excel).
  static String amount(int minor, Currency c) {
    if (c.decimals == 0) return '$minor';
    final abs = minor.abs();
    final sign = minor < 0 ? '-' : '';
    return '$sign${abs ~/ c.factor}.${(abs % c.factor).toString().padLeft(c.decimals, '0')}';
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// CSV con encabezado. Lleva BOM UTF-8 para que Excel muestre bien las tildes.
  static String build(List<CsvRow> rows) {
    final b = StringBuffer('﻿fecha,tipo,categoria,nota,monto,moneda\r\n');
    for (final r in rows) {
      b.write([
        _date(r.date),
        _kindLabel(r.kind),
        _cell(r.category),
        _cell(r.note),
        amount(r.amountMinor, r.currency),
        r.currency.code,
      ].join(','));
      b.write('\r\n');
    }
    return b.toString();
  }
}
