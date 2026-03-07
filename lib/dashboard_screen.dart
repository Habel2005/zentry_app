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
  late Future<List<Map<String, dynamic>>> _topCallerIntentsFuture;
  late Future<Map<String, double>> _aiPipelineLatencyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dashboardData = SupabaseService().getDashboardData();
    _topCallerIntentsFuture = SupabaseService().getTopCallerIntents();
    _aiPipelineLatencyFuture = SupabaseService().getAiPipelineLatency();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder(
        future: Future.wait([_dashboardData, _topCallerIntentsFuture, _aiPipelineLatencyFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple,));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          } else {
              final dashboardData = snapshot.data![0] as DashboardData;
              final topCallerIntents = snapshot.data![1] as List<Map<String, dynamic>>;
              final aiPipelineLatency = snapshot.data![2] as Map<String, double>;

              if (dashboardData.totalCalls == 0) {
                return const Center(child: Text('No call data available for today.'));
              }
  
              return RiveRefreshIndicator(
                riveAnimationPath: 'assets/riv/load.riv', 
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(dashboardData, isDarkMode),
                      const SizedBox(height: 20),
                      _buildSttQualityChart(dashboardData, isDarkMode),
                      const SizedBox(height: 20),
                      _buildTopCallerIntentsCard(isDarkMode, topCallerIntents),
                      const SizedBox(height: 20),
                      _buildAiPipelineLatencyChart(isDarkMode, aiPipelineLatency),
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
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
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

  Widget _buildTopCallerIntentsCard(bool isDarkMode, List<Map<String, dynamic>> topIntents) {
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    final List<Color> colorPalette = [
      Colors.teal,
      Colors.cyan,
      Colors.amber,
      Colors.lightBlue.shade300,
      Colors.orangeAccent,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Caller Intents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          if (topIntents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('No intent data available for today.'),
              ),
            )
          else
            ...List.generate(topIntents.length, (index) {
              final intentData = topIntents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildIntentIndicator(
                  intentData['intent'],
                  (intentData['value'] as double),
                  colorPalette[index % colorPalette.length],
                  isDarkMode,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildIntentIndicator(String label, double value, Color color, bool isDarkMode) {
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;
    final double percentage = value / 100;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(fontSize: 14, color: subTextColor), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 16,
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text('${value.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSttQualityChart(DashboardData data, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
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

Widget _buildAiPipelineLatencyChart(bool isDarkMode, Map<String, double> latencies) {
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    // Safely extract latencies
    final double sttLat = latencies['STT'] ?? 0.0;
    final double llmLat = latencies['LLM'] ?? 0.0;
    final double ttsLat = latencies['TTS'] ?? 0.0;

    // Find the max to scale the heights. Default to 1000ms if all 0.
    double maxLat = [sttLat, llmLat, ttsLat].reduce(max);
    if (maxLat <= 0) maxLat = 1000.0;

    return Container(
      height: 240, // Fixed height for the vertical chart
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Pipeline Latency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildVerticalLatencyBar('STT', sttLat, maxLat, Colors.blue, textColor, isDarkMode),
                _buildVerticalLatencyBar('LLM', llmLat, maxLat, Colors.deepPurpleAccent, textColor, isDarkMode),
                _buildVerticalLatencyBar('TTS', ttsLat, maxLat, Colors.teal, textColor, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom widget for a vertical, bottom-up progress bar
  Widget _buildVerticalLatencyBar(String label, double value, double maxVal, Color color, Color textColor, bool isDarkMode) {
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;
    final double percentage = (value / maxVal).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 1. The Value at the top
        Text(
          '${value.toInt()} ms',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        
        // 2. The Vertical Bar
        Expanded(
          child: Container(
            width: 45, // Thicker, pill-shaped vertical bars
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.bottomCenter, // Fills from bottom to top
            child: FractionallySizedBox(
              heightFactor: percentage > 0 ? percentage : 0.05, // Minimum sliver if 0
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.6), color],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 3. The Label at the bottom
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildHorizontalIndicator(String text, Color color, int value, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;

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
