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
  // Separate variables for each icon
  SMIBool? _hamInput;
  SMIBool? _docInput;
  SMIBool? _folderInput;
  SMITrigger? _layersInput;

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
                    onTap: _onProfileTap,
                    child: CircleAvatar(
                      radius: 18,
                      // Background color changes based on theme
                      backgroundColor: isDarkMode
                          ? Colors.deepPurpleAccent.withAlpha(
                              150,
                            ) // Dark mode background
                          : const Color.fromARGB(
                              255,
                              135,
                              104,
                              188,
                            ), // Your light mode color
                      child: Icon(
                        Icons.person,
                        size: 22,
                        // Icon color can also toggle if needed, or stay white
                        color: isDarkMode ? Colors.white : Colors.white,
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
                                  // Use the unique _hamInput variable
                                  _hamInput =
                                      controller.findInput<bool>('Hover/Press')
                                          as SMIBool?;
                                  if (_hamInput != null) {
                                    _hamInput!.value = (_selectedIndex == 0);
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
                                // Use the unique _docInput variable
                                _docInput =
                                    controller.findInput<bool>('Pressed/Hover')
                                        as SMIBool?;
                                if (_docInput != null) {
                                  _docInput!.value = (_selectedIndex == 1);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  GButton(
                    icon: Icons.analytics_outlined,
                    text: 'Overview',
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: AnimatedScale(
                          scale: 6,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedSlide(
                            // This moves the icon based on whether it is selected
                            // Offset(x, y) where y: 0.0 is center, 1.0 is full height down
                            offset: _selectedIndex == 2
                                ? const Offset(
                                    0,
                                    0.04,
                                  ) // Move it DOWN when animating
                                : const Offset(
                                    0,
                                    0.008,
                                  ), // Stay centered when idle
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: RiveAnimation.asset(
                              'assets/riv/folder.riv',
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
                                  _folderInput =
                                      controller.findInput<bool>('Hover/Press')
                                          as SMIBool?;
                                  if (_folderInput != null) {
                                    _folderInput!.value = (_selectedIndex == 2);
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
                    icon: Icons.layers_rounded,
                    text: 'Baseline',
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 2.0,
                          child: Transform.translate(
                            offset: Offset(0, 1),
                            child: RiveAnimation.asset(
                              'assets/riv/layer.riv',
                              artboard: 'Artboard',
                              fit: BoxFit.contain,
                              onInit: (artboard) {
                                final controller =
                                    StateMachineController.fromArtboard(
                                      artboard,
                                      'State Machine 1',
                                    );
                                if (controller != null) {
                                  artboard.addController(controller);
                            
                                  // 1. Change SMIBool to SMITrigger
                                  _layersInput =
                                      controller.findInput<bool>('Click')
                                          as SMITrigger?;
                            
                                  // 2. Use .fire() instead of .value
                                  if (_selectedIndex == 3) {
                                    _layersInput?.fire();
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (_hamInput != null) {
                    _hamInput!.value = (index == 0);
                  }

                  // Update the doc icon (Index 1)
                  if (_docInput != null) {
                    _docInput!.value = (index == 1);
                  }

                  if (_folderInput != null) {
                    _folderInput!.value = (index == 2);
                  }

                  if (index == 3 && _layersInput != null) {
                    _layersInput!
                        .fire(); // This triggers the "Click-on" animation sequence
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
