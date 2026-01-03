import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'main_screen.dart';
import 'call_detail_screen.dart';
import 'supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/calls/:callId',
      builder: (context, state) {
        final callId = state.pathParameters['callId']!;
        return CallDetailScreen(callId: callId);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);

    return MaterialApp.router(
      title: 'Zentry Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
          titleTextStyle: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blueGrey.withOpacity(0.1),
          selectedIconTheme: const IconThemeData(color: Colors.blueGrey),
          unselectedIconTheme: IconThemeData(color: Colors.grey[400]!),
          selectedLabelTextStyle: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: Colors.grey[600]!,
          ),
        ),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
