import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/model/farm_type_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/machine/model/machine_model.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/server_model/mining/repository/mining_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/economy_formulas.dart';

class FarmController extends GetxController {
  final FarmRepository _farmRepository = FarmRepository();
  final MachineRepository _machineRepository = MachineRepository();
  final RewardRepository _rewardRepository = RewardRepository();
  final MiningRepository _miningRepository = MiningRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final isUpgrading = false.obs;
  final farm = Rxn<FarmModel>();
  final farmTypes = <FarmTypeModel>[].obs;
  final myMachines = <UserMachineModel>[].obs;
  final availableBalance = 0.0.obs;
  final miningRate = 1.0.obs;
  final miningSession = Rxn<MiningSessionModel>();

  /// Store tab: 'air' | 'hydro' | 'premium'.
  static const storeCategories = ['air', 'hydro', 'premium'];
  final selectedCategory = 'air'.obs;
  final storeMachines = <String, List<MachineModel>>{}.obs;
  final isStoreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _farmRepository.myFarm(),
        _farmRepository.farmTypes(),
        _machineRepository.myMachines(),
        _rewardRepository.availableBalance(),
        _farmRepository.miningRate(),
        _miningRepository.activeSession(),
      ]);
      farm.value = results[0] as FarmModel?;
      farmTypes.value = results[1] as List<FarmTypeModel>;
      myMachines.value = results[2] as List<UserMachineModel>;
      unawaited(ReminderService.instance.planRentalExpiry(myMachines));
      availableBalance.value = results[3] as double;
      miningRate.value = results[4] as double;
      miningSession.value = results[5] as MiningSessionModel?;
      storeMachines.clear();
      unawaited(_loadStore(selectedCategory.value));
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  int? get nextUpgradeCost {
    final level = farm.value?.level;
    if (level == null) return null;
    return EconomyFormulas.farmUpgradeCost(level + 1);
  }

  Future<void> selectCategory(String category) async {
    selectedCategory.value = category;
    if (!storeMachines.containsKey(category)) await _loadStore(category);
  }

  Future<void> _loadStore(String category) async {
    isStoreLoading.value = true;
    try {
      storeMachines[category] = await _machineRepository.storeMachines(category);
    } catch (_) {
      // Leaves the tab empty; pull-to-refresh retries.
    } finally {
      isStoreLoading.value = false;
    }
  }

  List<MachineModel> get visibleStoreMachines => storeMachines[selectedCategory.value] ?? const [];

  /// Rented miners that haven't expired, and owned machines.
  List<UserMachineModel> get activeMachines => myMachines.where((m) => !m.isExpired).toList();

  /// The player's copy of store miner [machineId], if they have one -
  /// preferring a running one over an expired rental, then the latest expiry.
  /// Drives the Active / Expired badge on the store list.
  UserMachineModel? ownedCopyOf(String machineId) {
    final copies = myMachines.where((m) => m.machineId == machineId).toList();
    if (copies.isEmpty) return null;
    copies.sort((a, b) {
      if (a.isExpired != b.isExpired) return a.isExpired ? 1 : -1;
      if (a.expiresAt == null) return -1; // owned outright outlasts any rental
      if (b.expiresAt == null) return 1;
      return b.expiresAt!.compareTo(a.expiresAt!);
    });
    return copies.first;
  }

  /// Where [owned] stands relative to mining. start-mining snapshots the
  /// farm's hashrate when a session starts, so a miner added after that
  /// only counts from the next session.
  MinerStatus minerStatus(UserMachineModel? owned) {
    if (owned == null) return MinerStatus.notOwned;
    if (owned.isExpired) return MinerStatus.expired;
    final session = miningSession.value;
    if (session == null || !session.isActive) return MinerStatus.idle;
    if (owned.purchasedAt.isAfter(session.startedAt)) return MinerStatus.nextSession;
    final picked = session.machineIds;
    // Sessions from before miner selection used every active machine.
    if (picked != null && !picked.contains(owned.id)) return MinerStatus.notSelected;
    return MinerStatus.mining;
  }

  void openPlans(MachineModel machine) => Get.toNamed(AppRoutes.machinePlans, arguments: machine);

  /// Estimated points/hour at the farm's current total hashrate - shown so
  /// the player can see what an upgrade (higher multiplier) is worth before
  /// paying for it. The real reward is always computed server-side at claim.
  double get estimatedPointsPerHour {
    final totalHashrate = activeMachines.fold(0.0, (sum, m) => sum + m.currentHashrate);
    final multiplier = farm.value?.multiplier ?? 1.0;
    return totalHashrate * multiplier * miningRate.value;
  }

  /// Farm upgrades cost coins. Short on coins? The dialog offers the Store,
  /// where coin packs are sold through Google Play.
  Future<void> onUpgradeTap() async {
    final currentFarm = farm.value;
    final cost = nextUpgradeCost;
    if (currentFarm == null || cost == null || isUpgrading.value) return;

    final canAfford = availableBalance.value >= cost;

    final choice = await Get.dialog<String>(
      AlertDialog(
        title: Text('upgradeToLevel'.trParams({'level': '${currentFarm.level + 1}'})),
        content: Text(
          canAfford
              ? 'upgradeConfirmBody'.trParams({
                  'cost': '$cost',
                  'before': availableBalance.value.toStringAsFixed(0),
                  'after': (availableBalance.value - cost).toStringAsFixed(0),
                })
              : 'notEnoughPointsBody'.trParams({
                  'level': '${currentFarm.level + 1}',
                  'cost': '$cost',
                  'balance': availableBalance.value.toStringAsFixed(0),
                  'shortfall': (cost - availableBalance.value).toStringAsFixed(0),
                }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          if (canAfford)
            ElevatedButton(
              onPressed: () => Get.back(result: 'coins'),
              child: Text('payWithPoints'.trParams({'cost': '$cost'})),
            )
          else
            ElevatedButton(
              onPressed: () => Get.back(result: 'store'),
              child: Text('Get coins'.tr),
            ),
        ],
      ),
    );

    if (choice == 'coins') {
      await upgradeFarm();
    } else if (choice == 'store') {
      await Get.toNamed(AppRoutes.store);
      await load();
    }
  }

  Future<void> upgradeFarm() async {
    isUpgrading.value = true;
    try {
      await _farmRepository.upgradeFarm();
      AppSnackbar.success('Farm upgraded!'.tr);
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isUpgrading.value = false;
    }
  }

  void goToMachines() => Get.toNamed(AppRoutes.machineList);
}

enum MinerStatus { notOwned, mining, nextSession, notSelected, idle, expired }
