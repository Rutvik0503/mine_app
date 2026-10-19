import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/auth/model/profile_model.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/server_model/referral/model/referral_model.dart';
import '../../../core/server_model/referral/repository/referral_repository.dart';
import '../../../core/services/analytics_service.dart';

class ReferralController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ReferralRepository _referralRepository = ReferralRepository();

  final isLoading = true.obs;
  final profile = Rxn<ProfileModel>();
  final referrals = <ReferralModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _authRepository.currentProfile(),
        _referralRepository.myReferrals(),
      ]);
      profile.value = results[0] as ProfileModel?;
      referrals.value = results[1] as List<ReferralModel>;
    } finally {
      isLoading.value = false;
    }
  }

  int get activeCount => _referralRepository.activeCount(referrals);

  void copyCode() {
    final code = profile.value?.referralCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    AppSnackbar.success('Referral code copied!'.tr);
  }

  Future<void> shareCode() async {
    final code = profile.value?.referralCode;
    if (code == null) return;
    await AnalyticsService.logReferralInvite();
    await Share.share('Join me on Virtual Mining Empire! Use my code $code to get started.');
  }
}
