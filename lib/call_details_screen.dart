import 'package:flutter/material.dart';
import 'package:myapp/supabase_service.dart';

class CallDetailsScreen extends StatefulWidget {
  final String callId;

  const CallDetailsScreen({super.key, required this.callId});

  @override
  State<CallDetailsScreen> createState() => _CallDetailsScreenState();
}

class _CallDetailsScreenState extends State<CallDetailsScreen> {
  late Future<Map<String, dynamic>?> _callDetailsFuture;

  @override
  void initState() {
    super.initState();
    _callDetailsFuture = SupabaseService().getFullCallDetails(widget.callId);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Details'),
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey.shade100,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _callDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Call details not found.'));
          }

          final callData = snapshot.data!;
          final session = callData['session'];
          final messages = callData['messages'];
          final aiSteps = callData['ai_steps'];

          // Calculate Duration
          String durationStr = 'Ongoing';
          if (session['call_start_time'] != null && session['ended_at'] != null) {
            final start = DateTime.tryParse(session['call_start_time'].toString());
            final end = DateTime.tryParse(session['ended_at'].toString());
            if (start != null && end != null) {
              durationStr = '${end.difference(start).inSeconds}s';
            }
          }

          // Format clean Caller Name and grab the Session ID
          final String phoneHash = session['phone_hash']?.toString() ?? 'Unknown';
          final String cleanCallerName = phoneHash != 'Unknown' && phoneHash.length >= 6
              ? 'Caller #${phoneHash.substring(0, 6).toUpperCase()}'
              : phoneHash;
              
          final String languageDetected = session['language_detected']?.toString() ?? 'N/A';
          final String sttQuality = session['stt_quality']?.toString() ?? 'Unknown';

          return Column(
            children: [
              CallDetailHeader(
                callerName: cleanCallerName,
                callSessionId: widget.callId, // Passed the actual Conversation ID here
                callStatus: session['status'] ?? 'Unknown',
                duration: durationStr,
                consultationStatus: callData['consultation_status'] ?? 'None',
              ),
              Expanded(
                child: CallTranscriptView(messages: messages),
              ),
              AiSystemHealthPanel(
                language: languageDetected,
                sttQuality: sttQuality,
                latencies: aiSteps,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CallDetailHeader extends StatelessWidget {
  final String callerName;
  final String callSessionId;
  final String callStatus;
  final String duration;
  final String consultationStatus;

  const CallDetailHeader({
    super.key,
    required this.callerName,
    required this.callSessionId,
    required this.callStatus,
    required this.duration,
    required this.consultationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            callerName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Session ID: $callSessionId',
            style: TextStyle(
              fontSize: 12, 
              color: Colors.grey.shade500,
              fontFamily: 'monospace', // Makes the ID look like code/tech data
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                  label: callStatus,
                  color: callStatus == 'completed' ? Colors.teal : Colors.red),
              StatusBadge(label: duration, color: Colors.grey),
              StatusBadge(
                  label: consultationStatus,
                  color: consultationStatus == 'pending' ? Colors.amber : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CallTranscriptView extends StatelessWidget {
  final List<dynamic> messages;
  const CallTranscriptView({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    // --- SMART DEDUPLICATION ---
    // Cleans up existing database duplicates by ignoring consecutive identical messages
    final List<dynamic> cleanMessages = [];
    for (var i = 0; i < messages.length; i++) {
      final currentMsg = messages[i];
      if (i > 0) {
        final prevMsg = messages[i - 1];
        // If speaker and text are exactly the same as the last one, skip it!
        if (currentMsg['speaker'] == prevMsg['speaker'] && 
            currentMsg['raw_text'] == prevMsg['raw_text']) {
          continue; 
        }
      }
      cleanMessages.add(currentMsg);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cleanMessages.length,
      itemBuilder: (context, index) {
        final message = cleanMessages[index];
        final isUser = message['speaker'] == 'user';

        final String messageText = message['raw_text'] as String? ?? '...';
        final double? confidenceScore = (message['confidence'] as num?)?.toDouble();

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ChatBubble(
            message: messageText,
            isUser: isUser,
            confidence: confidenceScore,
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final double? confidence;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isUser
            ? (isDarkMode ? Colors.teal.shade900 : Colors.teal.shade100)
            : (isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          if (isUser && confidence != null) ...[
            const SizedBox(height: 4),
            Text(
              'STT Confidence: ${(confidence! * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: isDarkMode ? Colors.white.withAlpha(153) : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AiSystemHealthPanel extends StatefulWidget {
  final String language;
  final String sttQuality;
  final List<dynamic> latencies;
  
  const AiSystemHealthPanel({
    super.key,
    required this.language,
    required this.sttQuality,
    required this.latencies,
  });

  @override
  State<AiSystemHealthPanel> createState() => _AiSystemHealthPanelState();
}

class _AiSystemHealthPanelState extends State<AiSystemHealthPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;

    // Deduplicate latencies
    final uniqueLatencies = <String, dynamic>{};
    for (var step in widget.latencies) {
      final type = (step['step_type'] as String).toUpperCase();
      if (!uniqueLatencies.containsKey(type)) {
         uniqueLatencies[type] = step;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(50) : Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2), // Slight shadow upwards
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER (Always Visible) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI System Health',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  
                  // --- EXPANDED CONTENT ---
                  if (_isExpanded) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HealthMetric(label: 'Language', value: widget.language),
                        HealthMetric(
                          label: 'STT Quality',
                          value: widget.sttQuality,
                          valueColor: widget.sttQuality.toLowerCase() == 'good'
                              ? Colors.teal.shade300
                              : (widget.sttQuality.toLowerCase() == 'low' ? Colors.amber.shade300 : Colors.red.shade300),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Latency Breakdown', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    
                    // Vertical List instead of Wrap to prevent text overflow
                    ...uniqueLatencies.values.map<Widget>((step) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (step['step_type'] as String).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${step['latency_ms'] ?? 'N/A'} ms',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const HealthMetric({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class LatencyMetric extends StatelessWidget {
  final String label;
  final String value;

  const LatencyMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
