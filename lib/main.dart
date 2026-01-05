import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/connectivity_provider.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/offline_dialog.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ],
      child: const MyApp(), // The root of the application.
    ),
  );
}

// The root widget that now correctly builds the UI layers.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appTextTheme = GoogleFonts.poppinsTextTheme(textTheme);
    const primarySeedColor = Color(0xFF6200EE);

    final lightTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        textTheme: appTextTheme);

    final darkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark, surface: const Color(0xFF121212)),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: appTextTheme.apply(bodyColor: Colors.white.withAlpha(217), displayColor: Colors.white));

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
          // The builder is now the correct place to stack the UI.
          builder: (context, appChild) {
            return Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                return Stack(
                  children: [
                    appChild!, // The main app content (Navigator, etc.)
                    if (connectivity.shouldShowDialog) 
                      const OfflineDialog(),
                  ],
                );
              },
            );
          },
          home: const MainContent(), // The initial screen.
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// This widget handles the initial onboarding check.
class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  late final Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = _isOnboardingCompleted();
  }

  Future<bool> _isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
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
    );
  }
}

// This widget handles the authentication flow.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
