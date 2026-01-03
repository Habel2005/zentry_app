import 'dart:convert';

class CallDetail {
  final String callId;
  final DateTime startTime;
  final DateTime? endTime;
  final String callStatus;
  final String language;
  final String sttQuality;
  final List<TranscriptItem> transcript;
  final List<AiProcessingStep> aiProcessingTimeline;

  CallDetail({
    required this.callId,
    required this.startTime,
    this.endTime,
    required this.callStatus,
    required this.language,
    required this.sttQuality,
    required this.transcript,
    required this.aiProcessingTimeline,
  });

  factory CallDetail.fromJson(Map<String, dynamic> json) {
    return CallDetail(
      callId: json['call_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      callStatus: json['call_status'],
      language: json['language'],
      sttQuality: json['stt_quality'],
      transcript: (json['transcript'] as List)
          .map((item) => TranscriptItem.fromJson(item))
          .toList(),
      aiProcessingTimeline: (json['ai_processing_timeline'] as List)
          .map((item) => AiProcessingStep.fromJson(item))
          .toList(),
    );
  }
}

class TranscriptItem {
  final String speaker;
  final String text;
  final double? sttConfidence;

  TranscriptItem({
    required this.speaker,
    required this.text,
    this.sttConfidence,
  });

  factory TranscriptItem.fromJson(Map<String, dynamic> json) {
    return TranscriptItem(
      speaker: json['speaker'],
      text: json['text'],
      sttConfidence: json['stt_confidence']?.toDouble(),
    );
  }
}

class AiProcessingStep {
  final String stepName;
  final String status;
  final int latency;
  final bool? guardrailModifiedOutput;

  AiProcessingStep({
    required this.stepName,
    required this.status,
    required this.latency,
    this.guardrailModifiedOutput,
  });

  factory AiProcessingStep.fromJson(Map<String, dynamic> json) {
    return AiProcessingStep(
      stepName: json['step_name'],
      status: json['status'],
      latency: json['latency'],
      guardrailModifiedOutput: json['guardrail_modified_output'],
    );
  }
}
