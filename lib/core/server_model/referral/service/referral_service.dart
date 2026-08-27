import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/referral_model.dart';

class ReferralService {
  final _client = SupabaseService.client;

  Future<List<ReferralModel>> fetchMyReferrals() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.referrals)
        .select()
        .eq('referrer_id', userId)
        .order('created_at', ascending: false);
    return rows.map((e) => ReferralModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> applyReferralCode(String code) {
    return SupabaseService.invoke(
      ApiConstant.fnActivateReferral,
      body: {'referral_code': code},
    );
  }
}
