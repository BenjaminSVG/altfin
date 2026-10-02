import 'package:altfin/domain/reminder_times.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee varias horas, ordenadas y sin repetidas', () {
    expect(ReminderTimes.parse('20:00,09:00,14:30,09:00'), [540, 870, 1200]);
    expect(ReminderTimes.encode([1200, 540]), '09:00,20:00');
  });

  test('instalaciones viejas: usa la hora única de antes o las 20:00', () {
    expect(ReminderTimes.parse(null, legacyHour: 18), [1080]);
    expect(ReminderTimes.parse('', legacyHour: null), [1200]);
    expect(ReminderTimes.parse('basura,25:00,10:99'), [1200]);
  });

  test('agregar, cambiar y quitar; máximo 6 y nunca queda vacía', () {
    var t = ReminderTimes.parse('08:00');
    t = ReminderTimes.add(t, 20 * 60);
    expect(t, [480, 1200]);
    t = ReminderTimes.replace(t, 480, 9 * 60 + 30);
    expect(t, [570, 1200]);
    t = ReminderTimes.remove(t, 570);
    expect(t, [1200]);
    expect(ReminderTimes.remove(t, 1200), ReminderTimes.defaultTimes);
    var many = <int>[];
    for (var h = 6; h < 14; h++) {
      many = ReminderTimes.add(many, h * 60);
    }
    expect(many.length, ReminderTimes.max);
  });
}
