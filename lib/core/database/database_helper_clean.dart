import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const int _currentVersion = 6;
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

    if (oldVersion < 3) {
      // Re-run courses table schema upgrade to ensure all columns exist
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
          last_sync_at TEXT
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

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
