import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const int _currentVersion = 10;
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
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade: v$oldVersion → v$newVersion');
    // Handle database migrations
    if (oldVersion < 1) {
      // Add profile_picture column if it doesn't exist
      try {
        await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
      } catch (e) {
        // Column might already exist, ignore error
        print('Profile picture column might already exist: $e');
      }
    }

    if (oldVersion < 2) {
      // Add missing columns to courses table
      await _addCoursesTableColumns(db);
    }

    if (oldVersion < 3) {
      // Add missing columns to courses table (repeat for safety)
      await _addCoursesTableColumns(db);
    }

    if (oldVersion < 4) {
      // Force complete courses table migration
      await _addCoursesTableColumns(db);
    }

    if (oldVersion < 5) {
      // Add user_id column to courses table
      await _addCoursesTableColumns(db);
    }

    if (oldVersion < 6) {
      // Add code column to courses table
      await _addCoursesTableColumns(db);
    }

    if (oldVersion < 7) {
      // Add course_assignments table for assignment grading system
      await _createCourseAssignmentsTable(db);
    }

    if (oldVersion < 8) {
      // Add schedule notification columns to courses table
      await _addScheduleNotificationColumns(db);
    }

    if (oldVersion < 9) {
      // Add course_grades table for comprehensive grading system
      await _createCourseGradesTable(db);
    }

    if (oldVersion < 10) {
      // Add assessments table for unified assessment management
      await _createAssessmentsTable(db);
    }

    // Always run this at the end to ensure all columns exist
    if (oldVersion < newVersion) {
      await _addCoursesTableColumns(db);
    }
  }

  Future<void> _addCoursesTableColumns(Database db) async {
    print('🔄 Upgrading courses table schema...');

    // Check if courses table exists
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='courses'",
    );

    if (tables.isEmpty) {
      print('📋 Creating courses table...');
      // Create the full courses table if it doesn't exist
      await db.execute('''
        CREATE TABLE courses (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          teacher_name TEXT NOT NULL,
          classroom TEXT NOT NULL,
          schedule TEXT NOT NULL,
          description TEXT,
          color TEXT,
          credits INTEGER NOT NULL DEFAULT 3,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          last_sync_at TEXT,
          start_date TEXT,
          end_date TEXT,
          duration_months INTEGER,
          status TEXT NOT NULL DEFAULT 'active'
        )
      ''');
      print('✅ Courses table created successfully');
      return;
    }

    print('🔄 Upgrading courses table schema...');
    // Get current table info
    final List<Map<String, dynamic>> tableInfo = await db.rawQuery(
      'PRAGMA table_info(courses)',
    );
    final existingColumns = tableInfo
        .map((row) => row['name'] as String)
        .toSet();
    print('🔍 Existing columns: $existingColumns');

    // All required columns for the current model
    final columnsToAdd = {
      'user_id': 'TEXT NOT NULL DEFAULT ""',
      'code': 'TEXT',
      'teacher_name': 'TEXT',
      'classroom': 'TEXT',
      'schedule': 'TEXT',
      'description': 'TEXT',
      'color': 'TEXT',
      'credits': 'INTEGER NOT NULL DEFAULT 3',
      'created_at': 'TEXT NOT NULL',
      'updated_at': 'TEXT NOT NULL',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'last_sync_at': 'TEXT',
      'start_date': 'TEXT',
      'end_date': 'TEXT',
      'duration_months': 'INTEGER',
      'status': 'TEXT NOT NULL DEFAULT "active"',
      'schedule_days': 'TEXT',
      'class_time': 'TEXT',
      'reminder_minutes': 'INTEGER',
    };

    for (final entry in columnsToAdd.entries) {
      final columnName = entry.key;
      final columnDefinition = entry.value;
      if (!existingColumns.contains(columnName)) {
        try {
          await db.execute(
            'ALTER TABLE courses ADD COLUMN $columnName $columnDefinition',
          );
          print('✅ Added column: $columnName');
        } catch (e) {
          print('❌ Failed to add column $columnName: $e');
        }
      } else {
        print('ℹ️ Column $columnName already exists');
      }
    }
    print('✅ Courses table schema upgrade completed');
  }

  Future<void> _createCourseAssignmentsTable(Database db) async {
    print('🔄 Creating course_assignments table...');

    // Check if table already exists
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='course_assignments'",
    );

    if (tables.isNotEmpty) {
      print('ℹ️ course_assignments table already exists');
      return;
    }

    try {
      await db.execute('''
        CREATE TABLE course_assignments (
          id TEXT PRIMARY KEY,
          course_id TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT,
          is_completed INTEGER NOT NULL DEFAULT 0,
          grade REAL,
          max_grade REAL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      print('✅ course_assignments table created successfully');
    } catch (e) {
      print('❌ Failed to create course_assignments table: $e');
    }
  }

  Future<void> _addScheduleNotificationColumns(Database db) async {
    print('🔄 Adding schedule notification columns to courses table...');

    // Get current table info
    final List<Map<String, dynamic>> tableInfo = await db.rawQuery(
      'PRAGMA table_info(courses)',
    );
    final existingColumns = tableInfo
        .map((row) => row['name'] as String)
        .toSet();

    // Columns to add for schedule notifications
    final columnsToAdd = {
      'schedule_days': 'TEXT', // Comma-separated weekday numbers (1-7)
      'class_time': 'TEXT', // Format: "HH:mm" 24-hour
      'reminder_minutes': 'INTEGER', // 10 or 15 minutes before class
    };

    for (final entry in columnsToAdd.entries) {
      final columnName = entry.key;
      final columnDefinition = entry.value;
      if (!existingColumns.contains(columnName)) {
        try {
          await db.execute(
            'ALTER TABLE courses ADD COLUMN $columnName $columnDefinition',
          );
          print('✅ Added $columnName column');
        } catch (e) {
          print('⚠️ Failed to add $columnName column: $e');
        }
      } else {
        print('ℹ️ Column $columnName already exists');
      }
    }

    print('✅ Schedule notification columns added successfully');
  }

  Future<void> _createAssessmentsTable(Database db) async {
    print('🔄 Creating assessments table...');

    // Check if table already exists
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='assessments'",
    );

    if (tables.isNotEmpty) {
      print('ℹ️ assessments table already exists');
      return;
    }

    try {
      await db.execute('''
        CREATE TABLE assessments (
          id TEXT PRIMARY KEY,
          course_id TEXT NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT,
          reminder_minutes INTEGER,
          marks REAL,
          max_marks REAL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      print('✅ assessments table created successfully');
    } catch (e) {
      print('❌ Failed to create assessments table: $e');
    }
  }

  Future<void> _createCourseGradesTable(Database db) async {
    print('🔄 Creating course_grades table...');

    // Check if table already exists
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='course_grades'",
    );

    if (tables.isNotEmpty) {
      print('ℹ️ course_grades table already exists');
      return;
    }

    try {
      await db.execute('''
        CREATE TABLE course_grades (
          id TEXT PRIMARY KEY,
          course_id TEXT NOT NULL,
          quiz_marks TEXT,
          quiz_max_marks TEXT,
          lab_report_mark REAL,
          lab_report_max_mark REAL,
          midterm_mark REAL,
          midterm_max_mark REAL,
          presentation_mark REAL,
          presentation_max_mark REAL,
          final_exam_mark REAL,
          final_exam_max_mark REAL,
          assignment_marks TEXT,
          assignment_max_marks TEXT,
          quiz_weight REAL NOT NULL DEFAULT 10.0,
          lab_report_weight REAL NOT NULL DEFAULT 10.0,
          midterm_weight REAL NOT NULL DEFAULT 25.0,
          presentation_weight REAL NOT NULL DEFAULT 5.0,
          final_exam_weight REAL NOT NULL DEFAULT 35.0,
          assignment_weight REAL NOT NULL DEFAULT 15.0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      print('✅ course_grades table created successfully');
    } catch (e) {
      print('❌ Failed to create course_grades table: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        profile_picture TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_sync_at TEXT
      )
    ''');

    // Create courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT,
        teacher_name TEXT NOT NULL,
        classroom TEXT NOT NULL,
        schedule TEXT NOT NULL,
        description TEXT,
        color TEXT,
        credits INTEGER NOT NULL DEFAULT 3,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_sync_at TEXT,
        start_date TEXT,
        end_date TEXT,
        duration_months INTEGER,
        status TEXT NOT NULL DEFAULT 'active',
        schedule_days TEXT,
        class_time TEXT,
        reminder_minutes INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        assignment_type TEXT NOT NULL,
        due_date TEXT NOT NULL,
        estimated_hours REAL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_sync_at TEXT,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Create grades table
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        assignment_id TEXT,
        assessment_type TEXT NOT NULL,
        title TEXT NOT NULL,
        score REAL,
        max_score REAL NOT NULL,
        percentage REAL,
        letter_grade TEXT,
        date_graded TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 1.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_sync_at TEXT,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE,
        FOREIGN KEY (assignment_id) REFERENCES assignments (id) ON DELETE SET NULL
      )
    ''');

    // Create course_assignments table for course-specific assignments with grades
    await db.execute('''
      CREATE TABLE course_assignments (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        grade REAL,
        max_grade REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Create course_grades table for comprehensive grading system
    await db.execute('''
      CREATE TABLE course_grades (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        quiz_marks TEXT,
        quiz_max_marks TEXT,
        lab_report_mark REAL,
        lab_report_max_mark REAL,
        midterm_mark REAL,
        midterm_max_mark REAL,
        presentation_mark REAL,
        presentation_max_mark REAL,
        final_exam_mark REAL,
        final_exam_max_mark REAL,
        assignment_marks TEXT,
        assignment_max_marks TEXT,
        quiz_weight REAL NOT NULL DEFAULT 10.0,
        lab_report_weight REAL NOT NULL DEFAULT 10.0,
        midterm_weight REAL NOT NULL DEFAULT 25.0,
        presentation_weight REAL NOT NULL DEFAULT 5.0,
        final_exam_weight REAL NOT NULL DEFAULT 35.0,
        assignment_weight REAL NOT NULL DEFAULT 15.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Create assessments table for unified assessment management
    await db.execute('''
      CREATE TABLE assessments (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        reminder_minutes INTEGER,
        marks REAL,
        max_marks REAL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');
  }

  // Query methods for data viewing
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await database;
    return await db.query('courses');
  }

  Future<List<Map<String, dynamic>>> getAllAssignments() async {
    final db = await database;
    return await db.query('assignments');
  }

  Future<List<Map<String, dynamic>>> getAllGrades() async {
    final db = await database;
    return await db.query('grades');
  }

  Future<int> getTableCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return result.first['count'] as int;
  }

  Future<Map<String, int>> getTableCounts() async {
    return {
      'users': await getTableCount('users'),
      'courses': await getTableCount('courses'),
      'assignments': await getTableCount('assignments'),
      'grades': await getTableCount('grades'),
    };
  }

  // Insert or update user data from authentication
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {
    final db = await database;

    // Ensure all required columns exist
    await _ensureUserTableColumns(db);

    final now = DateTime.now().toIso8601String();
    final userDataWithTimestamps = {...userData, 'updated_at': now};

    try {
      // Try to insert first
      await db.insert('users', {
        ...userDataWithTimestamps,
        'created_at': now,
        'is_synced': 0,
      });
      print('✅ User inserted into database: ${userData['email']}');
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        // User already exists, update instead
        await db.update(
          'users',
          userDataWithTimestamps,
          where: 'id = ?',
          whereArgs: [userData['id']],
        );
        print('✅ User updated in database: ${userData['email']}');
      } else {
        print('❌ Error saving user to database: $e');
        rethrow;
      }
    }
  }

  // Ensure all required columns exist in users table (for backward compatibility)
  Future<void> _ensureUserTableColumns(Database db) async {
    try {
      // Check what columns exist in the users table
      final result = await db.rawQuery('PRAGMA table_info(users)');
      final existingColumns = result
          .map((row) => row['name'] as String)
          .toSet();

      // Add missing columns one by one
      if (!existingColumns.contains('profile_picture')) {
        await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
        print('✅ Added profile_picture column to users table');
      }

      if (!existingColumns.contains('is_synced')) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN is_synced INTEGER NOT NULL DEFAULT 0',
        );
        print('✅ Added is_synced column to users table');
      }

      if (!existingColumns.contains('last_sync_at')) {
        await db.execute('ALTER TABLE users ADD COLUMN last_sync_at TEXT');
        print('✅ Added last_sync_at column to users table');
      }

      if (!existingColumns.contains('created_at')) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
        );
        print('✅ Added created_at column to users table');
      }

      if (!existingColumns.contains('updated_at')) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
        );
        print('✅ Added updated_at column to users table');
      }
    } catch (e) {
      print('ℹ️ Database column check error: $e');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Sample data insertion methods for testing
  Future<void> insertSampleUser(String id, String email, String name) async {
    final db = await database;
    await db.insert('users', {
      'id': id,
      'email': email,
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> insertSampleCourse(
    String id,
    String name,
    String teacher,
    String classroom,
    String schedule,
  ) async {
    final db = await database;
    await db.insert('courses', {
      'id': id,
      'name': name,
      'teacher_name': teacher,
      'classroom': classroom,
      'schedule': schedule,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Course Assignments CRUD Methods
  Future<int> insertCourseAssignment(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.insert('course_assignments', assignment);
  }

  Future<List<Map<String, dynamic>>> getCourseAssignments(
    String courseId,
  ) async {
    final db = await database;
    return await db.query(
      'course_assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'due_date ASC, created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getCourseAssignmentById(String id) async {
    final db = await database;
    final result = await db.query(
      'course_assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCourseAssignment(
    String id,
    Map<String, dynamic> assignment,
  ) async {
    final db = await database;
    return await db.update(
      'course_assignments',
      assignment,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourseAssignment(String id) async {
    final db = await database;
    return await db.delete(
      'course_assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourseAssignmentsByCourseId(String courseId) async {
    final db = await database;
    return await db.delete(
      'course_assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCourseAssignments() async {
    final db = await database;
    return await db.query('course_assignments');
  }

  // Course Grades CRUD Methods
  Future<int> insertCourseGrade(Map<String, dynamic> grade) async {
    final db = await database;
    return await db.insert('course_grades', grade);
  }

  Future<Map<String, dynamic>?> getCourseGrade(String courseId) async {
    final db = await database;
    final result = await db.query(
      'course_grades',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getCourseGradeById(String id) async {
    final db = await database;
    final result = await db.query(
      'course_grades',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCourseGrade(String id, Map<String, dynamic> grade) async {
    final db = await database;
    return await db.update(
      'course_grades',
      grade,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourseGrade(String id) async {
    final db = await database;
    return await db.delete('course_grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCourseGradeByCourseId(String courseId) async {
    final db = await database;
    return await db.delete(
      'course_grades',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCourseGrades() async {
    final db = await database;
    return await db.query('course_grades');
  }

  // Calculate overall GPA across all courses
  Future<double> calculateOverallGPA() async {
    final db = await database;
    final grades = await db.rawQuery('''
      SELECT cg.*, c.credits
      FROM course_grades cg
      JOIN courses c ON cg.course_id = c.id
      WHERE c.status = 'active'
    ''');

    if (grades.isEmpty) return 0.0;

    double totalGradePoints = 0;
    int totalCredits = 0;

    for (final gradeData in grades) {
      final credits = gradeData['credits'] as int? ?? 3;

      // Parse grade data to calculate GPA for this course
      final quizMarks =
          (gradeData['quiz_marks'] as String?)
              ?.split(',')
              .map((e) => double.tryParse(e) ?? 0)
              .toList() ??
          [];
      final quizMaxMarks =
          (gradeData['quiz_max_marks'] as String?)
              ?.split(',')
              .map((e) => double.tryParse(e) ?? 0)
              .toList() ??
          [];

      double totalPercentage = 0;
      double totalWeight = 0;

      // Calculate percentage for each component (simplified)
      if (gradeData['midterm_mark'] != null &&
          gradeData['midterm_max_mark'] != null) {
        final midtermPercent =
            (gradeData['midterm_mark'] as double) /
            (gradeData['midterm_max_mark'] as double) *
            100;
        totalPercentage +=
            midtermPercent * ((gradeData['midterm_weight'] as double) / 100);
        totalWeight += gradeData['midterm_weight'] as double;
      }

      if (gradeData['final_exam_mark'] != null &&
          gradeData['final_exam_max_mark'] != null) {
        final finalPercent =
            (gradeData['final_exam_mark'] as double) /
            (gradeData['final_exam_max_mark'] as double) *
            100;
        totalPercentage +=
            finalPercent * ((gradeData['final_exam_weight'] as double) / 100);
        totalWeight += gradeData['final_exam_weight'] as double;
      }

      // Convert percentage to GPA
      double courseGPA = 0.0;
      final percent = totalWeight > 0
          ? (totalPercentage / totalWeight) * 100
          : 0;
      if (percent >= 90)
        courseGPA = 4.0;
      else if (percent >= 85)
        courseGPA = 3.7;
      else if (percent >= 80)
        courseGPA = 3.3;
      else if (percent >= 77)
        courseGPA = 3.0;
      else if (percent >= 73)
        courseGPA = 2.7;
      else if (percent >= 70)
        courseGPA = 2.3;
      else if (percent >= 67)
        courseGPA = 2.0;
      else if (percent >= 63)
        courseGPA = 1.7;
      else if (percent >= 60)
        courseGPA = 1.3;
      else if (percent >= 57)
        courseGPA = 1.0;
      else if (percent >= 50)
        courseGPA = 0.7;

      totalGradePoints += courseGPA * credits;
      totalCredits += credits;
    }

    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }

  // Assessments CRUD Methods
  Future<int> insertAssessment(Map<String, dynamic> assessment) async {
    final db = await database;
    return await db.insert('assessments', assessment);
  }

  Future<List<Map<String, dynamic>>> getAssessments(String courseId) async {
    final db = await database;
    return await db.query(
      'assessments',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'due_date ASC, created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAssessmentsByType(
    String courseId,
    String type,
  ) async {
    final db = await database;
    return await db.query(
      'assessments',
      where: 'course_id = ? AND type = ?',
      whereArgs: [courseId, type],
      orderBy: 'due_date ASC, created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getAssessmentById(String id) async {
    final db = await database;
    final result = await db.query(
      'assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateAssessment(
    String id,
    Map<String, dynamic> assessment,
  ) async {
    final db = await database;
    return await db.update(
      'assessments',
      assessment,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAssessment(String id) async {
    final db = await database;
    return await db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAssessmentsByCourseId(String courseId) async {
    final db = await database;
    return await db.delete(
      'assessments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllAssessments([String? userId]) async {
    final db = await database;

    if (userId != null && userId.isNotEmpty) {
      // Filter assessments by user through their courses
      return await db.rawQuery(
        '''
        SELECT a.* FROM assessments a
        INNER JOIN courses c ON a.course_id = c.id
        WHERE c.user_id = ?
        ORDER BY a.due_date ASC
      ''',
        [userId],
      );
    } else {
      // Fallback for backward compatibility
      return await db.query('assessments', orderBy: 'due_date ASC');
    }
  }

  // Get assessments with upcoming due dates for notifications
  Future<List<Map<String, dynamic>>> getUpcomingAssessments([
    String? userId,
  ]) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    if (userId != null && userId.isNotEmpty) {
      // Filter upcoming assessments by user through their courses
      return await db.rawQuery(
        '''
        SELECT a.* FROM assessments a
        INNER JOIN courses c ON a.course_id = c.id
        WHERE c.user_id = ? AND a.due_date >= ? AND a.is_completed = 0
        ORDER BY a.due_date ASC
        LIMIT 10
      ''',
        [userId, now],
      );
    } else {
      // Fallback for backward compatibility
      return await db.query(
        'assessments',
        where: 'due_date >= ? AND is_completed = 0',
        whereArgs: [now],
        orderBy: 'due_date ASC',
        limit: 10,
      );
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
