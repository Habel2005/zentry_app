import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/call_detail.dart';
import 'package:myapp/supabase_service.dart';

class CallDetailScreen extends StatefulWidget {
  final String callId;
  const CallDetailScreen({super.key, required this.callId});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  late Future<CallDetail?> _callDetailFuture;

  @override
  void initState() {
    super.initState();
    _loadCallDetails();
  }

  void _loadCallDetails() {
    setState(() {
      _callDetailFuture = SupabaseService().getCallDetails(widget.callId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCallDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<CallDetail?>(
        future: _callDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Call not found.'));
          }

          final callDetail = snapshot.data!;

          // Using a LayoutBuilder for a responsive multi-pane layout
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // Wide layout: Transcript | Details
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTranscriptList(callDetail),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 1,
                      child: _buildDetailsColumn(callDetail),
                    ),
                  ],
                );
              } else {
                // Narrow layout: Combined scrollable view
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMetadataCard(callDetail),
                      const SizedBox(height: 24),
                      _buildAiProcessingTimeline(callDetail),
                      const SizedBox(height: 24),
                      Text('Transcript', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      ...callDetail.transcript.map((item) => _TranscriptBubble(item: item)),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTranscriptList(CallDetail callDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Conversation Transcript', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (callDetail.transcript.isEmpty)
              const Center(child: Text('No transcript available.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: callDetail.transcript.length,
                itemBuilder: (context, index) {
                  return _TranscriptBubble(item: callDetail.transcript[index]);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(CallDetail callDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataCard(callDetail),
          const SizedBox(height: 24),
          _buildAiProcessingTimeline(callDetail),
        ],
      ),
    );
  }
  
  Widget _buildMetadataCard(CallDetail callDetail) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call Metadata', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _MetadataRow(title: 'Call ID', value: callDetail.callId),
            _MetadataRow(title: 'Status', value: callDetail.callStatus),
            _MetadataRow(title: 'Language', value: callDetail.language),
            _MetadataRow(title: 'STT Quality', value: callDetail.sttQuality),
            _MetadataRow(title: 'Start Time', value: DateFormat.yMd().add_jms().format(callDetail.startTime)),
            _MetadataRow(title: 'End Time', value: callDetail.endTime != null ? DateFormat.yMd().add_jms().format(callDetail.endTime!) : 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildAiProcessingTimeline(CallDetail callDetail) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Processing Timeline', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            if (callDetail.aiProcessingTimeline.isEmpty)
              const Text('No processing steps recorded.')
            else
              ...callDetail.aiProcessingTimeline.map((step) => _AiProcessingStepTile(step: step)),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _MetadataRow extends StatelessWidget {
  final String title;
  final String value;

  const _MetadataRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          Flexible(child: Text(value, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.end,)),
        ],
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  final TranscriptItem item;
  const _TranscriptBubble({required this.item});

  @override
  Widget build(BuildContext context) {
    final isAi = item.speaker.toLowerCase() == 'ai response';
    final lowConfidence = (item.sttConfidence ?? 1.0) < 0.8;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Card(
              elevation: 1,
              color: isAi ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                side: lowConfidence ? BorderSide(color: Colors.orange.shade700, width: 1.5) : BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAi ? 'AI Response' : 'Caller (STT Output)',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: isAi ? theme.colorScheme.primary : null),
                    ),
                    const SizedBox(height: 4),
                    Text(item.text),
                    if (!isAi && item.sttConfidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Confidence: ${(item.sttConfidence! * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(color: lowConfidence ? Colors.orange.shade900 : Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiProcessingStepTile extends StatelessWidget {
  final AiProcessingStep step;
  const _AiProcessingStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    switch (step.status.toLowerCase()) {
      case 'success':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'fail':
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
      default:
        statusIcon = Icons.info;
        statusColor = Colors.grey;
    }

    return ListTile(
      dense: true,
      leading: Icon(statusIcon, color: statusColor),
      title: Text(step.stepName),
      trailing: Text('${step.latency}ms'),
      subtitle: step.guardrailModifiedOutput == true ? Text('Output modified by Guardrail', style: TextStyle(color: Colors.amber.shade800, fontStyle: FontStyle.italic)) : null,
    );
  }
}
