import 'package:flutter/foundation.dart';
import '../models/lesson_plan.dart';
import 'database_helper_web.dart' if (dart.library.io) 'database_helper_mobile.dart';

abstract class LessonRepository {
  Future<void> save(LessonPlan plan);
  Future<List<LessonPlan>> getAll(String userId);
  Future<void> delete(String id);

  factory LessonRepository() {
    if (kIsWeb) return DatabaseHelperWeb();
    return getInstance(); // This comes from conditional imports
  }
}
