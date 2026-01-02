
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color slateBlue = Color(0xFF708090);
  static const Color offWhite = Color(0xFFF8F8FF);
  static const Color teal = Color(0xFF008080);
  static const Color amber = Color(0xFFFFB347);
  static const Color red = Color(0xFFF44336);
  static const Color darkSlateGray = Color(0xFF2F4F4F);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: slateBlue,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: slateBlue,
        secondary: teal,
        background: offWhite,
        surface: offWhite,
        error: red,
        onPrimary: offWhite,
        onSecondary: offWhite,
        onBackground: darkSlateGray,
        onSurface: darkSlateGray,
        onError: offWhite,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          labelSmall: TextStyle(fontSize: 12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: slateBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: offWhite),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
