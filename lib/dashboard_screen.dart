import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/models/dashboard_data.dart';
import 'package:myapp/supabase_service.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = SupabaseService().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.totalCalls == 0) {
            return const Center(child: Text('No call data available for today.'));
          } else {
            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _dashboardData = SupabaseService().getDashboardData();
                });
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSummaryCards(data),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildAiVsHumanChart(data),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: _buildSttQualityChart(data),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSummaryCards(DashboardData data) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              'Total Calls', data.totalCalls.toString(), Icons.call, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Ongoing', data.ongoingCalls.toString(),
              Icons.phone_in_talk, Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Dropped', data.droppedCalls.toString(),
              Icons.phone_missed, Colors.red),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAiVsHumanChart(DashboardData data) {
    final double aiPercentage =
        (data.aiCalls + data.humanCalls) == 0 ? 0 : (data.aiCalls / (data.aiCalls + data.humanCalls));

    return Container(
       padding: const EdgeInsets.all(20),
       height: 250, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('AI Handled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -pi / 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 50, // Inner circle radius
                      startDegreeOffset: 0,
                      sections: [
                        PieChartSectionData(
                          value: aiPercentage,
                          color: Colors.teal,
                          radius: 25, // Thickness of the progress bar
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 1 - aiPercentage,
                          color: Colors.grey.shade300,
                          radius: 25,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(aiPercentage * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                     Text(
                      '${data.aiCalls} Calls',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSttQualityChart(DashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('STT Quality',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: data.sttGood.toDouble(),
                          color: Colors.cyan,
                          radius: 25,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: data.sttLow.toDouble(),
                          color: Colors.amber,
                          radius: 25,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: data.sttFailed.toDouble(),
                          color: Colors.pinkAccent,
                          radius: 25,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIndicator('Good', Colors.cyan, data.sttGood),
                      _buildIndicator('Low', Colors.amber, data.sttLow),
                      _buildIndicator('Failed', Colors.pinkAccent, data.sttFailed),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String text, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12, 
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
