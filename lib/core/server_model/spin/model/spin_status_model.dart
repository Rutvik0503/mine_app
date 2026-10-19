class SpinPrize {
  final int segment;
  final double reward;

  SpinPrize({required this.segment, required this.reward});

  factory SpinPrize.fromJson(Map<String, dynamic> json) => SpinPrize(
        segment: (json['segment'] as num).toInt(),
        reward: (json['reward'] as num).toDouble(),
      );
}

/// Server-side spin state from the spin-wheel Edge Function. [segment] and
/// [reward] are only set on the response to an actual spin.
class SpinStatusModel {
  final int freeSpinsLeft;
  final int adSpinsLeft;
  final List<SpinPrize> prizes;
  final int? segment;
  final double? reward;

  SpinStatusModel({
    required this.freeSpinsLeft,
    required this.adSpinsLeft,
    required this.prizes,
    this.segment,
    this.reward,
  });

  factory SpinStatusModel.fromJson(Map<String, dynamic> json) => SpinStatusModel(
        freeSpinsLeft: (json['free_spins_left'] as num?)?.toInt() ?? 0,
        adSpinsLeft: (json['ad_spins_left'] as num?)?.toInt() ?? 0,
        prizes: ((json['prizes'] as List?) ?? [])
            .map((e) => SpinPrize.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        segment: (json['segment'] as num?)?.toInt(),
        reward: (json['reward'] as num?)?.toDouble(),
      );
}
