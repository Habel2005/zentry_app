import 'dart:ui';
import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String pageTitle;

  const ComingSoonScreen({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Important for the glass effect
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), // Max width for larger screens
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.black.withAlpha(64) // 0.25 alpha
                      : Colors.white.withAlpha(38), // 0.15 alpha
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(51)), // 0.2 alpha
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pageTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.construction_rounded,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary.withAlpha(204), // 0.8 alpha
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white.withAlpha(230) : Colors.black54, // 0.9 alpha
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We are working hard to bring you this feature. Stay tuned!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
