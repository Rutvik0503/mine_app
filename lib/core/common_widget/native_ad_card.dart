import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constant/app_color.dart';
import '../services/ads_service.dart';

/// A native ad styled like the app's own list cards (Google's "small"
/// template, which carries its own "Ad" badge). Takes no space until an ad
/// has actually loaded, and none at all if it fails - never a blank gap.
class NativeAdCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  const NativeAdCard({super.key, this.padding = const EdgeInsets.only(bottom: 10)});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  static const double _height = 92;

  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unitId = AdsService.instance.nativeUnitId;
    if (unitId == null) return;
    await AdsService.instance.whenReady;
    if (!mounted) return;

    final ad = NativeAd(
      adUnitId: unitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppColor.surface,
        cornerRadius: 14,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.background,
          backgroundColor: AppColor.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.textPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(textColor: AppColor.textSecondary, size: 12),
        tertiaryTextStyle: NativeTemplateTextStyle(textColor: AppColor.textSecondary, size: 12),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.border),
        ),
        clipBehavior: Clip.antiAlias,
        // The small template's own height. Its white outer frame is made
        // transparent in res/drawable/gnt_outline_shape.xml.
        child: SizedBox(height: _height, child: AdWidget(ad: ad)),
      ),
    );
  }
}
