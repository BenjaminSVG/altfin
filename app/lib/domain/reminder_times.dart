/// Horas de los recordatorios diarios, en minutos desde medianoche
/// (20:00 = 1200). Se guardan como texto "09:00,14:30,20:00".
class ReminderTimes {
  const ReminderTimes._();

  static const max = 6;
  static const defaultTimes = [20 * 60];

  /// Lee la lista guardada. Si no hay ninguna (instalaciones viejas), usa la
  /// hora única de antes ([legacyHour]) o las 20:00.
  static List<int> parse(String? csv, {int? legacyHour}) {
    final out = <int>{};
    for (final part in (csv ?? '').split(',')) {
      final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(part);
      if (m == null) continue;
      final h = int.parse(m.group(1)!), mi = int.parse(m.group(2)!);
      if (h < 24 && mi < 60) out.add(h * 60 + mi);
    }
    if (out.isEmpty) {
      if (legacyHour != null && legacyHour >= 0 && legacyHour < 24) return [legacyHour * 60];
      return defaultTimes;
    }
    return _clean(out);
  }

  static String encode(Iterable<int> times) => _clean(times).map(format).join(',');

  /// Ordenadas, sin repetidas y como mucho [max].
  static List<int> _clean(Iterable<int> times) {
    final l = times.toSet().toList()..sort();
    return l.length > max ? l.sublist(0, max) : l;
  }

  static String format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  static List<int> add(List<int> times, int minutes) => _clean([...times, minutes]);

  static List<int> remove(List<int> times, int minutes) {
    final l = [...times]..remove(minutes);
    return l.isEmpty ? defaultTimes : l;
  }

  static List<int> replace(List<int> times, int old, int minutes) => _clean([...times.where((t) => t != old), minutes]);
}
