class ReferralModel {
  final String id;
  final String referrerId;
  final String referredUserId;
  final String referralCode;
  final String status; // pending | active | rejected
  final DateTime? activatedAt;
  final DateTime createdAt;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.referralCode,
    required this.status,
    this.activatedAt,
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) => ReferralModel(
        id: json['id'] as String,
        referrerId: json['referrer_id'] as String,
        referredUserId: json['referred_user_id'] as String,
        referralCode: json['referral_code'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        activatedAt: json['activated_at'] != null ? DateTime.parse(json['activated_at']) : null,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}
