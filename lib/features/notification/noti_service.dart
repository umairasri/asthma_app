import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  // Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return false;
  }

  //  INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    try {
      // Check and request permission first
      final hasPermission = await isNotificationPermissionGranted();
      if (!hasPermission) {
        final granted = await requestNotificationPermission();
        if (!granted) {
          return; // Exit if permission not granted
        }
      }

      // prepare android init settings
      const initSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // init settings
      const initSettings = InitializationSettings(android: initSettingsAndroid);

      // finally, initialize the plugin!
      await notificationsPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  // NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notification',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }

    try {
      // Check permission before showing notification
      if (!await isNotificationPermissionGranted()) {
        return;
      }
      return notificationsPlugin.show(id, title, body, notificationDetails());
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Show medication usage warning
  Future<void> showMedicationUsageWarning({required String username}) async {
    if (!_isInitialized) {
      await initNotification();
    }

    try {
      // Check permission before showing notification
      if (!await isNotificationPermissionGranted()) {
        return;
      }
      return notificationsPlugin.show(
        1, // Using a different ID for medication warnings
        'High Medication Usage Warning',
        '$username has used Blue Inhaler Salbutamol more than 4 times today. Please consult your healthcare provider.',
        notificationDetails(),
      );
    } catch (e) {
      print('Error showing medication warning: $e');
    }
  }

  // ON NOTI TAP
}
