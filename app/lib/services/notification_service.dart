import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Recordatorios locales de Finn para que el usuario anote sus gastos.
/// Todo ocurre en el dispositivo (sin servidor).
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'altfin_recordatorios';

  /// Frases de Finn (varían para no ser repetitivo).
  static const _messages = [
    ('¿Cómo te fue hoy?', 'Anotá tus gastos en 5 segundos y mantené tu racha.'),
    ('Finn te extraña', 'Un minuto para anotar lo de hoy y seguís ahorrando.'),
    ('¡Hora de anotar!', 'Cada registro suma. ¿Qué gastaste hoy?'),
    ('Tu plata te lo agradece', 'Anotá tus gastos de hoy y mirá cómo vas.'),
    ('Racha en marcha', 'Un registro más y seguís sumando XP.'),
    ('¿Tereré, almuerzo, bus?', 'Que no se te pase nada: anotalo ahora.'),
  ];

  Future<void> init() async {
    if (_ready) return;
    // Por ahora solo Android: el plugin de Windows cierra la app al iniciar
    // (pendiente de investigar). En PC se usará otra vía.
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/Asuncion'));
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_finn'),
      windows: WindowsInitializationSettings(
        appName: 'AltFin',
        appUserModelId: 'py.altfin.AltFin',
        guid: '7d5a4a52-5d56-4b8f-9b0a-3f0d9c0a1a11',
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (e) {
      debugPrint('Notificaciones no disponibles: $e');
    }
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Recordatorios de Finn',
          channelDescription: 'Te recuerdo anotar tus gastos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        windows: WindowsNotificationDetails(),
      );

  /// Reprograma los próximos 14 días. Se llama al abrir la app, al registrar
  /// un gasto y al cambiar los ajustes. En Windows las notificaciones no se
  /// repiten solas, por eso se agendan día por día.
  Future<void> reschedule({
    required bool enabled,
    required int hour,
    required bool loggedToday,
    required int streak,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!enabled) return;
      final now = tz.TZDateTime.now(tz.local);
      for (var i = 0; i < 14; i++) {
        if (i == 0 && loggedToday) continue;
        final at = tz.TZDateTime(tz.local, now.year, now.month, now.day + i, hour);
        if (at.isBefore(now)) continue;
        final m = _messages[(now.day + i) % _messages.length];
        await _plugin.zonedSchedule(
          id: 100 + i,
          title: m.$1,
          body: m.$2,
          scheduledDate: at,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      // Aviso de racha en peligro: hoy, 2 h antes de medianoche.
      if (!loggedToday && streak > 0) {
        final risk = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
        if (risk.isAfter(now)) {
          await _plugin.zonedSchedule(
            id: 200,
            title: 'Tu racha de $streak ${streak == 1 ? 'día' : 'días'} termina esta noche',
            body: 'Anotá un gasto o tocá "Hoy no gasté" para no perderla.',
            scheduledDate: risk,
            notificationDetails: _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
      }
    } catch (e) {
      debugPrint('No se pudieron agendar notificaciones: $e');
    }
  }

  /// Notificación inmediata de prueba (botón en Ajustes).
  Future<void> showTest() async {
    if (!_ready) return;
    if (!await requestPermission()) return;
    await _plugin.show(
      id: 1,
      title: '¡Hola, soy Finn!',
      body: 'Así te voy a recordar anotar tus gastos.',
      notificationDetails: _details,
    );
  }
}
