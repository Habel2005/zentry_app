import 'package:myapp/call_log_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/supabase_service.dart';
import 'package:myapp/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'call_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Admin Panel',
            themeMode: themeProvider.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            routerConfig: _router,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final baseTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(SupabaseService().authStateChanges),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = SupabaseService().currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn) {
      return '/login';
    }
    if (loggedIn && loggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // The MainScreen now acts as the shell for other routes
        return const MainScreen();
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CallLogScreen(), // Default to call log
        ),
        GoRoute(
          path: '/calls/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CallDetailScreen(callId: id);
          },
        ),
      ],
    ),
  ],
);
