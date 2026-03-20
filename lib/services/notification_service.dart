import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        FlutterLocalNotificationsPlugin,
        AndroidNotificationDetails,
        DarwinNotificationDetails,
        NotificationDetails,
        Importance,
        Priority,
        AndroidScheduleMode,
        UILocalNotificationDateInterpretation;

// Plugin instance — initialized in main.dart
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static const _channelId = 'taskmaster_channel';
  static const _channelName = 'TaskMaster Reminders';

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await notificationsPlugin.zonedSchedule(
      id,
      '⏰ $title',
      body.isEmpty ? 'Time to work on this task!' : body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Task reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(int id) async {
    await notificationsPlugin.cancel(id);
  }

  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
