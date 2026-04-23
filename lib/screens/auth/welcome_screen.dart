import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_welcome', false);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF003366),
              const Color(0xFF003366).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo Placeholder (User will see the generated logo in UI)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: const Icon(LucideIcons.bookOpen, size: 80, color: Color(0xFF003366)),
              ).animate().scale(duration: 600.ms, curve: Curves.backOut),
              const SizedBox(height: 24),
              const Text(
                'Smart Lesson Plan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const Text(
                'Digital notebook for modern teachers',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              _buildFeatureRow(LucideIcons.zap, 'Offline-First', 'Work anytime, anywhere without internet.'),
              _buildFeatureRow(LucideIcons.fileText, 'DepEd Format', 'Compliant with DepEd Order No. 42 s. 2016.'),
              _buildFeatureRow(LucideIcons.share2, 'Easy Export', 'Print or share your plans as professional PDFs.'),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () => _completeOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8102E), // DepEd Red
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate().slideY(begin: 1, end: 0, delay: 800.ms),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showHowToUse(context),
                child: const Text('How to Use This App?', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              const Text(
                'by kuya ian',
                style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.2),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0);
  }

  void _showHowToUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const HowToUseModal(),
    );
  }
}

class HowToUseModal extends StatelessWidget {
  const HowToUseModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('How to Use', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _step(1, 'Create a Lesson', 'Tap the red "+" button on the dashboard to start a new plan.'),
                _step(2, 'Fill in Details', 'Follow the 7 steps (Header to Reflection). The app auto-saves your progress.'),
                _step(3, 'Two-Column Procedures', 'Input Teacher Activities and Learner Responses side-by-side (Horizontal on Web, Vertical on Mobile).'),
                _step(4, 'Export to PDF', 'Tap the file icon to generate a professional DepEd-style PDF ready for printing.'),
                _step(5, 'Offline Work', 'Don\'t worry about internet! All your plans are saved locally on your device.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _step(int num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF003366), radius: 14, child: Text('$num', style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
