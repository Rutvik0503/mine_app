class ProfileModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final int level;
  final int xp;
  final double totalHashrate;
  final int streakDays;

  /// Unused "24h Auto Mining" passes from referrals.
  final int autoMiningPasses;
  final DateTime? lastActiveAt;
  final String referralCode;
  final String? referredBy;
  final String status;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.totalHashrate,
    required this.streakDays,
    this.autoMiningPasses = 0,
    this.lastActiveAt,
    required this.referralCode,
    this.referredBy,
    required this.status,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? 'Miner',
      avatarUrl: json['avatar_url'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      totalHashrate: (json['total_hashrate'] as num?)?.toDouble() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      autoMiningPasses: (json['auto_mining_passes'] as num?)?.toInt() ?? 0,
      lastActiveAt:
          json['last_active_at'] != null ? DateTime.tryParse(json['last_active_at']) : null,
      referralCode: json['referral_code'] as String? ?? '',
      referredBy: json['referred_by'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'avatar_url': avatarUrl,
      };
}
