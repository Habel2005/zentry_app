
import 'package:flutter/material.dart';
import '../models/admin_calls_overview.dart';
import '../supabase_service.dart';
import 'stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<AdminCallsOverview> _overviewFuture;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _overviewFuture = _supabaseService.getCallsOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<AdminCallsOverview>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading data: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final overview = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Metrics',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    StatCard(
                      title: 'Total Calls',
                      value: overview.totalCalls.toString(),
                      icon: Icons.call,
                      iconColor: Colors.blue,
                    ),
                    StatCard(
                      title: 'Ongoing Calls',
                      value: overview.ongoingCalls.toString(),
                      icon: Icons.phone_in_talk,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      title: 'Dropped Calls',
                      value: overview.droppedCalls.toString(),
                      icon: Icons.call_missed_outgoing,
                      iconColor: Colors.red,
                    ),
                    StatCard(
                      title: 'AI Handled Ratio',
                      value: '${(overview.aiVsHumanRatio * 100).toStringAsFixed(1)}%',
                      icon: Icons.android,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                // ... The rest of your UI, including the chart placeholder ...
              ],
            ),
          );
        },
      ),
    );
  }
}
