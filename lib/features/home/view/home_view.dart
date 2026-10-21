import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/free_coins_card.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/error_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/mining_visuals.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/type_icons.dart';
import '../view_model/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        centerTitle: true,
        title: AppText.subHeading('Dashboard'.tr),
        leading: IconButton(
          onPressed: controller.goToNotifications,
          icon: Obx(() {
            final unread = controller.unreadNotifications.value;
            return Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              backgroundColor: AppColor.error,
              child: Icon(
                unread > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                color: AppColor.textPrimary,
              ),
            );
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _SpinButton(onTap: controller.goToSpin),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.hasError.value) {
          return ErrorStateWidget(onRetry: controller.loadDashboard);
        }
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          color: AppColor.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              _TotalBalanceCard(controller: controller),
              const SizedBox(height: 14),
              _FarmCard(controller: controller),
              const SizedBox(height: 14),
              _BuildFarmCard(controller: controller),
              const SizedBox(height: 14),
              _SpinBanner(onTap: controller.goToSpin),
              const SizedBox(height: 14),
              FreeCoinsCard(
                padding: const EdgeInsets.only(bottom: 14),
                onClaimed: controller.loadDashboard,
              ),
              _StreakCard(controller: controller),
              const SizedBox(height: 14),
              _MissionsCard(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

/// Shared card shell: dark surface with a faint green edge glow.
class _GlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlowCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(color: AppColor.primary.withValues(alpha: 0.06), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }
}

class _SpinButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SpinButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Color(0xFFE5484D),
              Color(0xFFE2C541),
              Color(0xFF3FBFA8),
              Color(0xFF7C4DDB),
              Color(0xFF3B6FD9),
              Color(0xFFE5484D),
            ],
          ),
        ),
        child: const Icon(Icons.casino_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final HomeController controller;
  const _TotalBalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlowCard(
      child: Obx(() {
        final mining = controller.activeSession.value?.isActive ?? false;
        final total = controller.availableBalance.value + controller.liveSessionReward.value;
        return Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primary.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(color: AppColor.primary.withValues(alpha: 0.35), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.monetization_on_rounded, color: AppColor.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.caption('Total Balance'.tr),
                  const SizedBox(height: 2),
                  AppText(
                    'coinsAmountPrecise'.trParams({'coins': total.toStringAsFixed(mining ? 4 : 0)}),
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColor.primary,
                  ),
                  const SizedBox(height: 6),
                  _LiveBadge(live: mining),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool live;
  const _LiveBadge({required this.live});

  @override
  Widget build(BuildContext context) {
    final color = live ? AppColor.primary : AppColor.textDisabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 4),
          AppText((live ? 'LIVE' : 'IDLE').tr, size: 10, weight: FontWeight.w800, color: color),
        ],
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final HomeController controller;
  const _FarmCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final farm = controller.farm.value;
    final hashrate = controller.profile.value?.totalHashrate ?? 0;
    return _GlowCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                TypeIcons.farmType(farm?.farmType?.name ?? 'Free Farm'),
                color: AppColor.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(farm?.farmType?.name ?? 'Free Farm', weight: FontWeight.w700),
                    AppText.caption(
                      'machinesInFarm'.trParams({'count': '${controller.machineCount.value}'}),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: controller.goToRewards,
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text('History'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.textSecondary,
                  side: BorderSide(color: AppColor.border),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColor.border, height: 1),
          const SizedBox(height: 14),
          Obx(() {
            final session = controller.activeSession.value;
            final active = session?.isActive ?? false;
            return Row(
              children: [
                SpinningGear(size: 18, color: AppColor.primary, spinning: active, seconds: 3),
                const SizedBox(width: 6),
                AppText(Formatters.hashrate(hashrate), weight: FontWeight.w700, size: 13),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: controller.isClaiming.value ? null : controller.onMiningCardTap,
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: controller.isClaiming.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.primary),
                            )
                          : AppText(
                              active
                                  ? (session!.isReadyToClaim
                                      ? 'CLAIM REWARD'.tr
                                      : Formatters.duration(controller.remaining.value))
                                  : 'START MINING'.tr,
                              align: TextAlign.center,
                              weight: FontWeight.w800,
                              size: 13,
                              color: AppColor.primary,
                            ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BuildFarmCard extends StatelessWidget {
  final HomeController controller;
  const _BuildFarmCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Every account gets a free farm at sign-up, so this is normally the
    // "grow it" prompt; the "create" copy only shows if the farm is missing.
    final hasFarm = controller.farm.value != null;
    return _GlowCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColor.primary.withValues(alpha: 0.35), Colors.transparent],
              ),
            ),
            child: const Icon(Icons.view_in_ar_rounded, size: 72, color: AppColor.primary),
          ),
          const SizedBox(height: 14),
          AppText(
            (hasFarm ? 'Grow your virtual mining farm' : 'Build your own virtual mining farm').tr,
            weight: FontWeight.w800,
            size: 16,
            align: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.caption(
            'Set up your farm, choose machines, and watch your mining power grow into daily virtual rewards.'.tr,
            align: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.goToFarm,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text((hasFarm ? 'Add more miners' : 'Create Mining Farm').tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SpinBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF3B2A6E), Color(0xFF1B4D3A)]),
        ),
        child: Row(
          children: [
            _SpinButton(onTap: onTap),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Daily Spin'.tr, weight: FontWeight.w800, color: Colors.white),
                  const SizedBox(height: 2),
                  AppText(
                    'Spin the wheel and win free coins every day.'.tr,
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final HomeController controller;
  const _StreakCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Own Obx: the streak check-in finishes after the dashboard has built.
    return Obx(() {
      final current = controller.streak.value?.currentStreak ?? 0;
      return GestureDetector(
        onTap: controller.goToStreak,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColor.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColor.warning,
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    'streakDays'.trParams({'count': '$current'}),
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final filled =
                      i < (current % 7 == 0 && current > 0 ? 7 : current % 7);
                  return Column(
                    children: [
                      AppText.caption(days[i]),
                      const SizedBox(height: 6),
                      Icon(
                        filled ? Icons.check_circle : Icons.circle_outlined,
                        size: 18,
                        color: filled ? AppColor.success : AppColor.textDisabled,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MissionsCard extends StatelessWidget {
  final HomeController controller;
  const _MissionsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final missions = controller.todayMissions;
    return GestureDetector(
      onTap: controller.goToMissions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText("Today's Missions".tr, weight: FontWeight.w700),
            const SizedBox(height: 12),
            if (missions.isEmpty) AppText.caption('No missions yet today.'.tr),
            ...missions
                .take(3)
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          m.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: m.isCompleted
                              ? AppColor.success
                              : AppColor.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            m.mission?.title ?? 'Mission',
                            size: 13,
                          ),
                        ),
                        AppText.caption('+${m.mission?.rewardXp ?? 0} XP'),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
