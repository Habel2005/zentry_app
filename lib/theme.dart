import 'package:flutter/material.dart';

class AppTheme {
  static final Color slateBlue = Colors.blue.shade900;
  static const Color red = Colors.red;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: slateBlue,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    colorScheme: ColorScheme.light(
      primary: slateBlue,
      secondary: slateBlue,
      surface: Colors.grey[100]!,
    ),
  );
}
