import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async { // Made main async
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseService.initialize();

  // Make the status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android
      statusBarBrightness: Brightness.light,    // For iOS
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    const primarySeedColor = Color(0xFF6200EE);

    final textTheme = Theme.of(context).textTheme;
    final appTextTheme = GoogleFonts.poppinsTextTheme(textTheme).copyWith(
      // You can add more specific text style overrides here if needed
    );

    // --- Modern Light Theme ---
        final ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primarySeedColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F7), // A clean, Apple-like light gray
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white.withAlpha(200),
            foregroundColor: Colors.black87,
            elevation: 0,
            titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primarySeedColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );

    // --- Modern Dark Theme ---
        final ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primarySeedColor,
            brightness: Brightness.dark,
            surface: const Color(0xFF121212), // Deep, rich dark background
          ),
          scaffoldBackgroundColor: const Color(0xFF121212), // Softer, less contrasty dark background
          textTheme: appTextTheme.apply(bodyColor: Colors.white.withAlpha(217), displayColor: Colors.white),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1C1C1E).withAlpha(200), // Slightly lighter than background
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: appTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primarySeedColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode ?? (MediaQuery.of(context).platformBrightness == Brightness.dark);
        // Update the status bar icon brightness based on the theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
        );

        return MaterialApp(
          title: 'ConvoSense AI',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: FutureBuilder<bool>(
            future: _isOnboardingCompleted(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.data == true) {
                return const AuthGate();
              } else {
                return const OnboardingScreen();
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
