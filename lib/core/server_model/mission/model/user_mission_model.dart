import 'mission_model.dart';

class UserMissionModel {
  final String id;
  final String userId;
  final String missionId;
  final int progress;
  final int target;
  final String status; // in_progress | completed | claimed
  final DateTime date;
  final DateTime? completedAt;
  final MissionModel? mission;

  UserMissionModel({
    required this.id,
    required this.userId,
    required this.missionId,
    required this.progress,
    required this.target,
    required this.status,
    required this.date,
    this.completedAt,
    this.mission,
  });

  bool get isCompleted => status == 'completed' || status == 'claimed';
  bool get isClaimed => status == 'claimed';

  factory UserMissionModel.fromJson(Map<String, dynamic> json) => UserMissionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        missionId: json['mission_id'] as String,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        target: (json['target'] as num?)?.toInt() ?? 1,
        status: json['status'] as String? ?? 'in_progress',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
        mission: json['missions'] != null
            ? MissionModel.fromJson(Map<String, dynamic>.from(json['missions']))
            : null,
      );
}
