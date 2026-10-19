import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps Google AdMob rewarded/interstitial/app-open/banner ads.
///
/// Release builds on Android use the real AdMob units below; debug/profile
/// builds (and iOS, until its AdMob app exists) use Google's public TEST
/// units - never tap real ads while developing, AdMob treats that as
/// invalid traffic.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIOS = 'ca-app-pub-3940256099942544/5575463023';
  static const String _testNativeAndroid = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeIOS = 'ca-app-pub-3940256099942544/3986624511';

  // Real AdMob units - app "Virtual Mining Empire" (Android),
  // App ID ca-app-pub-5350317534812840~7499523470.
  static const String _rewardedAndroid = 'ca-app-pub-5350317534812840/3567272461';
  static const String _interstitialAndroid = 'ca-app-pub-5350317534812840/6384832485';
  static const String _appOpenAndroid = 'ca-app-pub-5350317534812840/6760412019';
  static const String _bannerAndroid = 'ca-app-pub-5350317534812840/2672818183';
  static const String _nativeAndroid = 'ca-app-pub-5350317534812840/5323648202';

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get _useRealAndroidUnits => kReleaseMode && !_isIOS;

  /// The developer's own phones: AdMob serves them test ads even in release
  /// builds, so testing the Play build can't trigger invalid-traffic flags.
  /// Find a device's id in logcat: "Use RequestConfiguration...setTestDeviceIds".
  static const List<String> _testDeviceIds = [
    '220AE38F5EFDA2BD131862E23F118654', // CPH2763
  ];

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _ready = false;
  final Completer<void> _readyCompleter = Completer<void>();

  /// Completes once ads may be requested (consent gathered, SDK started).
  /// Never completes if the user declined consent.
  Future<void> get whenReady => _readyCompleter.future;

  // Interstitials only at natural breaks (after a claim), on every 2nd
  // claim, and never within [_fullScreenGap] of any other full-screen ad -
  // so a player who just watched a rewarded or app open ad isn't hit again.
  int _claimsSinceInterstitial = 0;
  static const _interstitialEveryNClaims = 2;
  static const _fullScreenGap = Duration(minutes: 3);
  DateTime? _lastFullScreenClosedAt;

  // Failed loads retry after 30s, 60s, 120s... (capped at 5 min), so an ad is
  // usually ready by the time a placement wants one.
  final Map<String, int> _loadFailures = {};

  Future<void> init() async {
    try {
      // Consent first (EEA/UK users see Google's UMP form, everyone else
      // passes straight through), and only request ads once it allows it.
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: _testDeviceIds),
      );
      await MobileAds.instance.initialize();
      _ready = true;
      if (!_readyCompleter.isCompleted) _readyCompleter.complete();
      loadRewardedAd();
      loadInterstitialAd();
      _loadAppOpenAd();
      _listenForAppResume();
    } catch (e) {
      debugPrint('AdsService.init failed (AdMob not configured yet): $e');
    }
  }

  /// Refreshes consent info and shows the UMP form when it's required.
  /// Never throws - on failure [ConsentInformation.canRequestAds] falls back
  /// to the consent stored from earlier launches.
  Future<void> _gatherConsent() async {
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => updated.complete(),
      (error) {
        debugPrint('Consent info update failed: ${error.message}');
        updated.complete();
      },
    );
    await updated.future;

    final shown = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) debugPrint('Consent form failed: ${error.message}');
      if (!shown.isCompleted) shown.complete();
    });
    await shown.future;
  }

  /// Whether Settings must offer "Ad privacy choices" (EEA/UK users).
  Future<bool> isPrivacyOptionsRequired() async {
    try {
      return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Lets the user review or change their ad consent.
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options form failed: ${error.message}');
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    // Consent may have just been granted - start ads if they weren't.
    if (!_ready && await ConsentInformation.instance.canRequestAds()) await init();
  }

  String get rewardedUnitId => _isIOS
      ? _testRewardedIOS
      : (_useRealAndroidUnits ? _rewardedAndroid : _testRewardedAndroid);

  String get interstitialUnitId => _isIOS
      ? _testInterstitialIOS
      : (_useRealAndroidUnits ? _interstitialAndroid : _testInterstitialAndroid);

  String get appOpenUnitId =>
      _isIOS ? _testAppOpenIOS : (_useRealAndroidUnits ? _appOpenAndroid : _testAppOpenAndroid);

  String? get nativeUnitId =>
      _isIOS ? _testNativeIOS : (_useRealAndroidUnits ? _nativeAndroid : _testNativeAndroid);

  String get bannerUnitId =>
      _isIOS ? _testBannerIOS : (_useRealAndroidUnits ? _bannerAndroid : _testBannerAndroid);

  /// Whether a rewarded ad is loaded and can be shown right now.
  bool get isRewardedReady => _rewardedAd != null;

  void _onLoaded(String format) => _loadFailures.remove(format);

  void _retryLater(String format, Object error, VoidCallback load) {
    final failures = (_loadFailures[format] ?? 0) + 1;
    _loadFailures[format] = failures;
    final seconds = (30 * (1 << (failures - 1))).clamp(30, 300);
    debugPrint('$format ad failed to load ($error) - retrying in ${seconds}s');
    Timer(Duration(seconds: seconds), load);
  }

  void loadRewardedAd() {
    if (!_ready || _rewardedAd != null) return;
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _onLoaded('rewarded');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (e) => _retryLater('rewarded', e, loadRewardedAd),
      ),
    );
  }

  void loadInterstitialAd() {
    if (!_ready || _interstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _onLoaded('interstitial');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (e) => _retryLater('interstitial', e, loadInterstitialAd),
      ),
    );
  }

  void _onFullScreenClosed() {
    _isShowingFullScreenAd = false;
    _lastFullScreenClosedAt = DateTime.now();
  }

  bool get _fullScreenGapPassed {
    final last = _lastFullScreenClosedAt;
    return last == null || DateTime.now().difference(last) >= _fullScreenGap;
  }

  /// Shows a rewarded ad and waits until it's actually dismissed before
  /// resolving - `RewardedAd.show()`'s own Future completes as soon as the ad
  /// is presented, well before the user finishes watching, so awaiting it
  /// directly would report `earned` before the reward callback even had a
  /// chance to fire. [onUserEarnedReward] fires ONLY once the user completes
  /// the full ad - the app must grant the in-app benefit there, never on a
  /// plain "ad shown" callback.
  Future<bool> showRewardedAd({required VoidCallback onUserEarnedReward}) async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }
    final ad = _rewardedAd!;
    _rewardedAd = null;

    var earned = false;
    final dismissed = Completer<void>();
    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _onFullScreenClosed();
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _onFullScreenClosed();
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
        onUserEarnedReward();
      },
    );
    await dismissed.future;

    loadRewardedAd();
    return earned;
  }

  /// Returns whether an interstitial was actually shown.
  Future<bool> showInterstitialAd() async {
    final ad = _interstitialAd;
    if (ad == null || _isShowingFullScreenAd || !_fullScreenGapPassed) {
      loadInterstitialAd();
      return false;
    }
    _interstitialAd = null;
    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _onFullScreenClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _onFullScreenClosed();
      },
    );
    await ad.show();
    loadInterstitialAd();
    return true;
  }

  // --- App open ---------------------------------------------------------
  //
  // Shown when the player comes back to the app, never on the cold start
  // (they should see the app before any ad), at most once every
  // [_appOpenCooldown], and never on top of another full-screen ad.
  // AppStateEventNotifier tracks the whole app process, so Google Play's
  // purchase sheet or an ad's own activity don't count as "left the app".

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpenShownAt;
  bool _isShowingFullScreenAd = false;
  bool _hasBeenBackgrounded = false;
  StreamSubscription<AppState>? _appStateSub;

  static const _appOpenCooldown = Duration(hours: 4);
  // Google expires app open ads after 4 hours.
  static const _appOpenMaxAge = Duration(hours: 4);

  void _loadAppOpenAd() {
    if (!_ready || _appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _onLoaded('app_open');
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (e) => _retryLater('app_open', e, _loadAppOpenAd),
      ),
    );
  }

  void _listenForAppResume() {
    AppStateEventNotifier.startListening();
    _appStateSub ??= AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.background) {
        _hasBeenBackgrounded = true;
      } else if (state == AppState.foreground && _hasBeenBackgrounded) {
        _maybeShowAppOpenAd();
      }
    });
  }

  void _maybeShowAppOpenAd() {
    if (_isShowingFullScreenAd) return;
    final last = _lastAppOpenShownAt;
    if (last != null && DateTime.now().difference(last) < _appOpenCooldown) return;

    final ad = _appOpenAd;
    final loadedAt = _appOpenLoadedAt;
    if (ad == null || loadedAt == null) {
      _loadAppOpenAd();
      return;
    }
    _appOpenAd = null;
    if (DateTime.now().difference(loadedAt) > _appOpenMaxAge) {
      ad.dispose();
      _loadAppOpenAd();
      return;
    }

    _isShowingFullScreenAd = true;
    _lastAppOpenShownAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _onFullScreenClosed();
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _onFullScreenClosed();
        _loadAppOpenAd();
      },
    );
    ad.show();
  }

  /// Call after a claim completes - shows an interstitial on every
  /// [_interstitialEveryNClaims]th claim, if no other full-screen ad was
  /// shown in the last [_fullScreenGap]. Fire-and-forget: never let an ad
  /// failure block gameplay.
  Future<void> maybeShowInterstitialOnClaim() async {
    _claimsSinceInterstitial++;
    if (_claimsSinceInterstitial < _interstitialEveryNClaims) return;
    // Only reset once one actually showed, so a skipped turn tries again
    // on the next claim instead of waiting another full cycle.
    if (await showInterstitialAd()) _claimsSinceInterstitial = 0;
  }

  /// An anchored adaptive banner - full screen width, which earns a better
  /// CPM than the fixed 320x50 banner. Waits until ads are allowed.
  Future<BannerAd> createBanner({
    required int width,
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) async {
    await whenReady;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width) ?? AdSize.banner;
    final banner = BannerAd(
      adUnitId: bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, e) {
          debugPrint('Banner ad failed to load: $e');
          ad.dispose();
          onFailed();
        },
      ),
    );
    await banner.load();
    return banner;
  }
}
