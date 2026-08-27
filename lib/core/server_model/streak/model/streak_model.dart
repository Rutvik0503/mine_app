class StreakModel {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;

  StreakModel({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
        lastCompletedDate: json['last_completed_date'] != null
            ? DateTime.tryParse(json['last_completed_date'])
            : null,
      );
}
