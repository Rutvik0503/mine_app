class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String conditionType;
  final double conditionValue;
  final String? reward;
  final bool isActive;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.conditionType,
    required this.conditionValue,
    this.reward,
    required this.isActive,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        conditionType: json['condition_type'] as String? ?? '',
        conditionValue: (json['condition_value'] as num?)?.toDouble() ?? 0,
        reward: json['reward']?.toString(),
        isActive: json['is_active'] as bool? ?? true,
      );
}
