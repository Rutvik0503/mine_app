import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps Google AdMob rewarded/interstitial/banner ads.
///
/// Ad unit IDs below are Google's public TEST ids so the app runs out of the
/// box in debug. Replace with your real AdMob unit IDs before release (see
/// README "AdMob setup").
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _ready = false;

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _ready = true;
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdsService.init failed (AdMob not configured yet): $e');
    }
  }

  String get rewardedUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? _testRewardedIOS
      : _testRewardedAndroid;

  String get interstitialUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? _testInterstitialIOS
      : _testInterstitialAndroid;

  String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS ? _testBannerIOS : _testBannerAndroid;

  void loadRewardedAd() {
    if (!_ready) return;
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (e) => debugPrint('Rewarded ad failed to load: $e'),
      ),
    );
  }

  void loadInterstitialAd() {
    if (!_ready) return;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (e) => debugPrint('Interstitial ad failed to load: $e'),
      ),
    );
  }

  /// Shows a rewarded ad. [onUserEarnedReward] fires ONLY once the user
  /// completes the full ad - the app must grant the in-app benefit there,
  /// never on a plain "ad shown" callback.
  Future<bool> showRewardedAd({required VoidCallback onUserEarnedReward}) async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }
    var earned = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
        onUserEarnedReward();
      },
    );
    _rewardedAd = null;
    loadRewardedAd();
    return earned;
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) return;
    await _interstitialAd!.show();
    _interstitialAd = null;
    loadInterstitialAd();
  }

  BannerAd createBanner({required VoidCallback onLoaded}) {
    final banner = BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, e) {
          debugPrint('Banner ad failed to load: $e');
          ad.dispose();
        },
      ),
    );
    banner.load();
    return banner;
  }
}
