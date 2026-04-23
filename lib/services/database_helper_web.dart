import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../../models/lesson_plan.dart';
import 'database_helper_stub.dart';

class DatabaseHelperWeb implements DatabaseHelper {
  static final DatabaseHelperWeb _instance = DatabaseHelperWeb._internal();
  factory DatabaseHelperWeb() => _instance;
  DatabaseHelperWeb._internal();

  static const String _webDbKey = 'smart_lesson_plans_db';

  List<LessonPlan> _getWebLessons() {
    final data = html.window.localStorage[_webDbKey];
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => LessonPlan.fromMap(e)).toList();
  }

  void _saveWebLessons(List<LessonPlan> lessons) {
    final encoded = jsonEncode(lessons.map((e) => e.toMap()).toList());
    html.window.localStorage[_webDbKey] = encoded;
  }

  @override
  Future<void> insertLessonPlan(LessonPlan plan) async {
    final lessons = _getWebLessons();
    lessons.removeWhere((l) => l.id == plan.id);
    lessons.add(plan);
    _saveWebLessons(lessons);
  }

  @override
  Future<List<LessonPlan>> getLessonPlans(String userId) async {
    return _getWebLessons().where((l) => l.userId == userId).toList();
  }

  @override
  Future<void> updateLessonPlan(LessonPlan plan) async {
    await insertLessonPlan(plan);
  }

  @override
  Future<void> deleteLessonPlan(String id) async {
    final lessons = _getWebLessons();
    lessons.removeWhere((l) => l.id == id);
    _saveWebLessons(lessons);
  }
}

// Global factory for conditional export
DatabaseHelper getInstance() => DatabaseHelperWeb();
