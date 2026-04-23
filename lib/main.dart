import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/lesson_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTE: You need to run 'flutterfire configure' in your terminal
  // to generate the firebase_options.dart file for your specific project.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  final prefs = await SharedPreferences.getInstance();
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
