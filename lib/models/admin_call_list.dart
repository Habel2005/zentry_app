class AdminCallList {
  final String callId;
  final DateTime startTime;
  final int duration;
  final String status;
  final String language;
  final String sttQuality;
  final bool isRepeatCaller;

  AdminCallList({
    required this.callId,
    required this.startTime,
    required this.duration,
    required this.status,
    required this.language,
    required this.sttQuality,
    required this.isRepeatCaller,
  });

  factory AdminCallList.fromJson(Map<String, dynamic> json) {
    return AdminCallList(
      callId: json['call_id'] as String? ?? 'N/A',
      startTime: json['call_start_time'] != null ? DateTime.parse(json['call_start_time'] as String) : DateTime.now(),
      duration: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      status: json['call_status'] as String? ?? 'Unknown',
      language: json['language_detected'] as String? ?? 'N/A',
      sttQuality: json['stt_quality'] as String? ?? 'N/A',
      isRepeatCaller: json['is_repeat_caller'] as bool? ?? false,
    );
  }
}
