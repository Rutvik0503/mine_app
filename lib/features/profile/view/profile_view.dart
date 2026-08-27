import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/stat_card.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const AppText.subHeading('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: controller.goToSettings, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        final profile = controller.profile.value;
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColor.surfaceElevated,
                      backgroundImage:
                          profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                      child: profile?.avatarUrl == null
                          ? const Icon(Icons.person, size: 40, color: AppColor.textSecondary)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppText(profile?.username ?? 'Miner', size: 20, weight: FontWeight.w700),
                    AppText.caption(profile?.email ?? ''),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(label: 'Level', value: '${profile?.level ?? 1}', icon: Icons.trending_up_rounded),
                  StatCard(label: 'XP', value: '${profile?.xp ?? 0}', icon: Icons.star_rounded, accent: AppColor.warning),
                  StatCard(
                      label: 'Farm Level', value: '${controller.farm.value?.level ?? 1}', icon: Icons.agriculture_rounded),
                  StatCard(
                      label: 'Mining Power',
                      value: '${(profile?.totalHashrate ?? 0).toStringAsFixed(1)} TH/s',
                      icon: Icons.bolt_rounded,
                      accent: AppColor.secondary),
                  StatCard(label: 'Streak', value: '${profile?.streakDays ?? 0}d', icon: Icons.local_fire_department_rounded),
                  StatCard(label: 'Referrals', value: '${controller.referralCount.value}', icon: Icons.people_alt_rounded),
                ],
              ),
              const SizedBox(height: 24),
              _MenuTile(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements (${controller.achievementCount.value})',
                onTap: controller.goToAchievements,
              ),
              _MenuTile(icon: Icons.people_alt_rounded, label: 'Referral Program', onTap: controller.goToReferral),
              _MenuTile(icon: Icons.leaderboard_rounded, label: 'Leaderboard', onTap: controller.goToLeaderboard),
              _MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: controller.goToSettings),
              const SizedBox(height: 20),
              _MenuTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: AppColor.error,
                onTap: controller.logout,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColor.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: AppText(label, color: color),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColor.textDisabled),
        onTap: onTap,
      ),
    );
  }
}
