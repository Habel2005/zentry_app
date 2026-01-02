import 'package:flutter/material.dart';
import 'models/dashboard_overview.dart';
import 'queries.dart';
import 'stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<DashboardOverview>? _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = Queries.getDashboardOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zentry Insights Dashboard'),
      ),
      body: FutureBuilder<DashboardOverview>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final overview = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _overviewFuture = Queries.getDashboardOverview();
              });
            },
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(title: 'Total Calls', value: overview.totalCalls.toString()),
                StatCard(title: 'Ongoing Calls', value: overview.ongoingCalls.toString()),
                StatCard(title: 'Dropped Calls', value: overview.droppedCalls.toString()),
                StatCard(
                    title: 'AI Handled Calls', value: overview.aiHandledCalls.toString()),
                StatCard(title: 'STT Good', value: overview.sttGood.toString()),
                StatCard(title: 'STT Low', value: overview.sttLow.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
