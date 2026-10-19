class MiningSessionModel {
  final String id;
  final String userId;
  final String farmId;
  final DateTime startedAt;
  final DateTime expectedEndAt;
  final DateTime? completedAt;
  final double hashrateSnapshot;
  final double rewardRateSnapshot;
  final double? calculatedReward;
  final String status; // active | completed | cancelled | expired
  final int adExtensionsUsed;
  final int adSpeedupsUsed;

  /// user_machines ids this session mines with; null on sessions started
  /// before miner selection existed (those used every active machine).
  final List<String>? machineIds;

  static const int maxAdExtensions = 2;

  MiningSessionModel({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.startedAt,
    required this.expectedEndAt,
    this.completedAt,
    required this.hashrateSnapshot,
    required this.rewardRateSnapshot,
    this.calculatedReward,
    required this.status,
    this.adExtensionsUsed = 0,
    this.adSpeedupsUsed = 0,
    this.machineIds,
  });

  bool get isActive => status == 'active';

  Duration get remaining {
    final diff = expectedEndAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isReadyToClaim => status == 'active' && remaining == Duration.zero;

  bool get canExtendWithAd => isReadyToClaim && adExtensionsUsed < maxAdExtensions;

  /// Still mining - speed-ups are capped per day (not per session) by
  /// grant-ad-reward; see MiningController.speedUpsLeft.
  bool get canSpeedUpWithAd => isActive && remaining > Duration.zero;

  factory MiningSessionModel.fromJson(Map<String, dynamic> json) => MiningSessionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        farmId: json['farm_id'] as String,
        startedAt: DateTime.parse(json['started_at']),
        expectedEndAt: DateTime.parse(json['expected_end_at']),
        completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
        hashrateSnapshot: (json['hashrate_snapshot'] as num?)?.toDouble() ?? 0,
        rewardRateSnapshot: (json['reward_rate_snapshot'] as num?)?.toDouble() ?? 0,
        calculatedReward: (json['calculated_reward'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'active',
        adExtensionsUsed: (json['ad_extensions_used'] as num?)?.toInt() ?? 0,
        adSpeedupsUsed: (json['ad_speedups_used'] as num?)?.toInt() ?? 0,
        machineIds: (json['machine_ids'] as List?)?.map((e) => e.toString()).toList(),
      );
}
