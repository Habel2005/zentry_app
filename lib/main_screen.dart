import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dashboard_screen.dart';
import 'call_log_screen.dart';
import 'account_settings_screen.dart';
import 'coming_soon_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    CallLogScreen(),
    ComingSoonScreen(pageTitle: 'Caller Overview'), // Updated page title
    ComingSoonScreen(pageTitle: 'Admission Baseline'), // Updated page title
  ];

  final List<String> _titles = [
    'Dashboard Overview',
    'Call History',
    'Caller Overview', // Updated title
    'Admission Baseline' // Updated title
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red
  ];

  void _onProfileTap() {
    // We will navigate to the AccountSettingsScreen directly
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountSettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: isDarkMode
                  ? const Color(0xFF1A1A1A).withAlpha(200)
                  : Colors.white.withAlpha(200),
              elevation: 0,
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: _onProfileTap,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 22, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1A1A1A).withAlpha(204) // 0.8 alpha
              : Colors.white.withAlpha(204), // 0.8 alpha
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withAlpha(64) // 0.25 alpha
                  : Colors.black.withAlpha(26), // 0.1 alpha
              spreadRadius: 2,
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: GNav(
                mainAxisAlignment: MainAxisAlignment.center,
                rippleColor: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                hoverColor: isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
                gap: 8,
                activeColor: _colors[_selectedIndex],
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: isDarkMode
                    ? _colors[_selectedIndex].withAlpha(100)
                    : _colors[_selectedIndex].withAlpha(60),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                tabs: const [
                  GButton(
                    icon: Icons.dashboard_rounded,
                    text: 'Dashboard',
                  ),
                  GButton(
                    icon: Icons.history_rounded,
                    text: 'Logs',
                  ),
                  GButton(
                    icon: Icons.analytics_outlined, // Updated icon
                    text: 'Overview', // Updated text
                  ),
                  GButton(
                    icon: Icons.show_chart_rounded, // Updated icon
                    text: 'Baseline', // Updated text
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
