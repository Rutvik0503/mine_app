import 'package:get/get.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Public on the leaderboard - mirrors cleanUsername in create-profile.
  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return required(v, field: 'Username'.tr);
    if (!RegExp(r'^[A-Za-z0-9_.]{3,20}$').hasMatch(v)) return 'usernameRules'.tr;
    return null;
  }
}
