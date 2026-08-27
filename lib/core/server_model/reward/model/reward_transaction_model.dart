class RewardTransactionModel {
  final String id;
  final String userId;
  final String type; // mining | mission | streak | referral | achievement | boost | adjustment
  final double amount;
  final String? source;
  final String? referenceId;
  final String status;
  final DateTime createdAt;

  RewardTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.source,
    this.referenceId,
    required this.status,
    required this.createdAt,
  });

  factory RewardTransactionModel.fromJson(Map<String, dynamic> json) => RewardTransactionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String? ?? 'adjustment',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        source: json['source'] as String?,
        referenceId: json['reference_id'] as String?,
        status: json['status'] as String? ?? 'completed',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}
