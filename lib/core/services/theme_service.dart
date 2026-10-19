import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/app_color.dart';

/// Live Dark/Light theme switching. AppColor's neutral colors (background,
/// surface, border, text) are dynamic getters driven by [isDark] - toggling
/// it persists the choice and forces the whole app to rebuild via
/// Get.forceAppUpdate() so every screen re-reads the new colors immediately.
class ThemeService {
  ThemeService._();

  static const _key = 'is_dark_theme';
  static late SharedPreferences _prefs;

  static final isDark = true.obs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getBool(_key) ?? true;
    isDark.value = saved;
    AppColor.setDark(saved);
  }

  static Future<void> setDark(bool value) async {
    isDark.value = value;
    AppColor.setDark(value);
    await _prefs.setBool(_key, value);
    Get.forceAppUpdate();
  }
}
