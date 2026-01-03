import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          children: const [
            StatCard(title: 'Total Calls', value: '1,234', icon: Icons.call),
            StatCard(title: 'Avg. Call Duration', value: '5:32', icon: Icons.timer),
            StatCard(title: 'Issues Resolved', value: '95%', icon: Icons.check_circle),
            StatCard(title: 'Voicemails', value: '12', icon: Icons.voicemail),
          ],
        ),
      ),
    );
  }
}
