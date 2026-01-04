import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:rive/rive.dart';
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
  SMIBool? _hamMenuInput;
  SMIBool? _profileHover;
  SMITrigger? _profilePressed;

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
    'Admission Baseline', // Updated title
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  void _onProfileTap() {
    // We will navigate to the AccountSettingsScreen directly
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
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
                    onTap: () {
                      _onProfileTap(); // Calls your function
                      _profilePressed
                          ?.fire(); // Fires the trigger confirmed in debug
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Colors.white, // Match the Rive file background
                      child: ClipOval(
                        child: Transform.scale(
                          scale:
                              2.5, // Your confirmed "sweet spot" to hide grey background
                          child: RiveAnimation.asset(
                            'assets/riv/avatar.riv',
                            artboard:
                                'New Artboard', // Matches your debug output
                            fit: BoxFit.cover,
                            onInit: (artboard) {
                              final controller =
                                  StateMachineController.fromArtboard(
                                    artboard,
                                    'State Machine 1', // Matches your debug output
                                  );
                              if (controller != null) {
                                artboard.addController(controller);
                                // Matches debug: 'Hover' (Bool) and 'Pressed' (Trigger)
                                _profileHover =
                                    controller.findInput<bool>('Hover')
                                        as SMIBool?;
                                _profilePressed =
                                    controller.findSMI('Pressed')
                                        as SMITrigger?;
                              }
                            },
                          ),
                        ),
                      ),
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
              ? const Color(0xFF1A1A1A).withAlpha(170) // ~67% alpha
              : Colors.white.withAlpha(170), // ~67% alpha
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withAlpha(51) // 0.2 alpha
                  : Colors.black.withAlpha(20), // 0.08 alpha
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: GNav(
                mainAxisAlignment: MainAxisAlignment.center,
                rippleColor: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                hoverColor: isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
                gap: 8,
                activeColor: _colors[_selectedIndex],
                iconSize: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: isDarkMode
                    ? _colors[_selectedIndex].withAlpha(70)
                    : _colors[_selectedIndex].withAlpha(40),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                tabs: [
                  GButton(
                    icon: Icons.dashboard_rounded,
                    text: 'Dashboard',
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white, // This fills the circle background
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        // This creates the circular "window"
                        child: Transform.scale(
                          scale: 6.5,
                          child: Transform.translate(
                            offset: const Offset(
                              0,
                              0.6,
                            ), // Keep your vertical adjustment
                            child: RiveAnimation.asset(
                              'assets/riv/ham.riv',
                              artboard: 'New Artboard',
                              fit: BoxFit.cover,
                              onInit: (artboard) {
                                final controller =
                                    StateMachineController.fromArtboard(
                                      artboard,
                                      artboard.stateMachines.first.name,
                                    );
                                if (controller != null) {
                                  artboard.addController(controller);
                                  _hamMenuInput =
                                      controller.findInput<bool>('Hover/Press')
                                          as SMIBool?;
                                  if (_hamMenuInput != null) {
                                    _hamMenuInput!.value =
                                        (_selectedIndex == 0);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GButton(
                    icon: Icons.dashboard_rounded, // Keeps GNav spacing logic
                    text: 'Dashboard',
                    leading: Container(
                      width: 28, // Slightly larger for better visibility
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 2.5, // Your confirmed sweet spot
                          child: RiveAnimation.asset(
                            'assets/riv/doc.riv',
                            artboard: 'New Artboard',
                            fit: BoxFit.cover,
                            onInit: (artboard) {
                              final controller =
                                  StateMachineController.fromArtboard(
                                    artboard,
                                    'State Machine 1',
                                  );
                              if (controller != null) {
                                artboard.addController(controller);

                                // Updated to match your exact Input name: 'Pressed/Hover'
                                _hamMenuInput =
                                    controller.findInput<bool>('Pressed/Hover')
                                        as SMIBool?;

                                if (_hamMenuInput != null) {
                                  _hamMenuInput!.value = (_selectedIndex == 0);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const GButton(
                    icon: Icons.analytics_outlined, // Updated icon
                    text: 'Overview', // Updated text
                  ),
                  const GButton(
                    icon: Icons.show_chart_rounded, // Updated icon
                    text: 'Baseline', // Updated text
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (_hamMenuInput != null) {
                    _hamMenuInput!.value = (index == 0);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
