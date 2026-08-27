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
  });

  bool get isActive => status == 'active';

  Duration get remaining {
    final diff = expectedEndAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isReadyToClaim => status == 'active' && remaining == Duration.zero;

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
      );
}
