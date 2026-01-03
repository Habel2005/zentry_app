import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'queries.dart';
import 'models/call_list_item.dart';

class CallListScreen extends StatefulWidget {
  const CallListScreen({super.key});

  @override
  State<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends State<CallListScreen> {
  late Future<List<CallListItem>> _callListFuture;

  @override
  void initState() {
    super.initState();
    _callListFuture = Queries.getCallList();
  }

  Future<void> _refreshCallList() async {
    setState(() {
      _callListFuture = Queries.getCallList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: FutureBuilder<List<CallListItem>>(
        future: _callListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No calls found.'));
          }

          final callList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshCallList,
            child: ListView.builder(
              itemCount: callList.length,
              itemBuilder: (context, index) {
                final call = callList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text('Call ID: ${call.callId}'),
                    subtitle: Text(
                      'Started: ${DateFormat.yMd().add_Hms().format(call.callStartTime)}\n'
                      'Status: ${call.callStatus} - ${call.sttQuality ?? 'N/A'}'
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    isThreeLine: true,
                    onTap: () => context.go('/calls/${call.callId}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
