
import 'package:flutter/material.dart';
import 'stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: const [
                StatCard(
                  title: 'Total Calls',
                  value: '1,234',
                  icon: Icons.call,
                  iconColor: Colors.blue,
                ),
                StatCard(
                  title: 'Avg. Call Duration',
                  value: '5:32',
                  icon: Icons.timer,
                  iconColor: Colors.green,
                ),
                StatCard(
                  title: 'Issues Resolved',
                  value: '95%',
                  icon: Icons.check_circle,
                  iconColor: Colors.purple,
                ),
                StatCard(
                  title: 'Voicemails',
                  value: '12',
                  icon: Icons.voicemail,
                  iconColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              'Call Volume Over Time',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 50,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chart will be displayed here',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
