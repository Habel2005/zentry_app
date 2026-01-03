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
  final User? user = Supabase.instance.client.auth.currentUser;

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Auth redirect will handle navigation
    } catch (e) {
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: isDarkMode
                  ? const Color(0xFF1A1A1A).withAlpha(200)
                  : Colors.white.withAlpha(200),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildGlassContainer(
              context,
              child: Column(
                children: [
                  _buildThemeToggle(themeProvider),
                  _buildDivider(),
                  _buildInfoTile('App Version', '1.0.0'),
                ],
              ),
            ),
            const SizedBox(height: 20),
             _buildGlassContainer(
              context,
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer(BuildContext context, {required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
  
  Widget _buildDivider() => Divider(height: 1, color: Colors.white.withOpacity(0.2), indent: 16, endIndent: 16,);

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          user?.email ?? 'Loading...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enterprise User',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_rounded, size: 24),
      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: _AnimatedThemeSwitch(themeProvider: themeProvider),
      onTap: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
    );
  }

   Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.info_outline_rounded, size: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }


  Widget _buildLogoutButton() {
    return ListTile(
      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
      title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
      onTap: _signOut,
    );
  }
}

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
