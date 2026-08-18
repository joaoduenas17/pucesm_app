import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // =========================
  // INIT
  // =========================
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  // =========================
  // PERMISSIONS
  // =========================
  static Future<bool> requestPermissions() async {
    try {
      final iosGranted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      final androidGranted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      return iosGranted ?? androidGranted ?? true;
    } on PlatformException {
      return false;
    }
  }

  // =========================
  // INSTANT (TEST)
  // =========================
  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'Notificaciones generales',
      channelDescription: 'Notificaciones generales de la app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  // =========================
  // SCHEDULE
  // =========================
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'calendar_reminders',
      'Recordatorios del calendario',
      channelDescription: 'Notificaciones de eventos del calendario académico',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  // =========================
  // CANCEL
  // =========================
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
