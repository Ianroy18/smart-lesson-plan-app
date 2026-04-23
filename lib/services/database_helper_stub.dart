import '../../models/lesson_plan.dart';

abstract class DatabaseHelper {
  static DatabaseHelper getInstance() => throw UnsupportedError('Cannot create DatabaseHelper');
  Future<void> insertLessonPlan(LessonPlan plan);
  Future<List<LessonPlan>> getLessonPlans(String userId);
  Future<void> updateLessonPlan(LessonPlan plan);
  Future<void> deleteLessonPlan(String id);
}
