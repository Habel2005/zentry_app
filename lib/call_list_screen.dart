
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'supabase_service.dart';

// Model for a single call entry in the list
class Call {
  final String id;
  final String summary;
  final DateTime createdAt;

  Call({required this.id, required this.summary, required this.createdAt});

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      summary: json['summary'] as String? ?? 'No summary available',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  late Future<List<Call>> _callsFuture;

  @override
  void initState() {
    super.initState();
    _callsFuture = _fetchCalls();
  }

  Future<List<Call>> _fetchCalls() async {
    try {
      final response = await SupabaseService().client.from('calls').select('id, summary, created_at').order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Call.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Log the error and show a user-friendly message
      print('Error fetching calls: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load calls.'), backgroundColor: Colors.red),
      );
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _callsFuture = _fetchCalls();
          });
        },
        child: FutureBuilder<List<Call>>(
          future: _callsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No calls found. Pull down to refresh.'),
              );
            }

            final calls = snapshot.data!;

            return ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                return ListTile(
                  title: Text(
                    call.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('ID: ${call.id}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/calls/${call.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
