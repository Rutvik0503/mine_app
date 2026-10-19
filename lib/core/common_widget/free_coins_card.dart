import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';
import '../server_model/reward/repository/reward_repository.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import 'app_snackbar.dart';
import 'app_text.dart';

/// "Free coins" - an opt-in rewarded ad worth a few coins, capped per day
/// by grant-ad-reward. Hides itself once today's limit is used up, so it
/// never sits there as a dead button.
class FreeCoinsCard extends StatefulWidget {
  /// Called after coins were granted, so the screen can refresh its balance.
  final VoidCallback? onClaimed;

  /// Space around the card - only applied while it's visible.
  final EdgeInsetsGeometry padding;
  const FreeCoinsCard({super.key, this.onClaimed, this.padding = EdgeInsets.zero});

  @override
  State<FreeCoinsCard> createState() => _FreeCoinsCardState();
}

class _FreeCoinsCardState extends State<FreeCoinsCard> with SingleTickerProviderStateMixin {
  static const _perDay = 5; // matches FREE_COINS_PER_DAY in grant-ad-reward
  static const _coins = 3; // matches FREE_COINS_AMOUNT in grant-ad-reward

  final RewardRepository _rewardRepository = RewardRepository();
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  int? _left;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final left = await _rewardRepository.freeCoinsLeft();
      if (mounted) setState(() => _left = left);
    } catch (_) {
      // Card just stays hidden if the status can't be loaded.
    }
  }

  Future<void> _watch() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final earned = await AdsService.instance.showRewardedAd(onUserEarnedReward: () {});
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        return;
      }
      await AnalyticsService.logRewardedAdComplete('free_coins');
      final result = await _rewardRepository.claimFreeCoins();
      final coins = (result['coins'] as num?)?.toInt() ?? 0;
      if (mounted) setState(() => _left = (result['free_coins_left'] as num?)?.toInt() ?? 0);
      AppSnackbar.success('pointsAdded'.trParams({'value': '$coins'}));
      widget.onClaimed?.call();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = _left;
    if (left == null || left <= 0) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding,
      child: _card(left),
    );
  }

  Widget _card(int left) {
    const gold = AppColor.warning;
    final orange = AppColor.premiumGradient.last;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2A06), Color(0xFF1C1405)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.18), blurRadius: 18, spreadRadius: 1)],
      ),
      child: Stack(
        children: [
          // Soft glow behind the coin.
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [gold.withValues(alpha: 0.35), Colors.transparent]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: AppColor.premiumGradient),
                    boxShadow: [BoxShadow(color: orange.withValues(alpha: 0.5), blurRadius: 12)],
                  ),
                  child: const Center(child: Text('🪙', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AppText('Free coins'.tr, weight: FontWeight.w800, size: 16, color: gold),
                          ),
                          const SizedBox(width: 6),
                          const Text('🎁', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      AppText('Watch a short video'.tr, size: 12, color: Colors.white70),
                      const SizedBox(height: 8),
                      // One dot per daily reward - filled ones are still available.
                      Row(
                        children: [
                          for (var i = 0; i < _perDay; i++) ...[
                            Container(
                              width: 14,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i < left ? gold : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          const SizedBox(width: 2),
                          AppText('freeCoinsLeftShort'.trParams({'left': '$left'}), size: 11, color: Colors.white60),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05)
                      .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
                  child: GestureDetector(
                    onTap: _busy ? null : _watch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColor.premiumGradient),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: orange.withValues(alpha: 0.55), blurRadius: 10)],
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.black87),
                                    SizedBox(width: 4),
                                    Text(
                                      '+$_coins',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Text(
                                  'WATCH'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
