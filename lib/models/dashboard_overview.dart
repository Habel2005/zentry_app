class DashboardOverview {
  final DateTime day;
  final int totalCalls;
  final int ongoingCalls;
  final int droppedCalls;
  final int aiCalls;
  final int humanCalls;
  final int sttGood;
  final int sttLow;
  final int sttFailed;

  DashboardOverview({
    required this.day,
    required this.totalCalls,
    required this.ongoingCalls,
    required this.droppedCalls,
    required this.aiCalls,
    required this.humanCalls,
    required this.sttGood,
    required this.sttLow,
    required this.sttFailed,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      day: DateTime.parse(json['day']),
      totalCalls: json['total_calls'] ?? 0,
      ongoingCalls: json['ongoing_calls'] ?? 0,
      droppedCalls: json['dropped_calls'] ?? 0,
      aiCalls: json['ai_calls'] ?? 0,
      humanCalls: json['human_calls'] ?? 0,
      sttGood: json['stt_good'] ?? 0,
      sttLow: json['stt_low'] ?? 0,
      sttFailed: json['stt_failed'] ?? 0,
    );
  }
}
