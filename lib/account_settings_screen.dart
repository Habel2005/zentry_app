import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Safely get the current user
  final User? user = Supabase.instance.client.auth.currentUser;

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Navigator.of(context).pushReplacement(...) is handled by the AuthRedirect
    } catch (e) {
      // Handle sign-out errors, maybe show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Max width for larger screens
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildThemeToggle(themeProvider),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          user?.email ?? 'Loading...',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade200.withOpacity(0.5)
              : Colors.grey.shade800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Keep the row compact
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.orange,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            _AnimatedThemeSwitch(themeProvider: themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _signOut,
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
    );
  }
}

// A custom animated switch for a more modern feel
class _AnimatedThemeSwitch extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _AnimatedThemeSwitch({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme(!themeProvider.isDarkMode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: themeProvider.isDarkMode ? Colors.deepPurple : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: themeProvider.isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
