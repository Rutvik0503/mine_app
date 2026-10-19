import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';

/// An anchored adaptive banner that only takes up space once it has
/// actually loaded - renders nothing before that or while a failed load
/// waits to retry, so it never leaves a blank gap (spec section 29:
/// "Banner ads only where they do not interfere with UX").
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  static const _retryDelay = Duration(seconds: 60);

  BannerAd? _banner;
  bool _loaded = false;
  int? _width;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width != _width) {
      _width = width;
      _load();
    }
  }

  Future<void> _load() async {
    _retryTimer?.cancel();
    final old = _banner;
    _banner = null;
    _loaded = false;
    await old?.dispose();

    final banner = await AdsService.instance.createBanner(
      width: _width!,
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: () {
        if (!mounted) return;
        setState(() {
          _banner = null;
          _loaded = false;
        });
        _retryTimer = Timer(_retryDelay, () {
          if (mounted) _load();
        });
      },
    );
    if (!mounted) {
      await banner.dispose();
      return;
    }
    _banner = banner;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      ),
    );
  }
}
