class AiProcessingStep {
  final String stepName;
  final String status;
  final int latency; // in milliseconds
  final bool? guardrailModifiedOutput;

  AiProcessingStep({
    required this.stepName,
    required this.status,
    required this.latency,
    this.guardrailModifiedOutput,
  });

  factory AiProcessingStep.fromJson(Map<String, dynamic> json) {
    return AiProcessingStep(
      stepName: json['step_name'] as String,
      status: json['status'] as String,
      latency: (json['latency'] as num).toInt(),
      guardrailModifiedOutput: json['guardrail_modified_output'] as bool?,
    );
  }
}
