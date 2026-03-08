import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/supabase_service.dart';
// Make sure this path matches your project structure to access the X-Ray screen
import 'package:myapp/call_details_screen.dart'; 

class AdmissionBaselineScreen extends StatefulWidget {
  const AdmissionBaselineScreen({super.key});

  @override
  State<AdmissionBaselineScreen> createState() => _AdmissionBaselineScreenState();
}

class _AdmissionBaselineScreenState extends State<AdmissionBaselineScreen> {
  late Future<List<dynamic>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = SupabaseService().getConsultationRequests();
    });
  }

  // Navigate to the dedicated screen and refresh list when we come back
  Future<void> _showRequestDetails(Map<String, dynamic> request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationDetailScreen(request: request),
      ),
    );
    _loadRequests(); // Refresh the list in case statuses were changed
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final requests = snapshot.data!;
          
          requests.sort((a, b) {
            if (a['status'] == 'pending' && b['status'] != 'pending') return -1;
            if (a['status'] != 'pending' && b['status'] == 'pending') return 1;
            return 0;
          });

          return RefreshIndicator(
            onRefresh: () async => _loadRequests(),
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0, bottom: 100.0),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final status = request['status'] ?? 'pending';
                final rawName = request['caller_name']?.toString().trim();
                final isNameMissing = rawName == null || rawName.isEmpty || rawName.toLowerCase() == 'unknown';
                final displayName = isNameMissing ? 'Name Unknown' : rawName;
                final course = request['course_interest'] ?? 'General Inquiry';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isNameMissing && status == 'pending' 
                        ? BorderSide(color: Colors.amber.withOpacity(0.5)) 
                        : BorderSide.none,
                  ),
                  elevation: 4,
                  shadowColor: isDarkMode ? Colors.black54 : Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showRequestDetails(request),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: status == 'resolved' ? Colors.teal.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                            child: Icon(
                              status == 'resolved' ? Icons.check : Icons.person, 
                              color: status == 'resolved' ? Colors.teal : Colors.blue
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(course, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                              ],
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'pending' ? Colors.amber.shade700 
                : status == 'pending' ? Colors.blue.shade500 
                : Colors.teal.shade500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text('No Consultation Requests', style: TextStyle(fontSize: 18, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- THE NEW DEDICATED SCREEN ---
class ConsultationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const ConsultationDetailScreen({super.key, required this.request});

  @override
  State<ConsultationDetailScreen> createState() => _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  late Future<List<dynamic>> _interestsFuture;
  late Future<List<dynamic>> _transcriptFuture;
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.request['status'] ?? 'pending';
    final callId = widget.request['call_id'];
    
    if (callId != null) {
      _interestsFuture = SupabaseService().getInterestsForCall(callId);
      _transcriptFuture = SupabaseService().getTranscriptSnippet(callId);
    } else {
      _interestsFuture = Future.value([]);
      _transcriptFuture = Future.value([]);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await SupabaseService().updateConsultationStatus(widget.request['id'], newStatus);
      setState(() {
        currentStatus = newStatus;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final rawName = widget.request['caller_name']?.toString().trim();
    final isNameMissing = rawName == null || rawName.isEmpty || rawName.toLowerCase() == 'unknown';
    final displayName = isNameMissing ? 'Name not extracted' : rawName;
    final phone = widget.request['caller_phone'] ?? 'Unknown Phone';
    final callId = widget.request['call_id'];

    String dateStr = 'Unknown Date';
    if (widget.request['created_at'] != null) {
      final date = DateTime.tryParse(widget.request['created_at']);
      if (date != null) dateStr = DateFormat('MMM d, yyyy - h:mm a').format(date);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Consultation Form'),
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        actions: [
          _buildStatusBadge(currentStatus),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CALLER DETAILS CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Caller Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(phone, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: isNameMissing ? Colors.amber : Colors.blue),
                      const SizedBox(width: 12),
                      Text(displayName, style: TextStyle(fontSize: 16, color: isNameMissing ? Colors.amber : textColor, fontStyle: isNameMissing ? FontStyle.italic : FontStyle.normal)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Requested: $dateStr', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- COURSE SIGNALS ---
            const Text(' Course Signals (From Call)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            FutureBuilder<List<dynamic>>(
              future: _interestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('  No specific courses detected.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
                
                return Column(
                  children: snapshot.data!.map((interest) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(interest['program_code'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        Text(interest['strength']?.toString().toUpperCase() ?? '', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- TRANSCRIPT SNIPPET ---
            const Text(' Final Conversation Snippet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            FutureBuilder<List<dynamic>>(
              future: _transcriptFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('  Transcript snippet unavailable.', style: TextStyle(color: Colors.grey));
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isDarkMode ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.map((msg) {
                      final isUser = msg['speaker'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: isUser ? 'Student: ' : 'Zentry: ', style: TextStyle(fontWeight: FontWeight.bold, color: isUser ? Colors.blue : Colors.teal)),
                              TextSpan(text: msg['raw_text'] ?? '...', style: TextStyle(color: textColor, height: 1.4)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // --- VIEW FULL CONVERSATION BUTTON ---
            if (callId != null) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CallDetailsScreen(callId: callId)),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Full Conversation', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
      
      // --- FIXED BOTTOM ACTION BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: _buildActionButtons(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (currentStatus == 'resolved') {
      return Row(
        children: [
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.teal),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Resolved & Handled', 
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _updateStatus('contacted'), // UNDO back to contacted
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          )
        ],
      );
    }

    return Row(
      children: [
        if (currentStatus == 'pending')
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('contacted'), // Move state forward
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), 
                side: const BorderSide(color: Colors.blue)
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Mark Contacted', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          
        if (currentStatus == 'contacted')
          Expanded(
            child: OutlinedButton.icon(
               onPressed: () => _updateStatus('pending'), // UNDO back to pending
               icon: const Icon(Icons.undo, size: 18),
               label: const Text('Undo', style: TextStyle(fontWeight: FontWeight.bold)),
               style: OutlinedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 foregroundColor: Colors.grey, 
                 side: const BorderSide(color: Colors.grey)
               ),
            ),
          ),
          
        const SizedBox(width: 12),
        
        Expanded(
          flex: 1, 
          child: ElevatedButton(
            onPressed: () => _updateStatus('resolved'), // Complete the flow
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Approve & Resolve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    // Fixed the duplicated 'pending' here so 'contacted' gets the blue badge!
    Color color = status == 'pending' ? Colors.amber.shade700 
                : status == 'contacted' ? Colors.blue.shade500 
                : Colors.teal.shade500;
                
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)
      ),
    );
  }

}