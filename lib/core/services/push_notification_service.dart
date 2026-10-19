import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'language_service.dart';
import 'supabase_service.dart';

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

      // Server pushes (verify the channel id matches _shared/fcm.ts) show in
      // this channel when the app is in the background.
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      FirebaseMessaging.onMessage.listen(_showLocalNotification);
      messaging.onTokenRefresh.listen((_) => saveTokenForCurrentUser());
      _ready = true;
      await syncTopics();
      // Keep token + language fresh for an already signed-in player.
      await saveTokenForCurrentUser();
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

  /// Saves this device's current FCM token against the logged-in user (spec
  /// section 30, "store device tokens securely") via a security-definer RPC
  /// (see migration 0007) - safe no-op until Firebase is configured or if
  /// the user isn't logged in yet.
  static const _channel = AndroidNotificationChannel(
    'mining_channel',
    'Mining Notifications',
    description: 'Friend referrals, offers and news from Virtual Mining Empire',
    importance: Importance.high,
  );

  /// Firebase Console campaigns can target everyone ("all") or one
  /// language ("lang_en" / "lang_gu" / "lang_hi"). Call again after the
  /// player changes language.
  static Future<void> syncTopics() async {
    if (!_ready) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final current = LanguageService.locale.value.languageCode;
      await messaging.subscribeToTopic('all');
      for (final l in LanguageService.supported) {
        final topic = 'lang_${l.languageCode}';
        if (l.languageCode == current) {
          await messaging.subscribeToTopic(topic);
        } else {
          await messaging.unsubscribeFromTopic(topic);
        }
      }
    } catch (e) {
      debugPrint('PushNotificationService.syncTopics failed: $e');
    }
  }

  static Future<void> saveTokenForCurrentUser() async {
    if (!SupabaseService.isLoggedIn) return;
    final token = await getToken();
    if (token == null) return;
    try {
      await SupabaseService.client.rpc('save_device_token', params: {
        'p_token': token,
        'p_platform': Platform.isIOS ? 'ios' : 'android',
        // Server pushes are sent in this language.
        'p_language': LanguageService.locale.value.languageCode,
      });
    } catch (e) {
      debugPrint('PushNotificationService.saveTokenForCurrentUser failed: $e');
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
