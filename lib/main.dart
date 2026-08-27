import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/ads_service.dart';
import 'core/services/session_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();
  await SessionService.init();

  // Fire-and-forget: these are safe no-ops until Firebase/AdMob are
  // configured (see README "Firebase setup" / "AdMob setup").
  unawaited(AdsService.instance.init());

  runApp(const MiningApp());
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
          initialRoute: AppRoutes.splash,
          initialBinding: InitialBinding(),
          getPages: AppPages.pages,
        );
      },
    );
  }
}
