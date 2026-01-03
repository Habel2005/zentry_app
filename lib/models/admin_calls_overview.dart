
class AdminCallsOverview {
  final int totalCalls;
  final int ongoingCalls;
  final int droppedCalls;
  final double aiVsHumanRatio;

  AdminCallsOverview({
    required this.totalCalls,
    required this.ongoingCalls,
    required this.droppedCalls,
    required this.aiVsHumanRatio,
  });

  factory AdminCallsOverview.fromJson(Map<String, dynamic> json) {
    return AdminCallsOverview(
      totalCalls: (json['total_calls'] as num?)?.toInt() ?? 0,
      ongoingCalls: (json['ongoing_calls'] as num?)?.toInt() ?? 0,
      droppedCalls: (json['dropped_calls'] as num?)?.toInt() ?? 0,
      aiVsHumanRatio: (json['ai_vs_human_ratio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
