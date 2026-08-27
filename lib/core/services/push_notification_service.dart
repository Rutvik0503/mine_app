import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps Firebase Cloud Messaging for push notifications. Safe no-op if
/// Firebase hasn't been configured yet (see README "Firebase setup").
class PushNotificationService {
  PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      FirebaseMessaging.onMessage.listen(_showLocalNotification);
      _ready = true;
    } catch (e) {
      debugPrint('PushNotificationService.init failed (Firebase not configured yet): $e');
    }
  }

  static Future<String?> getToken() async {
    if (!_ready) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('PushNotificationService.getToken failed: $e');
      return null;
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const androidDetails = AndroidNotificationDetails(
      'mining_channel',
      'Mining Notifications',
      channelDescription: 'Mining sessions, streaks, missions and events',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}
