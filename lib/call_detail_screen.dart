
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'supabase_service.dart';
import 'models/call_detail.dart';
import 'transcript_tile.dart';

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
    _callDetailFuture = SupabaseService().getCallDetails(widget.callId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call Summary',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(25),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(callDetail.summary ?? 'No summary available.'),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Transcript',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (callDetail.transcript.isEmpty)
                        const Text('No transcript available.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: callDetail.transcript.length,
                          itemBuilder: (context, index) {
                            final item = callDetail.transcript[index];
                            return TranscriptTile(
                              speaker: item.speaker,
                              text: item.text,
                              timestamp: item.timestamp,
                              isPrimarySpeaker: item.speaker == 'user', // Example logic
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right sidebar
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('Call ID', callDetail.callId, context),
                        _buildDetailRow('Start Time', DateFormat.yMMMd().add_jms().format(callDetail.startTime), context),
                        _buildDetailRow('End Time', callDetail.endTime != null ? DateFormat.yMMMd().add_jms().format(callDetail.endTime!) : 'N/A', context),
                        _buildDetailRow('Status', callDetail.callStatus, context),
                        _buildDetailRow('Language', callDetail.language, context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
