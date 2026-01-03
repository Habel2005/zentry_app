class CallListItem {
  final String callId;
  final DateTime callStartTime;
  final DateTime? callEndTime;
  final int? durationSeconds;
  final String callStatus;
  final String? languageDetected;
  final String? sttQuality;
  final bool isRepeatCaller;

  CallListItem({
    required this.callId,
    required this.callStartTime,
    this.callEndTime,
    this.durationSeconds,
    required this.callStatus,
    this.languageDetected,
    this.sttQuality,
    required this.isRepeatCaller,
  });

  factory CallListItem.fromJson(Map<String, dynamic> json) {
    return CallListItem(
      callId: json['call_id'],
      callStartTime: DateTime.parse(json['call_start_time']),
      callEndTime: json['call_end_time'] != null
          ? DateTime.parse(json['call_end_time'])
          : null,
      durationSeconds: json['duration_seconds'],
      callStatus: json['call_status'],
      languageDetected: json['language_detected'],
      sttQuality: json['stt_quality'],
      isRepeatCaller: json['is_repeat_caller'] ?? false,
    );
  }
}
