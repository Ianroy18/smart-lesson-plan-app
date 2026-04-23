import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html; 
import '../models/lesson_plan.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError("SQLite is not supported on web");
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_lesson_plans.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lesson_plans (
        id TEXT PRIMARY KEY,
        userId TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        school TEXT,
        teacherName TEXT,
        subject TEXT,
        gradeLevel TEXT,
        date TEXT,
        quarter TEXT,
        contentStandard TEXT,
        performanceStandard TEXT,
        melc TEXT,
        topic TEXT,
        teachersGuide TEXT,
        learnersMaterials TEXT,
        otherMaterials TEXT,
        procedures TEXT,
        assessment TEXT,
        remarks TEXT,
        reflectionWhatWorked TEXT,
        reflectionNeedsImprovement TEXT,
        learnersMastery INTEGER
      )
    ''');
  }

  // --- WEB FALLBACK (LocalStorage) ---
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

  // --- CROSS-PLATFORM CRUD ---

  Future<void> insertLessonPlan(LessonPlan plan) async {
    if (kIsWeb) {
      final lessons = _getWebLessons();
      lessons.removeWhere((l) => l.id == plan.id); // Prevent duplicates
      lessons.add(plan);
      _saveWebLessons(lessons);
      return;
    }
    Database db = await database;
    await db.insert('lesson_plans', plan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LessonPlan>> getLessonPlans(String userId) async {
    if (kIsWeb) {
      return _getWebLessons().where((l) => l.userId == userId).toList();
    }
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'lesson_plans',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => LessonPlan.fromMap(maps[i]));
  }

  Future<void> updateLessonPlan(LessonPlan plan) async {
    if (kIsWeb) return insertLessonPlan(plan);
    Database db = await database;
    await db.update(
      'lesson_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<void> deleteLessonPlan(String id) async {
    if (kIsWeb) {
      final lessons = _getWebLessons();
      lessons.removeWhere((l) => l.id == id);
      _saveWebLessons(lessons);
      return;
    }
    Database db = await database;
    await db.delete(
      'lesson_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
