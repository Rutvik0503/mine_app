import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'push_notification_service.dart';

/// Persisted app language, backed by GetX's own translation system (see
/// core/translations/app_translations.dart) - no flutter_localizations
/// dependency needed for this.
class LanguageService {
  LanguageService._();

  static const _key = 'app_locale';
  static late SharedPreferences _prefs;

  static const Locale english = Locale('en', 'US');
  static const Locale gujarati = Locale('gu', 'IN');
  static const Locale hindi = Locale('hi', 'IN');

  static const supported = [english, gujarati, hindi];

  static final locale = english.obs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final code = _prefs.getString(_key);
    locale.value = supported.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => english,
    );
  }

  static Future<void> setLocale(Locale value) async {
    locale.value = value;
    await _prefs.setString(_key, value.languageCode);
    Get.updateLocale(value);
    // Server pushes and Firebase Console topics follow the new language.
    unawaited(PushNotificationService.saveTokenForCurrentUser());
    unawaited(PushNotificationService.syncTopics());
  }

  static String labelFor(Locale l) {
    switch (l.languageCode) {
      case 'gu':
        return 'ગુજરાતી';
      case 'hi':
        return 'हिन्दी';
      default:
        return 'English';
    }
  }
}
