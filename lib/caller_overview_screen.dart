import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/supabase_service.dart';

class CallerOverviewScreen extends StatefulWidget {
  const CallerOverviewScreen({super.key});

  @override
  State<CallerOverviewScreen> createState() => _CallerOverviewScreenState();
}

class _CallerOverviewScreenState extends State<CallerOverviewScreen> {
  late Future<List<dynamic>> _callersFuture;

  @override
  void initState() {
    super.initState();
    _loadCallers();
  }

  void _loadCallers() {
    setState(() {
      _callersFuture = SupabaseService().getCallerProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Removed the Scaffold AppBar entirely to fit your main layout
    return Scaffold(
      backgroundColor: Colors.transparent, // Lets parent background show through
      body: FutureBuilder<List<dynamic>>(
        future: _callersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No callers found.'));
          }

          final callers = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadCallers(),
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0, bottom: 100.0),
              itemCount: callers.length,
              itemBuilder: (context, index) {
                final caller = callers[index];
                return CallerCard(caller: caller);
              },
            ),
          );
        },
      ),
    );
  }
}

class CallerCard extends StatelessWidget {
  final dynamic caller;

  const CallerCard({super.key, required this.caller});

  void _showInterestsBottomSheet(BuildContext context, String callerId, String phoneHash) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallerInterestSheet(callerId: callerId, phoneHash: phoneHash),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    final phoneHash = caller['phone_hash']?.toString() ?? 'Unknown';
    final callerId = caller['id']?.toString() ?? '00000000';
    
    // Human Readable ID Generator (Takes first 6 chars of the UUID)
    final humanId = 'Student #${callerId.substring(0, 6).toUpperCase()}';
    
    final totalCalls = caller['total_calls'] ?? 0;
    
    String lastSeenStr = 'Unknown';
    if (caller['last_seen'] != null) {
      final date = DateTime.tryParse(caller['last_seen']);
      if (date != null) {
        lastSeenStr = DateFormat('MMM d, yyyy - h:mm a').format(date);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(50) : Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showInterestsBottomSheet(context, caller['id'], phoneHash),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDarkMode ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
                  child: Icon(Icons.person, color: Colors.teal.shade400),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        humanId,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Active: $lastSeenStr',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: totalCalls > 1 ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call, size: 14, color: totalCalls > 1 ? Colors.amber.shade700 : Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCalls',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: totalCalls > 1 ? Colors.amber.shade700 : Colors.blue.shade700
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- The Deep Dive Bottom Sheet ---
class CallerInterestSheet extends StatefulWidget {
  final String callerId;
  final String phoneHash;

  const CallerInterestSheet({super.key, required this.callerId, required this.phoneHash});

  @override
  State<CallerInterestSheet> createState() => _CallerInterestSheetState();
}

class _CallerInterestSheetState extends State<CallerInterestSheet> {
  late Future<List<dynamic>> _interestsFuture;
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _interestsFuture = SupabaseService().getCallerInterests(widget.callerId);
    _historyFuture = SupabaseService().client
        .from('call_sessions')
        .select('call_start_time, status, stt_quality')
        .eq('phone_hash', widget.phoneHash)
        .order('call_start_time', ascending: false)
        .limit(3);
  }

  // Helper to filter out literal "null" strings that AI sometimes generates
  String? _cleanDbString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return null;
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final humanId = 'Student #${widget.callerId.substring(0, 6).toUpperCase()}';

    // Wrapping in SafeArea and SingleChildScrollView fixes ALL pixel overflow errors
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tells sheet to fit content perfectly
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // --- HEADER & QUICK ACTIONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        humanId,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'System Hash: ${widget.phoneHash.substring(0, 10)}...', 
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  
                  // NEW: Useful Action Buttons!
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement url_launcher 'sms:'
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS Action Triggered')));
                        },
                        icon: const Icon(Icons.message_rounded, color: Colors.blue),
                        tooltip: 'Send SMS',
                        style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          // TODO: Implement url_launcher 'tel:'
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call Action Triggered')));
                        },
                        icon: const Icon(Icons.call, color: Colors.green),
                        tooltip: 'Call Back',
                        style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                      ),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Identified Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              // --- COURSE INTERESTS ---
              FutureBuilder<List<dynamic>>(
                future: _interestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Colors.teal)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('No courses extracted by AI yet.'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Crucial for scrolling inside Column
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final interest = snapshot.data![index];
                      
                      // Using the strict clean logic so we only show what the DB actually has
                      final programCode = _cleanDbString(interest['program_code']);
                      final quotaType = _cleanDbString(interest['quota_type']);
                      final strength = _cleanDbString(interest['strength']);

                      // If the DB actually recorded nothing useful, don't show a blank box
                      if (programCode == null && quotaType == null && strength == null) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    programCode ?? 'Undeclared Program',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  if (quotaType != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Quota: $quotaType', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ]
                                ],
                              ),
                            ),
                            if (strength != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStrengthColor(strength).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  strength.toUpperCase(),
                                  style: TextStyle(color: _getStrengthColor(strength), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text('Recent Call Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              // --- RECENT CALL ACTIVITY ---
              FutureBuilder<List<dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No history found.', style: TextStyle(color: Colors.grey));
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Crucial for scrolling inside Column
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final call = snapshot.data![index];
                      final status = call['status'] ?? 'Unknown';
                      
                      String callDate = 'Unknown Time';
                      if (call['call_start_time'] != null) {
                        final dt = DateTime.tryParse(call['call_start_time']);
                        if (dt != null) callDate = DateFormat('MMM d, h:mm a').format(dt);
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: status == 'completed' ? Colors.teal.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          child: Icon(
                            status == 'completed' ? Icons.check : Icons.call_end,
                            color: status == 'completed' ? Colors.teal : Colors.red,
                            size: 16,
                          ),
                        ),
                        title: Text(callDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text('STT Quality: ${call['stt_quality'] ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'completed' ? Colors.teal : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20), // Bottom padding buffer
            ],
          ),
        ),
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'high':
        return Colors.green.shade400;
      case 'medium':
        return Colors.amber.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}