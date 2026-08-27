import 'package:supabase_flutter/supabase_flutter.dart';
import '../constant/api_constant.dart';

/// Thin wrapper around the Supabase client so the rest of the app never
/// touches `Supabase.instance` directly. Keeps the client swappable/mockable.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Future<void> init() async {
    await Supabase.initialize(
      url: ApiConstant.supabaseUrl,
      publishableKey: ApiConstant.supabaseAnonKey,
    );
  }

  /// Invokes a Supabase Edge Function and returns the decoded JSON body.
  /// Throws [EdgeFunctionException] on a non-2xx response.
  static Future<Map<String, dynamic>> invoke(
    String function, {
    Map<String, dynamic>? body,
  }) async {
    final res = await client.functions.invoke(function, body: body ?? {});
    final data = res.data;
    if (res.status < 200 || res.status >= 300) {
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Request failed (${res.status})';
      throw EdgeFunctionException(message, status: res.status);
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }
}

class EdgeFunctionException implements Exception {
  final String message;
  final int status;

  EdgeFunctionException(this.message, {this.status = 500});

  @override
  String toString() => message;
}
