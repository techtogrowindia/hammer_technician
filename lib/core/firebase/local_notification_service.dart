import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);
  }

  static Future<void> show(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'default_channel', // id
      'General Notifications', // name
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a unique id for each notification
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notifications.show(
      id: id, // positional
      title: message.notification?.title ?? 'Notification', // positional
      body: message.notification?.body ?? '', // positional
      notificationDetails: notificationDetails, // positional, not named
      payload: message.data['type'] ?? '', // optional
    );
  }
}
