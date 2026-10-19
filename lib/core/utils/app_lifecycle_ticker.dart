import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// A 1-second Timer.periodic that auto-pauses while the app is backgrounded
/// and resumes on return. A plain `Timer.periodic` keeps firing regardless
/// of app lifecycle - harmless alone, but with a countdown ticker running on
/// both Home and Mining at once, that's two Rx updates + widget rebuilds a
/// second happening behind whatever took over the screen (e.g. Razorpay's
/// native checkout), consistently starving it down to ~1-2fps
/// (BufferQueueProducer logs) and making its own buttons unresponsive to
/// taps. Mix this into a controller instead of managing the Timer directly.
mixin AppLifecycleTicker on GetxController {
  Timer? _ticker;
  AppLifecycleListener? _lifecycleListener;

  /// Override to do the periodic work.
  void onTick();

  Duration get tickInterval => const Duration(seconds: 1);

  void startTicker() {
    _lifecycleListener ??= AppLifecycleListener(onResume: _resumeTicker, onPause: _pauseTicker);
    _resumeTicker();
  }

  void _resumeTicker() {
    _ticker?.cancel();
    onTick();
    _ticker = Timer.periodic(tickInterval, (_) => onTick());
  }

  void _pauseTicker() => _ticker?.cancel();

  void stopTicker() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _ticker?.cancel();
    _ticker = null;
  }
}
