import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'queries.dart';
import 'models/call_detail.dart';

class CallDetailScreen extends StatefulWidget {
  final String callId;

  const CallDetailScreen({super.key, required this.callId});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  late Future<CallDetail> _callDetailFuture;

  @override
  void initState() {
    super.initState();
    _callDetailFuture = Queries.getCallDetails(widget.callId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calls'),
        ),
      ),
      body: FutureBuilder<CallDetail>(
        future: _callDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Call details not found.'));
          }

          final callDetail = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(callDetail),
                const SizedBox(height: 24),
                _buildMessagesSection(callDetail.messages),
                const SizedBox(height: 24),
                _buildProcessingStepsSection(callDetail.processingSteps),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(CallDetail detail) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call Summary', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _buildSummaryRow('Call ID:', detail.callId),
            _buildSummaryRow('Start Time:', DateFormat.yMd().add_Hms().format(detail.callStartTime)),
            _buildSummaryRow('End Time:', detail.callEndTime != null ? DateFormat.yMd().add_Hms().format(detail.callEndTime!) : 'N/A'),
            _buildSummaryRow('Status:', detail.callStatus),
            _buildSummaryRow('Language:', detail.languageDetected ?? 'N/A'),
            _buildSummaryRow('STT Quality:', detail.sttQuality ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(List<CallMessage> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conversation Log', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...messages.map((msg) => _buildMessageBubble(msg)).toList(),
      ],
    );
  }

  Widget _buildMessageBubble(CallMessage message) {
    bool isAi = message.speaker.toLowerCase() == 'ai';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isAi ? Colors.grey.shade200 : Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                  bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(20.0),
                  bottomRight: isAi ? const Radius.circular(20.0) : const Radius.circular(0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${message.speaker} at ${DateFormat.Hms().format(message.messageTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(message.rawText),
                  if (message.sttConfidence != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Confidence: ${(message.sttConfidence! * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStepsSection(List<AiProcessingStep> steps) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Processing Steps', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.black12),
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text('Step', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Latency (ms)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            ...steps.map((step) => TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text(step.stepType)),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(step.stepStatus)),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(step.latencyMs?.toString() ?? 'N/A')),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }
}
