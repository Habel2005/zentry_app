import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/models/dashboard_data.dart';
import 'package:myapp/refresh_screen.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<DashboardData>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple,));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.totalCalls == 0) {
            return const Center(child: Text('No call data available for today.'));
          } else {
  final data = snapshot.data!;
  
  return RiveRefreshIndicator(
    riveAnimationPath: 'assets/riv/load.riv', 
    onRefresh: () async {
      final newData = await SupabaseService().getDashboardData();
      setState(() {
        _dashboardData = Future.value(newData);
      });
    },
    // Adding physics here is the key to making the pull gesture register
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // <--- ADD THIS
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(data, isDarkMode),
          const SizedBox(height: 20),
          _buildSttQualityChart(data, isDarkMode),
          const SizedBox(height: 20),
          _buildAiVsHumanChart(data, isDarkMode),
        ],
      ),
    ),
  );
}
        },
      );
  }

  Widget _buildSummaryCards(DashboardData data, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              'Total Calls', data.totalCalls.toString(), Icons.call, Colors.blue, isDarkMode),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Ongoing', data.ongoingCalls.toString(),
              Icons.phone_in_talk, Colors.orange, isDarkMode),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Dropped', data.droppedCalls.toString(),
              Icons.phone_missed, Colors.red, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87; // 0.9 alpha
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54; // 0.6 alpha

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13), // 0.3 alpha
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
            backgroundColor: color.withAlpha(25),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: subTextColor)),
        ],
      ),
    );
  }

  Widget _buildAiVsHumanChart(DashboardData data, bool isDarkMode) {
    final double aiPercentage =
        (data.aiCalls + data.humanCalls) == 0 ? 0 : (data.aiCalls / (data.aiCalls + data.humanCalls));
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87; // 0.9 alpha
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54; // 0.6 alpha

    return Container(
       padding: const EdgeInsets.all(20),
       height: 250, // Fixed height
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13), // 0.3 alpha
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Handled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
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
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
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
                      style: TextStyle(
                          fontSize: 14, color: subTextColor),
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

  Widget _buildSttQualityChart(DashboardData data, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87; // 0.9 alpha

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13), // 0.3 alpha
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STT Quality',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 45,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: data.sttGood.toDouble(),
                    color: Colors.cyan,
                    radius: 30,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: data.sttLow.toDouble(),
                    color: Colors.amber,
                    radius: 30,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: data.sttFailed.toDouble(),
                    color: Colors.pinkAccent,
                    radius: 30,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             _buildHorizontalIndicator('Good', Colors.cyan, data.sttGood, isDarkMode),
             _buildHorizontalIndicator('Low', Colors.amber, data.sttLow, isDarkMode),
             _buildHorizontalIndicator('Failed', Colors.pinkAccent, data.sttFailed, isDarkMode),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalIndicator(String text, Color color, int value, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87; // 0.9 alpha
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54; // 0.6 alpha

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 14, color: subTextColor)),
          ],
        )
      ],
    );
  }
}
