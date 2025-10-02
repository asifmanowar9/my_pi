import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../../shared/models/course.dart';
import '../../shared/models/assignment.dart';
import '../../shared/models/grade.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const int _currentVersion = 2;
  static const String _databaseName = 'my_pi.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        profile_image_url TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create courses table
    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT UNIQUE,
        credits INTEGER NOT NULL DEFAULT 3,
        instructor TEXT,
        color TEXT DEFAULT '#2196F3',
        semester TEXT,
        year INTEGER,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create assignments table
    await db.execute('''
      CREATE TABLE assignments(
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        priority TEXT DEFAULT 'medium',
        grade REAL,
        max_grade REAL DEFAULT 100.0,
        submission_url TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Create grades table
    await db.execute('''
      CREATE TABLE grades(
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        assignment_id TEXT,
        grade REAL NOT NULL,
        max_grade REAL NOT NULL DEFAULT 100.0,
        type TEXT NOT NULL DEFAULT 'assignment',
        weight REAL DEFAULT 1.0,
        date TEXT NOT NULL,
        notes TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE,
        FOREIGN KEY (assignment_id) REFERENCES assignments (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_courses_user_id ON courses(user_id)');
    await db.execute(
      'CREATE INDEX idx_assignments_course_id ON assignments(course_id)',
    );
    await db.execute(
      'CREATE INDEX idx_assignments_due_date ON assignments(due_date)',
    );
    await db.execute('CREATE INDEX idx_grades_course_id ON grades(course_id)');
    await db.execute(
      'CREATE INDEX idx_grades_assignment_id ON grades(assignment_id)',
    );
    await db.execute('CREATE INDEX idx_grades_date ON grades(date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        // Migration for version 2: Make code field nullable in courses table
        print('🔄 Migrating database to version 2: Making code field nullable');

        // SQLite doesn't support ALTER COLUMN, so we need to recreate the table
        await db.execute('PRAGMA foreign_keys = OFF');

        // Create temporary table with new schema
        await db.execute('''
          CREATE TABLE courses_new(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            code TEXT UNIQUE,
            credits INTEGER NOT NULL DEFAULT 3,
            instructor TEXT,
            color TEXT DEFAULT '#2196F3',
            semester TEXT,
            year INTEGER,
            is_active INTEGER DEFAULT 1,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Copy data from old table to new table
        await db.execute('''
          INSERT INTO courses_new 
          SELECT id, user_id, name, code, credits, instructor, color, 
                 semester, year, is_active, is_synced, created_at, updated_at
          FROM courses
        ''');

        // Drop old table
        await db.execute('DROP TABLE courses');

        // Rename new table to original name
        await db.execute('ALTER TABLE courses_new RENAME TO courses');

        // Recreate indexes
        await db.execute(
          'CREATE INDEX idx_courses_user_id ON courses(user_id)',
        );

        await db.execute('PRAGMA foreign_keys = ON');
        print('✅ Database migration to version 2 completed');
        break;
      case 3:
        // Example migration for version 3
        break;
      default:
        throw Exception('Unknown database version: $version');
    }
  }

  // ======================== USER OPERATIONS ========================

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await db.update('users', updates, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // ======================== COURSE OPERATIONS ========================

  Future<String> insertCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return course.id;
  }

  Future<List<Course>> getCourses(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'courses',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Course.fromJson(map)).toList();
  }

  Future<Course?> getCourse(String courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
      limit: 1,
    );
    return result.isNotEmpty ? Course.fromJson(result.first) : null;
  }

  Future<void> updateCourse(Course course) async {
    final db = await database;
    final courseData = course.toJson();
    courseData['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'courses',
      courseData,
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final db = await database;
    // Soft delete - set is_active to 0
    await db.update(
      'courses',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // ======================== ASSIGNMENT OPERATIONS ========================

  Future<String> insertAssignment(Assignment assignment) async {
    final db = await database;
    await db.insert(
      'assignments',
      assignment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return assignment.id;
  }

  Future<List<Assignment>> getAssignments(String courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => Assignment.fromJson(map)).toList();
  }

  Future<List<Assignment>> getUpcomingAssignments(
    String userId, {
    int? limit,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final query =
        '''
      SELECT a.* FROM assignments a
      INNER JOIN courses c ON a.course_id = c.id
      WHERE c.user_id = ? AND a.due_date > ? AND a.status != 'completed'
      ORDER BY a.due_date ASC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';
    final List<Map<String, dynamic>> result = await db.rawQuery(query, [
      userId,
      now,
    ]);
    return result.map((map) => Assignment.fromJson(map)).toList();
  }

  Future<List<Assignment>> getOverdueAssignments(String userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final query = '''
      SELECT a.* FROM assignments a
      INNER JOIN courses c ON a.course_id = c.id
      WHERE c.user_id = ? AND a.due_date < ? AND a.status != 'completed'
      ORDER BY a.due_date DESC
    ''';
    final List<Map<String, dynamic>> result = await db.rawQuery(query, [
      userId,
      now,
    ]);
    return result.map((map) => Assignment.fromJson(map)).toList();
  }

  Future<Assignment?> getAssignment(String assignmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'assignments',
      where: 'id = ?',
      whereArgs: [assignmentId],
      limit: 1,
    );
    return result.isNotEmpty ? Assignment.fromJson(result.first) : null;
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final db = await database;
    final assignmentData = assignment.toJson();
    assignmentData['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'assignments',
      assignmentData,
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
  }

  Future<void> deleteAssignment(String assignmentId) async {
    final db = await database;
    await db.delete('assignments', where: 'id = ?', whereArgs: [assignmentId]);
  }

  // ======================== GRADE OPERATIONS ========================

  Future<String> insertGrade(Grade grade) async {
    final db = await database;
    await db.insert(
      'grades',
      grade.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return grade.id;
  }

  Future<List<Grade>> getGrades(String courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'grades',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'date DESC',
    );
    return result.map((map) => Grade.fromJson(map)).toList();
  }

  Future<Grade?> getGrade(String gradeId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'grades',
      where: 'id = ?',
      whereArgs: [gradeId],
      limit: 1,
    );
    return result.isNotEmpty ? Grade.fromJson(result.first) : null;
  }

  Future<double> getCourseGPA(String courseId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT AVG((grade * 100.0) / max_grade) as gpa FROM grades 
      WHERE course_id = ? AND grade IS NOT NULL
    ''',
      [courseId],
    );
    return result.first['gpa'] as double? ?? 0.0;
  }

  Future<double> getOverallGPA(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT AVG((g.grade * 100.0) / g.max_grade) as gpa FROM grades g
      INNER JOIN courses c ON g.course_id = c.id
      WHERE c.user_id = ? AND g.grade IS NOT NULL
    ''',
      [userId],
    );
    return result.first['gpa'] as double? ?? 0.0;
  }

  Future<void> updateGrade(Grade grade) async {
    final db = await database;
    final gradeData = grade.toJson();
    gradeData['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'grades',
      gradeData,
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<void> deleteGrade(String gradeId) async {
    final db = await database;
    await db.delete('grades', where: 'id = ?', whereArgs: [gradeId]);
  }

  // ======================== ANALYTICS & REPORTING ========================

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    final db = await database;

    // Get course count
    final courseCountResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM courses 
      WHERE user_id = ? AND is_active = 1
    ''',
      [userId],
    );

    // Get pending assignments count
    final pendingAssignmentsResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM assignments a
      INNER JOIN courses c ON a.course_id = c.id
      WHERE c.user_id = ? AND a.status = 'pending'
    ''',
      [userId],
    );

    // Get overdue assignments count
    final now = DateTime.now().toIso8601String();
    final overdueAssignmentsResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM assignments a
      INNER JOIN courses c ON a.course_id = c.id
      WHERE c.user_id = ? AND a.due_date < ? AND a.status != 'completed'
    ''',
      [userId, now],
    );

    // Get overall GPA
    final gpa = await getOverallGPA(userId);

    return {
      'totalCourses': courseCountResult.first['count'] as int,
      'pendingAssignments': pendingAssignmentsResult.first['count'] as int,
      'overdueAssignments': overdueAssignmentsResult.first['count'] as int,
      'overallGPA': gpa,
    };
  }

  // ======================== BACKUP & RESTORE ========================

  Future<Map<String, dynamic>> exportUserData(String userId) async {
    // Get user data
    final user = await getUser(userId);
    if (user == null) throw Exception('User not found');

    // Get all courses
    final courses = await getCourses(userId);

    // Get all assignments for user's courses
    List<Assignment> allAssignments = [];
    List<Grade> allGrades = [];

    for (final course in courses) {
      final assignments = await getAssignments(course.id);
      final grades = await getGrades(course.id);
      allAssignments.addAll(assignments);
      allGrades.addAll(grades);
    }

    return {
      'user': user,
      'courses': courses.map((c) => c.toJson()).toList(),
      'assignments': allAssignments.map((a) => a.toJson()).toList(),
      'grades': allGrades.map((g) => g.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': _currentVersion,
    };
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    final db = await database;

    await db.transaction((txn) async {
      // Import user
      if (data['user'] != null) {
        await txn.insert(
          'users',
          data['user'],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Import courses
      if (data['courses'] != null) {
        for (final courseData in data['courses']) {
          await txn.insert(
            'courses',
            courseData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import assignments
      if (data['assignments'] != null) {
        for (final assignmentData in data['assignments']) {
          await txn.insert(
            'assignments',
            assignmentData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import grades
      if (data['grades'] != null) {
        for (final gradeData in data['grades']) {
          await txn.insert(
            'grades',
            gradeData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<void> clearUserData(String userId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Delete user's grades
      await txn.rawDelete(
        '''
        DELETE FROM grades WHERE course_id IN (
          SELECT id FROM courses WHERE user_id = ?
        )
      ''',
        [userId],
      );

      // Delete user's assignments
      await txn.rawDelete(
        '''
        DELETE FROM assignments WHERE course_id IN (
          SELECT id FROM courses WHERE user_id = ?
        )
      ''',
        [userId],
      );

      // Delete user's courses
      await txn.delete('courses', where: 'user_id = ?', whereArgs: [userId]);

      // Delete user
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });
  }

  // ======================== SYNC OPERATIONS ========================

  Future<List<Map<String, dynamic>>> getUnsyncedData(String userId) async {
    final db = await database;

    List<Map<String, dynamic>> unsyncedItems = [];

    // Get unsynced courses
    final courses = await db.query(
      'courses',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );
    for (final course in courses) {
      unsyncedItems.add({'type': 'course', 'data': course});
    }

    // Get unsynced assignments
    final assignments = await db.rawQuery(
      '''
      SELECT a.* FROM assignments a
      INNER JOIN courses c ON a.course_id = c.id
      WHERE c.user_id = ? AND a.is_synced = 0
    ''',
      [userId],
    );
    for (final assignment in assignments) {
      unsyncedItems.add({'type': 'assignment', 'data': assignment});
    }

    // Get unsynced grades
    final grades = await db.rawQuery(
      '''
      SELECT g.* FROM grades g
      INNER JOIN courses c ON g.course_id = c.id
      WHERE c.user_id = ? AND g.is_synced = 0
    ''',
      [userId],
    );
    for (final grade in grades) {
      unsyncedItems.add({'type': 'grade', 'data': grade});
    }

    return unsyncedItems;
  }

  Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(table, {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ======================== UTILITY METHODS ========================

  Future<int> getDatabaseSize() async {
    final dbPath = join(await getDatabasesPath(), _databaseName);
    final file = File(dbPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<void> optimizeDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }

  Future<Map<String, int>> getTableCounts() async {
    final db = await database;

    final userCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;
    final courseCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM courses'),
        ) ??
        0;
    final assignmentCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM assignments'),
        ) ??
        0;
    final gradeCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM grades'),
        ) ??
        0;

    return {
      'users': userCount,
      'courses': courseCount,
      'assignments': assignmentCount,
      'grades': gradeCount,
    };
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
