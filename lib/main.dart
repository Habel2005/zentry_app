import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'theme_provider.dart'; // Import the new ThemeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Disable network fetching for Google Fonts to ensure bundled fonts are used
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Define a common TextTheme
    final TextTheme appTextTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.grey[100],
      textTheme: appTextTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFF121212), // A common dark background
      textTheme: appTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp(
      title: 'Zentry',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthRedirect(),
    );
  }
}

class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.deepPurple,)),
          );
        }

        if (snapshot.hasData && snapshot.data!.session != null) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
