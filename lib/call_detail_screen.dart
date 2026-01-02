import 'package:flutter/material.dart' hide Badge;
import 'badge.dart';
import 'models/call_detail.dart';
import 'queries.dart';
import 'theme.dart';

class CallDetailScreen extends StatefulWidget {
  final String callId;
  const CallDetailScreen({super.key, required this.callId});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  Future<CallDetail>? _callDetailFuture;

  @override
  void initState() {
    super.initState();
    _callDetailFuture = Queries.getCallDetails(widget.callId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Details'),
      ),
      body: FutureBuilder<CallDetail>(
        future: _callDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Call not found'));
          }

          final call = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMetadataSection(call),
              const SizedBox(height: 24),
              _buildTranscriptSection(call.messages),
              const SizedBox(height: 24),
              _buildAiTimelineSection(call.processingSteps),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetadataSection(CallDetail call) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call Metadata', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Chip(label: Text('ID: ${call.callId}')),
                Chip(label: Text('Start: ${call.callStartTime}')),
                if (call.callEndTime != null)
                  Chip(label: Text('End: ${call.callEndTime}')),
                Badge(
                    text: call.callStatus,
                    color: call.callStatus == 'completed'
                        ? Colors.green
                        : AppTheme.red),
                if (call.languageDetected != null)
                  Chip(label: Text('Lang: ${call.languageDetected}')),
                if (call.sttQuality != null)
                  Chip(label: Text('STT: ${call.sttQuality}')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptSection(List<CallMessage> messages) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transcript', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.speaker == 'user';
                final alignment = isUser ? Alignment.centerLeft : Alignment.centerRight;
                final color = isUser ? Colors.grey[200] : AppTheme.slateBlue.withAlpha(51);
                final confidenceColor = (message.sttConfidence ?? 1.0) < 0.8
                    ? AppTheme.red
                    : Colors.black;

                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'Caller' : 'AI',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.rawText,
                          style: TextStyle(color: confidenceColor),
                        ),
                        if (isUser && message.sttConfidence != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Confidence: ${(message.sttConfidence! * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTimelineSection(List<AiProcessingStep> steps) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Processing Timeline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return ListTile(
                  leading: const Icon(Icons.arrow_right_alt),
                  title: Text(step.stepType),
                  subtitle: Text('Status: ${step.stepStatus}'),
                  trailing: step.latencyMs != null
                      ? Text('${step.latencyMs}ms')
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
