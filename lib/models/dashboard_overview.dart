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
  final int aiHandledCalls;

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
    required this.aiHandledCalls,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      day: DateTime.parse(json['day']),
      totalCalls: json['total_calls'],
      ongoingCalls: json['ongoing_calls'],
      droppedCalls: json['dropped_calls'],
      aiCalls: json['ai_calls'],
      humanCalls: json['human_calls'],
      sttGood: json['stt_good'],
      sttLow: json['stt_low'],
      sttFailed: json['stt_failed'],
      aiHandledCalls: json['ai_handled_calls'],
    );
  }
}
