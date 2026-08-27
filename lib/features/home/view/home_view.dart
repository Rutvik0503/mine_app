import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/formatters.dart';
import '../view_model/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) return const LoadingOverlay();
          return RefreshIndicator(
            onRefresh: controller.loadDashboard,
            color: AppColor.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Header(controller: controller),
                const SizedBox(height: 20),
                _MiningCard(controller: controller),
                const SizedBox(height: 16),
                _BalanceCard(controller: controller),
                const SizedBox(height: 16),
                _StreakCard(controller: controller),
                const SizedBox(height: 16),
                _MissionsCard(controller: controller),
                const SizedBox(height: 16),
                _FarmProgressCard(controller: controller),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HomeController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile.value;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColor.surfaceElevated,
          backgroundImage:
              profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
          child: profile?.avatarUrl == null
              ? const Icon(Icons.person, color: AppColor.textSecondary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(profile?.username ?? 'Miner', size: 16, weight: FontWeight.w700),
              AppText.caption('Level ${profile?.level ?? 1}'),
            ],
          ),
        ),
        IconButton(
          onPressed: controller.goToNotifications,
          icon: const Icon(Icons.notifications_outlined, color: AppColor.textPrimary),
        ),
        IconButton(
          onPressed: controller.goToSettings,
          icon: const Icon(Icons.settings_outlined, color: AppColor.textPrimary),
        ),
      ],
    );
  }
}

class _MiningCard extends StatelessWidget {
  final HomeController controller;
  const _MiningCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final session = controller.activeSession.value;
    final hashrate = controller.profile.value?.totalHashrate ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColor.miningGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Mining Power', color: Colors.white70, size: 13),
          const SizedBox(height: 4),
          AppText(Formatters.hashrate(hashrate), color: Colors.white, size: 26, weight: FontWeight.w800),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                session != null ? Icons.bolt_rounded : Icons.bolt_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              AppText(
                session != null ? 'ACTIVE' : 'IDLE',
                color: Colors.white,
                weight: FontWeight.w600,
                size: 13,
              ),
              const Spacer(),
              if (session != null)
                AppText(Formatters.duration(controller.remaining.value), color: Colors.white, weight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.goToMining,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColor.primaryDark,
              ),
              child: const Text('VIEW MINING'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final HomeController controller;
  const _BalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.caption('Available Reward'),
                const SizedBox(height: 4),
                AppText(
                  Formatters.points(controller.availableBalance.value),
                  size: 20,
                  weight: FontWeight.w700,
                  color: AppColor.secondary,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColor.border),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.caption('Pending Reward'),
                const SizedBox(height: 4),
                AppText(
                  Formatters.points(controller.pendingBalance.value),
                  size: 20,
                  weight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final HomeController controller;
  const _StreakCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final streak = controller.streak.value;
    final current = streak?.currentStreak ?? 0;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
                const Icon(Icons.local_fire_department_rounded, color: AppColor.warning),
                const SizedBox(width: 6),
                AppText('$current Day Streak', weight: FontWeight.w700),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final filled = i < (current % 7 == 0 && current > 0 ? 7 : current % 7);
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
            const AppText("Today's Missions", weight: FontWeight.w700),
            const SizedBox(height: 12),
            if (missions.isEmpty) const AppText.caption('No missions yet today.'),
            ...missions.take(3).map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          m.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 18,
                          color: m.isCompleted ? AppColor.success : AppColor.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: AppText(m.mission?.title ?? 'Mission', size: 13)),
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

class _FarmProgressCard extends StatelessWidget {
  final HomeController controller;
  const _FarmProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final farm = controller.farm.value;
    return GestureDetector(
      onTap: controller.goToFarm,
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
            AppText('Farm Level ${farm?.level ?? 1}', weight: FontWeight.w700),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.farmProgress,
                minHeight: 8,
                backgroundColor: AppColor.border,
                valueColor: const AlwaysStoppedAnimation(AppColor.secondary),
              ),
            ),
            const SizedBox(height: 8),
            AppText.caption(farm?.farmType?.name ?? 'Free Farm'),
          ],
        ),
      ),
    );
  }
}
