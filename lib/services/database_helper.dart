import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lesson_plan.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
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

  Future<int> insertLessonPlan(LessonPlan plan) async {
    Database db = await database;
    return await db.insert('lesson_plans', plan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LessonPlan>> getLessonPlans(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'lesson_plans',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => LessonPlan.fromMap(maps[i]));
  }

  Future<int> updateLessonPlan(LessonPlan plan) async {
    Database db = await database;
    return await db.update(
      'lesson_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deleteLessonPlan(String id) async {
    Database db = await database;
    return await db.delete(
      'lesson_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
