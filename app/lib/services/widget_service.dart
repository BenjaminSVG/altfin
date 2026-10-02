import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/money.dart';

/// Textos que muestran los widgets de la pantalla de inicio de Android.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.todayValue,
    required this.todayLabel,
    required this.streakValue,
    required this.streakLabel,
    required this.loggedLabel,
    required this.balanceValue,
    required this.balanceLabel,
  });

  final String todayValue, todayLabel, streakValue, streakLabel, loggedLabel, balanceValue, balanceLabel;

  factory WidgetSnapshot.build({
    required bool hasIncome,
    required Money dailyAllowance,
    required int streak,
    required bool loggedToday,
    Money? available,
  }) =>
      WidgetSnapshot(
        todayValue: hasIncome ? dailyAllowance.format() : 'Sin sueldo',
        todayLabel: hasIncome ? 'PODÉS GASTAR HOY' : 'Cargá tu sueldo',
        streakValue: '$streak',
        streakLabel: streak == 1 ? 'día de racha' : 'días de racha',
        loggedLabel: loggedToday ? 'Hoy ya anotaste' : 'Hoy falta anotar',
        balanceValue: available == null ? 'Cargá tu dinero' : available.format(),
        balanceLabel: 'DINERO DISPONIBLE',
      );

  Map<String, String> toMap() => {
        'today_value': todayValue,
        'today_label': todayLabel,
        'streak_value': streakValue,
        'streak_label': streakLabel,
        'logged_label': loggedLabel,
        'balance_value': balanceValue,
        'balance_label': balanceLabel,
      };
}

/// Widgets de la pantalla de inicio (solo Android; en PC no existen).
/// Cada widget abre directo su pantalla con enlaces como `altfin://add?kind=income`, `altfin://balance` o `altfin://budget`.
class WidgetService {
  WidgetService._();
  static final instance = WidgetService._();

  /// Nombres de las clases Kotlin de cada widget.
  static const providers = [
    'QuickAddWidgetProvider',
    'TodayWidgetProvider',
    'BalanceWidgetProvider',
    'StreakWidgetProvider',
  ];

  bool get _supported => !kIsWeb && Platform.isAndroid;

  String? _last;

  Future<void> push(WidgetSnapshot s) async {
    if (!_supported) return;
    final key = s.toMap().values.join('|');
    if (key == _last) return;
    _last = key;
    try {
      for (final e in s.toMap().entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      for (final p in providers) {
        await HomeWidget.updateWidget(qualifiedAndroidName: 'py.altfin.altfin.$p');
      }
    } catch (_) {
      // Sin widgets colocados no pasa nada.
    }
  }

  /// Llama a [onUri] cuando la app se abre (o ya estaba abierta) desde un widget.
  StreamSubscription<Uri?>? listen(void Function(Uri uri) onUri) {
    if (!_supported) return null;
    HomeWidget.initiallyLaunchedFromHomeWidget().then((u) {
      if (u != null) onUri(u);
    }).catchError((_) {});
    return HomeWidget.widgetClicked.listen((u) {
      if (u != null) onUri(u);
    });
  }
}
