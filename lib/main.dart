import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/lesson_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool showWelcome = prefs.getBool('show_welcome') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: SmartLessonApp(showWelcome: showWelcome),
    ),
  );
}

class SmartLessonApp extends StatelessWidget {
  final bool showWelcome;
  const SmartLessonApp({super.key, required this.showWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lesson Plan System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: showWelcome ? const WelcomeScreen() : const DashboardScreen(),
    );
  }
}
