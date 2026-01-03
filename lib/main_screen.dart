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
    ComingSoonScreen(pageTitle: 'Analytics'),
    AccountSettingsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard Overview',
    'Call History',
    'Analytics',
    'My Profile' // Changed for the settings screen
  ];

  void _onProfileTap() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white.withAlpha(200), // Light glass effect
              elevation: 0,
              centerTitle: true,
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted margin for better spacing
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220), // Light glass effect
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.center, // Key fix for overflow
            rippleColor: Colors.grey[200]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.deepPurple,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.deepPurple.withAlpha(60), // Light, subtle highlight
            color: Colors.black54,
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
                icon: Icons.analytics_rounded,
                text: 'Analytics',
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profile',
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
    );
  }
}
