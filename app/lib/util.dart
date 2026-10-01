import 'domain/money.dart';

String fmt(Money m) => m.format();

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];
const _wd = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

String monthName(DateTime d) => _months[d.month - 1];
String monthTitle(DateTime d) {
  final n = monthName(d);
  return '${n[0].toUpperCase()}${n.substring(1)} ${d.year}';
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "Hoy", "Ayer" o "jue 1 oct".
String dayLabel(DateTime d, DateTime now) {
  final a = dayOnly(d), b = dayOnly(now);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return '${_wd[d.weekday - 1]} ${d.day} ${monthName(d).substring(0, 3)}';
}
