class MissionModel {
  final String id;
  final String title;
  final String description;
  final String type; // start_mining | claim_mining | upgrade_machine | custom
  final int target;
  final int rewardXp;
  final double rewardPoints;
  final bool isActive;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardXp,
    required this.rewardPoints,
    required this.isActive,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        type: json['type'] as String? ?? 'custom',
        target: (json['target'] as num?)?.toInt() ?? 1,
        rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 0,
        rewardPoints: (json['reward_points'] as num?)?.toDouble() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}
