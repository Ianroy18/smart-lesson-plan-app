import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson_plan.dart';
import '../../services/pdf_service.dart';
import '../editor/lesson_editor_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<LessonProvider>().fetchLessons('test_user_123'));
  }

  void _sendEmail(LessonPlan lesson) async {
    final String subject = Uri.encodeComponent("Lesson Plan: ${lesson.topic}");
    final String body = Uri.encodeComponent(
      "Detailed Lesson Plan Summary\n\n"
      "Subject: ${lesson.subject}\n"
      "Grade: ${lesson.gradeLevel}\n"
      "Topic: ${lesson.topic}\n\n"
      "Generated via Smart Lesson Plan System by kuya ian"
    );
    final Uri mail = Uri.parse("mailto:?subject=$subject&body=$body");
    if (await canLaunchUrl(mail)) {
      await launchUrl(mail);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search plans...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            )
          : const Text('Lesson Plan'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search), 
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            }
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.user),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('My Profile')),
              const PopupMenuItem(
                value: 'logout', 
                child: Text('Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.lessons.isEmpty) return _buildEmptyState();

          final lessons = provider.lessons.where((l) {
            return l.topic.toLowerCase().contains(_searchQuery) ||
                   l.subject.toLowerCase().contains(_searchQuery) ||
                   l.gradeLevel.toLowerCase().contains(_searchQuery);
          }).toList();

          if (lessons.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(child: Text('No results found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _LessonCard(
                lesson: lesson,
                onEmail: () => _sendEmail(lesson),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                  .slideY(begin: 0.2, end: 0);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Text(
          'by kuya ian',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LessonEditorScreen()));
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Create New Plan'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bookOpen, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No lesson plans yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          const Text('Tap "+" to start writing your first plan'),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonPlan lesson;
  final VoidCallback onEmail;

  const _LessonCard({required this.lesson, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LessonEditorScreen(lesson: lesson)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lesson.topic.isEmpty ? 'Untitled Lesson' : lesson.topic,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQuarterBadge(context, lesson.quarter),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(LucideIcons.graduationCap, '${lesson.gradeLevel} - ${lesson.subject}'),
              const SizedBox(height: 4),
              _buildInfoRow(LucideIcons.calendar, lesson.date != null ? DateFormat('MMM dd, yyyy').format(lesson.date!) : 'No date set'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.mail, size: 20, color: Colors.orange),
                    onPressed: onEmail,
                    tooltip: 'Email Summary',
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.fileText, size: 20, color: Colors.blue),
                    onPressed: () => PdfService.generateAndPrint(lesson),
                    tooltip: 'Export PDF',
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                    onPressed: () => context.read<LessonProvider>().deleteLesson(lesson.id!),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuarterBadge(BuildContext context, String quarter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Q$quarter', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
