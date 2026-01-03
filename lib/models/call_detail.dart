

class CallDetail {
  final String callId;
  final DateTime startTime;
  final DateTime? endTime;
  final String callStatus;
  final String language;
  final String? summary;
  final List<TranscriptItem> transcript;

  CallDetail({
    required this.callId,
    required this.startTime,
    this.endTime,
    required this.callStatus,
    required this.language,
    this.summary,
    required this.transcript,
  });

  factory CallDetail.fromJson(Map<String, dynamic> json) {
    return CallDetail(
      callId: json['call_id'] as String,
      startTime: DateTime.parse(json['call_start_time'] as String),
      endTime: json['call_end_time'] != null ? DateTime.parse(json['call_end_time'] as String) : null,
      callStatus: json['call_status'] as String,
      language: json['language'] as String,
      summary: json['summary'] as String?,
      transcript: (json['transcript'] as List<dynamic>? ?? [])
          .map((item) => TranscriptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TranscriptItem {
  final String speaker;
  final String text;
  final Duration timestamp;

  TranscriptItem({required this.speaker, required this.text, required this.timestamp});

  factory TranscriptItem.fromJson(Map<String, dynamic> json) {
    return TranscriptItem(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      timestamp: Duration(seconds: (json['timestamp'] as num).toInt()),
    );
  }
}
