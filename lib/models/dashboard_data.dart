class DashboardData {
  final int totalCalls;
  final int ongoingCalls;
  final int droppedCalls;
  final int aiCalls;
  final int humanCalls;
  final int sttGood;
  final int sttLow;
  final int sttFailed;

  DashboardData({
    required this.totalCalls,
    required this.ongoingCalls,
    required this.droppedCalls,
    required this.aiCalls,
    required this.humanCalls,
    required this.sttGood,
    required this.sttLow,
    required this.sttFailed,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCalls: json['total_calls'] as int? ?? 0,
      ongoingCalls: json['ongoing_calls'] as int? ?? 0,
      droppedCalls: json['dropped_calls'] as int? ?? 0,
      aiCalls: json['ai_calls'] as int? ?? 0,
      humanCalls: json['human_calls'] as int? ?? 0,
      sttGood: json['stt_good'] as int? ?? 0,
      sttLow: json['stt_low'] as int? ?? 0,
      sttFailed: json['stt_failed'] as int? ?? 0,
    );
  }
}
