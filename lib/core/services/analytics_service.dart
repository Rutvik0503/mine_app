import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Analytics. Every call is guarded so the app keeps working
/// even before Firebase is configured (see README "Firebase setup").
class AnalyticsService {
  AnalyticsService._();

  static bool _ready = false;

  static void markReady() => _ready = true;

  static Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    if (!_ready) return;
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('AnalyticsService.logEvent($name) failed: $e');
    }
  }

  static Future<void> setUserId(String? id) async {
    if (!_ready) return;
    try {
      await FirebaseAnalytics.instance.setUserId(id: id);
    } catch (e) {
      debugPrint('AnalyticsService.setUserId failed: $e');
    }
  }

  // Common product events
  static Future<void> logSignup(String method) => logEvent('signup', params: {'method': method});
  static Future<void> logLogin(String method) => logEvent('login', params: {'method': method});
  static Future<void> logStartMining() => logEvent('start_mining');
  static Future<void> logClaimReward(num amount) => logEvent('claim_reward', params: {'amount': amount});
  static Future<void> logUpgradeMachine(String machineId, int level) =>
      logEvent('upgrade_machine', params: {'machine_id': machineId, 'level': level});
  static Future<void> logMissionComplete(String missionId) =>
      logEvent('mission_complete', params: {'mission_id': missionId});
  static Future<void> logReferralInvite() => logEvent('referral_invite');
  static Future<void> logRewardedAdComplete(String placement) =>
      logEvent('rewarded_ad_complete', params: {'placement': placement});
}
