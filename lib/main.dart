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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// CRITICAL FIX: Converted to a StatefulWidget to prevent login screen reload.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    // The future is now run only ONCE when the app starts.
    _onboardingFuture = _isOnboardingCompleted();
  }

  Future<bool> _isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    // For testing, you can uncomment the line below to reset onboarding
    // await prefs.setBool('onboarding_completed', false);
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    const primarySeedColor = Color(0xFF6200EE);

    final textTheme = Theme.of(context).textTheme;
    final appTextTheme = GoogleFonts.poppinsTextTheme(textTheme);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
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

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: appTextTheme.apply(bodyColor: Colors.white.withAlpha(217), displayColor: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C1C1E).withAlpha(200),
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
          // The FutureBuilder now uses the state variable, preventing reloads.
          home: FutureBuilder<bool>(
            future: _onboardingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final isOnboardingCompleted = snapshot.data ?? false;

              if (isOnboardingCompleted) {
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for auth state, show a loader.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
