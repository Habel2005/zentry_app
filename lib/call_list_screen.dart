import 'package:flutter/material.dart';
import 'package:zentry_insights/lib/badge.dart';
import 'package:zentry_insights/lib/call_detail_screen.dart';
import 'package:zentry_insights/lib/theme.dart';

class CallListScreen extends StatefulWidget {
  const CallListScreen({super.key});

  @override
  State<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends State<CallListScreen> {
  final List<Map<String, dynamic>> _calls = [
    {
      'id': 'C12345',
      'timestamp': 'Today, 10:30 AM',
      'status': 'Completed',
      'language': 'English',
      'duration': '5m 30s'
    },
    {
      'id': 'C12346',
      'timestamp': 'Today, 10:35 AM',
      'status': 'Dropped',
      'language': 'Spanish',
      'duration': '2m 15s'
    },
    {
      'id': 'C12347',
      'timestamp': 'Today, 10:40 AM',
      'status': 'Completed',
      'language': 'English',
      'duration': '10m 5s'
    },
  ];

  Future<void> _refresh() async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // For now, just re-order the list
      _calls.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: _calls.length,
          itemBuilder: (context, index) {
            final call = _calls[index];
            return ListTile(
              title: Text('Call ID: ${call['id']}'),
              subtitle: Text(
                  '${call['timestamp']} - ${call['duration']} - ${call['language']}'),
              trailing: Badge(
                text: call['status'],
                color: call['status'] == 'Completed'
                    ? Colors.green
                    : AppTheme.red,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CallDetailScreen()));
              },
            );
          },
        ),
      ),
    );
  }
}
