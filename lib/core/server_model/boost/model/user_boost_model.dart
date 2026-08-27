import 'boost_model.dart';

class UserBoostModel {
  final String id;
  final String userId;
  final String boostId;
  final DateTime startedAt;
  final DateTime expiresAt;
  final String status;
  final BoostModel? boost;

  UserBoostModel({
    required this.id,
    required this.userId,
    required this.boostId,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
    this.boost,
  });

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  factory UserBoostModel.fromJson(Map<String, dynamic> json) => UserBoostModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        boostId: json['boost_id'] as String,
        startedAt: DateTime.tryParse(json['started_at'] ?? '') ?? DateTime.now(),
        expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
        status: json['status'] as String? ?? 'active',
        boost: json['boosts'] != null
            ? BoostModel.fromJson(Map<String, dynamic>.from(json['boosts']))
            : null,
      );
}
