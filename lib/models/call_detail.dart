import 'package:flutter/foundation.dart';

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

  factory CallDetail.fromJson(List<dynamic> jsonList) {
    if (jsonList.isEmpty) {
      throw Exception("Cannot create CallDetail from empty list");
    }

    // Aggregate data from the list of rows from the view
    final firstRow = jsonList.first;
    final callId = firstRow['call_id'];
    final callStartTime = DateTime.parse(firstRow['call_start_time']);
    final callEndTime = firstRow['call_end_time'] != null
        ? DateTime.parse(firstRow['call_end_time'])
        : null;
    final callStatus = firstRow['call_status'];
    final languageDetected = firstRow['language_detected'];
    final sttQuality = firstRow['stt_quality'];

    final messages = <CallMessage>[];
    final processingSteps = <AiProcessingStep>[];
    final messageIds = <String>{}; // To avoid duplicate messages
    final stepIds = <String>{}; // To avoid duplicate steps

    for (var row in jsonList) {
      if (row['message_time'] != null && !messageIds.contains(row['message_time'])) {
        messages.add(CallMessage.fromJson(row));
        messageIds.add(row['message_time']);
      }
      if (row['step_type'] != null) {
        // Assuming step_type and message_time can be used to uniquely identify a step
        final stepId = '${row['step_type']}_${row['message_time']}';
         if (!stepIds.contains(stepId)) {
            processingSteps.add(AiProcessingStep.fromJson(row));
            stepIds.add(stepId);
        }
      }
    }
    
    // Sort messages and steps by time
    messages.sort((a, b) => a.messageTime.compareTo(b.messageTime));

    return CallDetail(
      callId: callId,
      callStartTime: callStartTime,
      callEndTime: callEndTime,
      callStatus: callStatus,
      languageDetected: languageDetected,
      sttQuality: sttQuality,
      messages: messages,
      processingSteps: processingSteps,
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
}
