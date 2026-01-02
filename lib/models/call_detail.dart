class CallDetail {
  final String callId;
  final DateTime callStartTime;
  final DateTime? callEndTime;
  final String callStatus;
  final String? languageDetected;
  final String? sttQuality;
  final List<CallMessage> messages;
  final List<AiProcessingStep> processingSteps;

  CallDetail({
    required this.callId,
    required this.callStartTime,
    this.callEndTime,
    required this.callStatus,
    this.languageDetected,
    this.sttQuality,
    required this.messages,
    required this.processingSteps,
  });

  factory CallDetail.fromJson(Map<String, dynamic> json) {
    return CallDetail(
      callId: json['call_id'],
      callStartTime: DateTime.parse(json['call_start_time']),
      callEndTime: json['call_end_time'] != null
          ? DateTime.parse(json['call_end_time'])
          : null,
      callStatus: json['call_status'],
      languageDetected: json['language_detected'],
      sttQuality: json['stt_quality'],
      messages: (json['messages'] as List)
          .map((item) => CallMessage.fromJson(item))
          .toList(),
      processingSteps: (json['processing_steps'] as List)
          .map((item) => AiProcessingStep.fromJson(item))
          .toList(),
    );
  }
}

class CallMessage {
  final String speaker;
  final String rawText;
  final String? normalizedText;
  final double? sttConfidence;
  final DateTime messageTime;

  CallMessage({
    required this.speaker,
    required this.rawText,
    this.normalizedText,
    this.sttConfidence,
    required this.messageTime,
  });

  factory CallMessage.fromJson(Map<String, dynamic> json) {
    return CallMessage(
      speaker: json['speaker'],
      rawText: json['raw_text'],
      normalizedText: json['normalized_text'],
      sttConfidence: json['stt_confidence'] != null
          ? (json['stt_confidence'] as num).toDouble()
          : null,
      messageTime: DateTime.parse(json['message_time']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallMessage &&
          runtimeType == other.runtimeType &&
          messageTime == other.messageTime &&
          speaker == other.speaker;

  @override
  int get hashCode => messageTime.hashCode ^ speaker.hashCode;
}

class AiProcessingStep {
  final String stepType;
  final String stepStatus;
  final int? latencyMs;

  AiProcessingStep({
    required this.stepType,
    required this.stepStatus,
    this.latencyMs,
  });

  factory AiProcessingStep.fromJson(Map<String, dynamic> json) {
    return AiProcessingStep(
      stepType: json['step_type'],
      stepStatus: json['step_status'],
      latencyMs: json['latency_ms'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiProcessingStep &&
          runtimeType == other.runtimeType &&
          stepType == other.stepType;

  @override
  int get hashCode => stepType.hashCode;
}
