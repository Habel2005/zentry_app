import 'package:flutter/material.dart';
import 'package:zentry_insights/lib/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatCard(
              title: 'Total Calls (Today)',
              value: '1,234',
              description: '+', // Placeholder for description
              icon: Icons.call,
            ),
            SizedBox(height: 16),
            StatCard(
              title: 'Ongoing Calls',
              value: '56',
              description: '', // Placeholder for description
              icon: Icons.call,
            ),
            SizedBox(height: 16),
            StatCard(
              title: 'Dropped Calls (Today)',
              value: '78',
              description: '-', // Placeholder for description
              icon: Icons.call_missed,
            ),
          ],
        ),
      ),
    );
  }
}
