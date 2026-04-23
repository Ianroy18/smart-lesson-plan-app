import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/lesson_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    
    // One-time reset logic
    if (prefs.getBool('force_reset_v3') == null) {
      await prefs.clear();
      await prefs.setBool('force_reset_v3', true);
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Firebase init error: $e");
    }

    final bool showWelcome = prefs.getBool('show_welcome') ?? true;
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LessonProvider()),
        ],
        child: SmartLessonApp(
          showWelcome: showWelcome,
          isLoggedIn: isLoggedIn,
        ),
      ),
    );
  } catch (e) {
    debugPrint("Critical Init Error: $e");
    // Fallback to minimal app if everything fails
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text("App Error. Please Refresh.")))));
  }
}

class SmartLessonApp extends StatelessWidget {
  final bool showWelcome;
  final bool isLoggedIn;
  const SmartLessonApp({
    super.key, 
    required this.showWelcome,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lesson Plan System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/': (context) => _getHome(),
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }

  Widget _getHome() {
    if (showWelcome) return const WelcomeScreen();
    if (isLoggedIn) return const DashboardScreen();
    return const LoginScreen();
  }
}
