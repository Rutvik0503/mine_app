import '../model/referral_model.dart';
import '../service/referral_service.dart';

class ReferralRepository {
  final ReferralService _service = ReferralService();

  Future<List<ReferralModel>> myReferrals() => _service.fetchMyReferrals();

  int activeCount(List<ReferralModel> referrals) =>
      referrals.where((r) => r.status == 'active').length;

  Future<void> applyCode(String code) => _service.applyReferralCode(code);
}
