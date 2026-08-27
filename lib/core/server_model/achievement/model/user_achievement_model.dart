class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) => UserAchievementModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        achievementId: json['achievement_id'] as String,
        unlockedAt: DateTime.tryParse(json['unlocked_at'] ?? '') ?? DateTime.now(),
      );
}
