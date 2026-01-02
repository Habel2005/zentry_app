import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zentry_insights/lib/theme.dart';
import 'package:zentry_insights/lib/login_screen.dart';
import 'package:zentry_insights/lib/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zentry Insights',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
