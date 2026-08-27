class LeaderboardEntryModel {
  final String userId;
  final String username;
  final String? avatarUrl;
  final double value;
  final int rank;

  LeaderboardEntryModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.value,
    required this.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json, int rank) =>
      LeaderboardEntryModel(
        userId: json['id'] as String,
        username: json['username'] as String? ?? 'Miner',
        avatarUrl: json['avatar_url'] as String?,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        rank: rank,
      );
}

enum LeaderboardCategory { hashrate, level, streak }
