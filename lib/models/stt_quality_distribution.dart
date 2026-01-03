class SttQualityDistribution {
  final int good;
  final int low;
  final int failed;

  SttQualityDistribution({
    required this.good,
    required this.low,
    required this.failed,
  });

  factory SttQualityDistribution.fromJson(Map<String, dynamic> json) {
    return SttQualityDistribution(
      good: (json['good'] as num?)?.toInt() ?? 0,
      low: (json['low'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
    );
  }
}
