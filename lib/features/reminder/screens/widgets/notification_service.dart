// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzData;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/src/platform_specifics/android/notification_details.dart';

// class NotificationService {
//   static final _notifications = FlutterLocalNotificationsPlugin();

//   static Future init() async {
//     // Initialize timezone
//     tzData.initializeTimeZones();
//     tz.setLocalLocation(
//         tz.getLocation('Asia/Kuala_Lumpur')); // or your local timezone

//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android);
//     await _notifications.initialize(settings);
//   }

//   static Future showNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     final details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'reminder_channel',
//         'Reminders',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     );

//     final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

//     await _notifications.zonedSchedule(
//       id,
//       title,
//       body,
//       tzScheduledDate,
//       details,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   static Future cancel(int id) async {
//     await _notifications.cancel(id);
//   }
// }
