import 'package:flutter/material.dart';
import 'package:myapp/models/admin_calls_overview.dart';
import 'package:myapp/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AdminCallsOverview> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = SupabaseService().getCallsOverview();
  }

  void _refreshData() {
    setState(() {
      _overviewFuture = SupabaseService().getCallsOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<AdminCallsOverview>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refreshData, child: const Text('Try Again')),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available. Pull to refresh.'));
          }

          final overview = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 4
                    : constraints.maxWidth > 800
                        ? 2
                        : 1;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Overview",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.5, // Adjusted for better proportions
                        children: [
                          KpiCard(
                            title: 'Total Calls',
                            value: overview.totalCalls.toString(),
                            icon: Icons.call,
                            color: Colors.blue,
                          ),
                          KpiCard(
                            title: 'Ongoing Calls',
                            value: overview.ongoingCalls.toString(),
                            icon: Icons.phone_in_talk,
                            color: Colors.orange,
                          ),
                          KpiCard(
                            title: 'Dropped Calls',
                            value: overview.droppedCalls.toString(),
                            icon: Icons.call_missed_outgoing,
                            color: Colors.red,
                          ),
                          KpiCard(
                            title: 'AI vs Human Ratio',
                            value: '${(overview.aiVsHumanRatio * 100).toStringAsFixed(1)}%',
                            icon: Icons.data_usage,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'STT Quality Distribution',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      // Add STT quality distribution visualization here
                    ],
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

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const KpiCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
