import 'package:flutter/material.dart' hide Badge;
import 'badge.dart';
import 'call_detail_screen.dart';
import 'models/call_list_item.dart';
import 'queries.dart';
import 'theme.dart';

class CallListScreen extends StatefulWidget {
  const CallListScreen({super.key});

  @override
  State<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends State<CallListScreen> {
  Future<List<CallListItem>>? _callListFuture;

  @override
  void initState() {
    super.initState();
    _callListFuture = Queries.getCallList();
  }

  void _refreshCallList() {
    setState(() {
      _callListFuture = Queries.getCallList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCallList,
          ),
        ],
      ),
      body: FutureBuilder<List<CallListItem>>(
        future: _callListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No calls found'));
          }

          final calls = snapshot.data!;

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              return ListTile(
                title: Text('Call ID: ${call.callId}'),
                subtitle: Text(
                    '${call.callStartTime} - ${call.duration ?? 'Ongoing'} - ${call.language}'),
                trailing: Wrap(
                  spacing: 8.0,
                  children: [
                    if (call.isRepeatCaller)
                      const Chip(label: Text('Repeat')),
                    Badge(
                      text: call.callStatus,
                      color: call.callStatus == 'completed'
                          ? Colors.green
                          : AppTheme.red,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallDetailScreen(callId: call.callId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
