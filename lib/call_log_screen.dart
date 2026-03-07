import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/call_details_screen.dart';
import 'package:myapp/models/admin_call_list.dart';
import 'package:myapp/refresh_screen.dart';
import 'package:myapp/supabase_service.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  late Future<List<AdminCallList>> _callListFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _callListFuture = SupabaseService().getCallList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  void _navigateToDetails(AdminCallList call) {
    if (call.callId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallDetailsScreen(callId: call.callId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    return RiveRefreshIndicator(
        riveAnimationPath: 'assets/riv/load.riv',
        onRefresh: _refreshData,
        child: FutureBuilder<List<AdminCallList>>(
          future: _callListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No call logs found.'),
              );
            }

            final calls = snapshot.data!;

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: isDarkMode ? Colors.white.withAlpha(50) : Colors.grey.withAlpha(100),
                      width: 1,
                    ),
                  ),
                  child: InkWell( // Use InkWell for tap effects on the entire card
                    onTap: () => _navigateToDetails(call),
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMd().add_jms().format(call.startTime),
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                              ),
                              _buildStatusChip(call.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric('Duration', '${call.duration}s', isDarkMode),
                              _buildMetric('Language', call.language, isDarkMode),
                              _buildSttQualityIndicator(call.sttQuality, isDarkMode),
                              _buildMetric('Repeat', call.isRepeatCaller ? 'Yes' : 'No', isDarkMode, 
                                valueColor: call.isRepeatCaller ? Colors.teal : null),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  Widget _buildMetric(String label, String value, bool isDarkMode, {Color? valueColor}) {
     final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;
     final defaultColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? defaultColor)),
      ],
    );
  }


  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String label;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade300;
        label = 'Completed';
        break;
      case 'dropped':
        chipColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade300;
        label = 'Dropped';
        break;
      case 'ongoing':
        chipColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade300;
        label = 'Ongoing';
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey.shade300;
        label = status;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSttQualityIndicator(String quality, bool isDarkMode) {
    Color color;
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;

    switch (quality.toLowerCase()) {
      case 'good':
        color = Colors.cyan;
        break;
      case 'low':
        color = Colors.amber;
        break;
      case 'failed':
        color = Colors.pinkAccent;
        break;
      default:
        return Text(quality);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('STT Quality', style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(quality, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
