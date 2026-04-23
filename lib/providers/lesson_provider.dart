import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/lesson_plan.dart';
import '../services/lesson_repository.dart';

class LessonProvider with ChangeNotifier {
  final LessonRepository _repo = LessonRepository();
  List<LessonPlan> _lessons = [];
  bool _isLoading = false;

  List<LessonPlan> get lessons => _lessons;
  bool get isLoading => _isLoading;

  Future<void> fetchLessons(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _lessons = await _repo.getAll(userId);
      if (_lessons.isEmpty) {
        _lessons = [
          LessonPlan(
            id: 'sample-1',
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            school: 'San Jose National High School',
            teacherName: 'Juan Dela Cruz',
            subject: 'Mathematics',
            gradeLevel: 'Grade 10',
            topic: 'Quadratic Equations and Functions',
            quarter: '1',
            date: DateTime.now(),
            contentStandard: 'Understanding quadratic equations, inequalities and functions.',
            performanceStandard: 'Solve real-life problems involving quadratic equations.',
            melc: 'Solves quadratic equations by extracting square roots. (M9AL-Ia-1)',
          )
        ];
      }
    } catch (e) {
      debugPrint("Error fetching lessons: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLesson(LessonPlan lesson) async {
    lesson.id ??= const Uuid().v4();
    await _repo.save(lesson);
    _lessons.insert(0, lesson);
    notifyListeners();
  }

  Future<void> updateLesson(LessonPlan lesson) async {
    lesson.updatedAt = DateTime.now();
    await _repo.save(lesson);
    int index = _lessons.indexWhere((l) => l.id == lesson.id);
    if (index != -1) {
      _lessons[index] = lesson;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String id) async {
    await _repo.delete(id);
    _lessons.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // Auto-save logic can be called periodically from UI
  Future<void> autoSave(LessonPlan lesson) async {
    await updateLesson(lesson);
  }
}
