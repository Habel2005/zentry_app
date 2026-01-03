import 'stt_quality_distribution.dart';

class AdminCallsOverview {
  final int totalCalls;
  final int ongoingCalls;
  final int droppedCalls;
  final double aiVsHumanRatio; // Corrected field name
  final SttQualityDistribution sttQualityDistribution;

  AdminCallsOverview({
    required this.totalCalls,
    required this.ongoingCalls,
    required this.droppedCalls,
    required this.aiVsHumanRatio,
    required this.sttQualityDistribution,
  });

  factory AdminCallsOverview.fromJson(Map<String, dynamic> json) {
    return AdminCallsOverview(
      totalCalls: (json['total_calls'] as num?)?.toInt() ?? 0,
      ongoingCalls: (json['ongoing_calls'] as num?)?.toInt() ?? 0,
      droppedCalls: (json['dropped_calls'] as num?)?.toInt() ?? 0,
      aiVsHumanRatio: (json['ai_vs_human_ratio'] as num?)?.toDouble() ?? 0.0,
      sttQualityDistribution: SttQualityDistribution.fromJson(
        (json['stt_quality_distribution'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
