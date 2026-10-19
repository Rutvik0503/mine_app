import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/ads_service.dart';
import 'core/services/language_service.dart';
import 'core/services/play_billing_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/session_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'core/translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebase();
  await SupabaseService.init();
  await SessionService.init();
  await ThemeService.init();
  await LanguageService.init();

  // Fire-and-forget: never block startup on ads or push.
  unawaited(AdsService.instance.init());
  unawaited(PushNotificationService.init());
  // Listen for Play purchases from the start, and grant any left unfinished
  // last time (app killed mid-purchase) for an already signed-in player.
  PlayBillingService.instance.init();
  unawaited(ReminderService.instance.init());
  unawaited(PlayBillingService.instance.recoverUnfinishedPurchases());

  runApp(const MiningApp());
}

/// Firebase powers push notifications, Analytics and Crashlytics. Android
/// reads android/app/google-services.json; iOS has no
/// GoogleService-Info.plist yet, so there this logs and the app carries on.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    // Keep crashes from development builds out of the dashboard.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
}

class MiningApp extends StatelessWidget {
  const MiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Virtual Mining Empire',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          translations: AppTranslations(),
          locale: LanguageService.locale.value,
          fallbackLocale: LanguageService.english,
          initialRoute: AppRoutes.splash,
          initialBinding: InitialBinding(),
          getPages: AppPages.pages,
        );
      },
    );
  }
}
