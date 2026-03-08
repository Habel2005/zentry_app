import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/call_details_screen.dart'; // Ensure correct import name
import 'package:myapp/models/admin_call_list.dart';
import 'package:myapp/refresh_screen.dart';
import 'package:myapp/supabase_service.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  late Future<List<AdminCallList>> _callListFuture;
  
  // --- Search & Filter State ---
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // --- NEW: Scroll Controller & FAB State ---
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  final List<String> _filters = [
    'All',
    'Completed',
    'Dropped',
    'Repeat Callers',
    'Bad STT',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // --- NEW: Listen to scroll position ---
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400 && !_showBackToTopButton) {
        setState(() {
          _showBackToTopButton = true; // Show when scrolled down 400 pixels
        });
      } else if (_scrollController.offset < 400 && _showBackToTopButton) {
        setState(() {
          _showBackToTopButton = false; // Hide when near top
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose(); // Don't forget to dispose the controller!
    super.dispose();
  }

  void _loadData() {
    _callListFuture = SupabaseService().getCallList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  void _navigateToDetails(AdminCallList call) {
    if (call.callId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallDetailsScreen(callId: call.callId!),
        ),
      );
    }
  }

  // --- NEW: Scroll To Top Action ---
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  List<AdminCallList> _getFilteredCalls(List<AdminCallList> calls) {
    return calls.where((call) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          (call.callId?.toLowerCase().contains(query) ?? false) ||
          (call.language?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Completed':
          return call.status.toLowerCase() == 'completed';
        case 'Dropped':
          return call.status.toLowerCase() == 'dropped';
        case 'Repeat Callers':
          return call.isRepeatCaller == true;
        case 'Bad STT':
          return call.sttQuality.toLowerCase() == 'low' || call.sttQuality.toLowerCase() == 'failed';
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withAlpha(230) : Colors.black87;

    // Wrapped everything in a transparent Scaffold to hold the FloatingActionButton
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      // --- NEW: Animated Floating Action Button ---
      floatingActionButton: AnimatedScale(
        scale: _showBackToTopButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Padding(
          // Padding to push the button above your custom bottom navigation bar
          padding: const EdgeInsets.only(bottom: 80.0, right: 8.0),
          child: FloatingActionButton(
            onPressed: _scrollToTop,
            backgroundColor: Colors.teal,
            elevation: 4,
            mini: true, // Smaller profile looks cleaner on logs
            child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      
      body: RiveRefreshIndicator(
        riveAnimationPath: 'assets/riv/load.riv',
        onRefresh: _refreshData,
        child: FutureBuilder<List<AdminCallList>>(
          future: _callListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No call logs found.'));
            }

            final allCalls = snapshot.data!;
            final filteredCalls = _getFilteredCalls(allCalls);

            return CustomScrollView(
              controller: _scrollController, // Attach the controller here!
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(isDarkMode),
                        const SizedBox(height: 16),
                        _buildFilterChips(isDarkMode),
                        const SizedBox(height: 8),
                        if (filteredCalls.isEmpty)
                           const Padding(
                             padding: EdgeInsets.only(top: 40.0),
                             child: Center(child: Text('No calls match these filters.', style: TextStyle(color: Colors.grey))),
                           ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final call = filteredCalls[index];
                        return _buildCallCard(call, cardColor, textColor, isDarkMode);
                      },
                      childCount: filteredCalls.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: 'Search Session ID or Language...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                });
              },
              selectedColor: Colors.teal.withOpacity(0.2),
              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Colors.teal 
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.teal.withOpacity(0.5) : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCallCard(AdminCallList call, Color cardColor, Color textColor, bool isDarkMode) {
    final bool isAiFailure = call.status.toLowerCase() == 'dropped' && 
                            (call.sttQuality.toLowerCase() == 'low' || call.sttQuality.toLowerCase() == 'failed');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isAiFailure 
              ? Colors.redAccent.withOpacity(0.5) 
              : (isDarkMode ? Colors.white.withAlpha(50) : Colors.grey.withAlpha(100)),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(call),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat.yMd().add_jms().format(call.startTime),
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                      ),
                      if (isAiFailure) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                      ]
                    ],
                  ),
                  _buildStatusChip(call.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('Duration', '${call.duration}s', isDarkMode),
                  _buildMetric('Language', call.language ?? 'N/A', isDarkMode),
                  _buildSttQualityIndicator(call.sttQuality, isDarkMode),
                  _buildMetric('Repeat', call.isRepeatCaller ? 'Yes' : 'No', isDarkMode, 
                    valueColor: call.isRepeatCaller ? Colors.teal : null),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDarkMode, {Color? valueColor}) {
     final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;
     final defaultColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? defaultColor)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String label;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade300;
        label = 'Completed';
        break;
      case 'dropped':
        chipColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade300;
        label = 'Dropped';
        break;
      case 'ongoing':
        chipColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade300;
        label = 'Ongoing';
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey.shade300;
        label = status;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }

  Widget _buildSttQualityIndicator(String quality, bool isDarkMode) {
    Color color;
    final subTextColor = isDarkMode ? Colors.white.withAlpha(153) : Colors.black54;

    switch (quality.toLowerCase()) {
      case 'good':
        color = Colors.cyan;
        break;
      case 'low':
        color = Colors.amber;
        break;
      case 'failed':
        color = Colors.pinkAccent;
        break;
      default:
        color = Colors.grey;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('STT Quality', style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(quality, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}