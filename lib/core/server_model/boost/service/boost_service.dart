import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/user_boost_model.dart';

class BoostService {
  final _client = SupabaseService.client;

  Future<List<UserBoostModel>> fetchActiveBoosts() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.userBoosts)
        .select('*, boosts(*)')
        .eq('user_id', userId)
        .eq('status', 'active')
        // status stays 'active' after a boost runs out - same expiry check
        // start-mining uses, so the list matches what actually applies.
        .gt('expires_at', DateTime.now().toUtc().toIso8601String());
    return rows.map((e) => UserBoostModel.fromJson(e)).toList();
  }

  /// Grants (or extends) the ad-sourced mining boost server-side, after
  /// AdsService confirms the rewarded ad was watched to completion.
  Future<String> grantAdBoost() async {
    final result = await SupabaseService.invoke(ApiConstant.fnGrantAdBoost);
    return result['boost_name'] as String? ?? 'Boost';
  }
}
