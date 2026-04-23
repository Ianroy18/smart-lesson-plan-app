import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson_plan.dart';
import '../../services/pdf_service.dart';
import '../editor/lesson_editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<LessonProvider>().fetchLessons('test_user_123'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Lesson Plan System'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.user),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.lessons.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: provider.lessons.length,
            itemBuilder: (context, index) {
              final lesson = provider.lessons[index];
              return _LessonCard(lesson: lesson)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                  .slideY(begin: 0.2, end: 0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LessonEditorScreen(),
            ),
          );
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
          Text(
            'No lesson plans yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text('Tap "+" to start writing your first plan'),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonPlan lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonEditorScreen(lesson: lesson),
            ),
          );
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Q${lesson.quarter}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.graduationCap, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${lesson.gradeLevel} - ${lesson.subject}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    lesson.date != null
                        ? DateFormat('MMM dd, yyyy').format(lesson.date!)
                        : 'No date set',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => PdfService.generateAndPrint(lesson),
                    icon: const Icon(LucideIcons.fileText, size: 18),
                    label: const Text('Export PDF'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.red),
                    onPressed: () {
                      context.read<LessonProvider>().deleteLesson(lesson.id!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
