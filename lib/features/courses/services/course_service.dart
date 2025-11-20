import 'dart:convert';
import 'package:get/get.dart';

import '../../../core/database/database_helper_clean.dart';
import '../../../shared/services/cloud_database_service.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../models/course_model.dart';

/// CourseService - Comprehensive service for course management in My Pi app
/// Features:
/// 1. Business logic for course management
/// 2. Local database operations using DatabaseHelper
/// 3. Optional cloud backup using CloudDatabaseService
/// 4. Data validation and business rules
/// 5. Search and filter functionality
/// 6. Import/export functionality for course data
/// 7. Statistics calculation for dashboard
/// 8. Conflict resolution for sync operations
class CourseService extends GetxService {
  final DatabaseHelper _databaseHelper = Get.find<DatabaseHelper>();
  CloudDatabaseService? _cloudService;
  AuthController? _authController;

  @override
  void onInit() {
    super.onInit();
    _initializeCloudService();
  }

  void _initializeCloudService() {
    try {
      if (Get.isRegistered<CloudDatabaseService>()) {
        _cloudService = Get.find<CloudDatabaseService>();
      }
    } catch (e) {
      print('Cloud service not available: $e');
    }
  }

  // Helper method to get AuthController safely
  AuthController? get _safeAuthController {
    try {
      if (_authController == null && Get.isRegistered<AuthController>()) {
        _authController = Get.find<AuthController>();
      }
      return _authController;
    } catch (e) {
      return null;
    }
  }

  // Helper method to get current user ID
  String get _currentUserId => _safeAuthController?.user?.uid ?? '';

  // CRUD Operations with DatabaseHelper

  /// Creates a new course in the local database and optionally backs it up to cloud
  Future<String> createCourse(CourseModel course) async {
    try {
      // Validate course data
      final validationErrors = validateCourseData(course);
      if (validationErrors.isNotEmpty) {
        throw Exception('Validation failed: ${validationErrors.join(', ')}');
      }

      // Check business rules
      final isValid = await validateBusinessRules(course);
      if (!isValid) {
        throw Exception('Course name or code already exists');
      }

      final db = await _databaseHelper.database;
      final courseData = course.toJson();
      await db.insert('courses', courseData);

      // Optional cloud backup for authenticated users
      if (_safeAuthController?.isAuthenticated == true &&
          _cloudService != null) {
        try {
          print('☁️ CourseService: Attempting to sync course to cloud');
          print(
            '🔐 User authenticated: ${_safeAuthController?.isAuthenticated}',
          );
          print('🌩️ Cloud service available: ${_cloudService != null}');

          // Use upsert to handle both create and update
          await _cloudService!.upsertCourse(courseData);
          print('✅ Course synced to cloud successfully');

          // Update local record to mark as synced
          await db.update(
            'courses',
            {'is_synced': 1, 'last_sync_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [course.id],
          );
          print('✅ Local course marked as synced');
        } catch (e) {
          print('❌ Cloud backup failed: $e');
          // Continue without cloud backup
        }
      } else {
        print(
          '⚠️ Skipping cloud sync - Auth: ${_safeAuthController?.isAuthenticated}, Cloud: ${_cloudService != null}',
        );
      }

      return course.id;
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  /// Retrieves all courses for the current user
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      final List<Map<String, dynamic>> maps = await db.query(
        'courses',
        where: userId.isNotEmpty ? 'user_id = ?' : null,
        whereArgs: userId.isNotEmpty ? [userId] : null,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => CourseModel.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }

  /// Retrieves a specific course by ID
  Future<CourseModel?> getCourseById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      final List<Map<String, dynamic>> maps = await db.query(
        'courses',
        where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
        whereArgs: userId.isNotEmpty ? [id, userId] : [id],
      );

      if (maps.isNotEmpty) {
        return CourseModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get course: $e');
    }
  }

  /// Updates an existing course
  Future<void> updateCourse(CourseModel course) async {
    try {
      // Validate course data
      final validationErrors = validateCourseData(course);
      if (validationErrors.isNotEmpty) {
        throw Exception('Validation failed: ${validationErrors.join(', ')}');
      }

      // Check business rules
      final isValid = await validateBusinessRules(course, isUpdate: true);
      if (!isValid) {
        throw Exception('Course name or code already exists');
      }

      final db = await _databaseHelper.database;
      final userId = _currentUserId;
      final courseData = course
          .copyWith(updatedAt: DateTime.now(), isSynced: false)
          .toJson();

      await db.update(
        'courses',
        courseData,
        where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
        whereArgs: userId.isNotEmpty ? [course.id, userId] : [course.id],
      );

      // Optional cloud sync for authenticated users
      if (_safeAuthController?.isAuthenticated == true &&
          _cloudService != null) {
        try {
          // Use upsert to handle both create and update
          await _cloudService!.upsertCourse(courseData);
          // Update local record to mark as synced
          await db.update(
            'courses',
            {'is_synced': 1, 'last_sync_at': DateTime.now().toIso8601String()},
            where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
            whereArgs: userId.isNotEmpty ? [course.id, userId] : [course.id],
          );
        } catch (e) {
          print('Cloud backup failed: $e');
          // Continue without cloud backup
        }
      }
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  /// Deletes a course
  Future<void> deleteCourse(String id) async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      await db.delete(
        'courses',
        where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
        whereArgs: userId.isNotEmpty ? [id, userId] : [id],
      );

      // Optional cloud deletion for authenticated users
      if (_safeAuthController?.isAuthenticated == true &&
          _cloudService != null) {
        try {
          await _cloudService!.deleteCourse(id);
        } catch (e) {
          print('Cloud deletion failed: $e');
          // Continue without cloud deletion
        }
      }
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // Search and Filter Functionality

  /// Searches courses by name, teacher, or classroom
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCourses();
      }

      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause =
          '(name LIKE ? OR teacher_name LIKE ? OR classroom LIKE ? OR code LIKE ?)';
      List<dynamic> whereArgs = [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
      ];

      if (userId.isNotEmpty) {
        whereClause = '($whereClause) AND user_id = ?';
        whereArgs.add(userId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'courses',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => CourseModel.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Failed to search courses: $e');
    }
  }

  // Cloud Synchronization Methods

  /// Syncs unsynced local courses to cloud
  /// Set [forceAll] to true to sync all courses regardless of sync status
  Future<void> syncToCloud({bool forceAll = false}) async {
    if (_safeAuthController?.isAuthenticated != true || _cloudService == null) {
      print(
        '⚠️ Sync skipped - Auth: ${_safeAuthController?.isAuthenticated}, Cloud: ${_cloudService != null}',
      );
      return;
    }

    try {
      print('🔄 Starting sync to cloud (forceAll: $forceAll)...');
      final db = await _databaseHelper.database;
      final userId = _currentUserId;
      print('👤 User ID: $userId');

      String? whereClause;
      List<dynamic>? whereArgs;

      if (!forceAll) {
        // Only sync unsynced courses
        whereClause = 'is_synced = ?';
        whereArgs = [0];

        if (userId.isNotEmpty) {
          whereClause = '$whereClause AND user_id = ?';
          whereArgs.add(userId);
        }
      } else {
        // Sync all courses for this user
        if (userId.isNotEmpty) {
          whereClause = 'user_id = ?';
          whereArgs = [userId];
        }
      }

      print(
        '📊 Query: WHERE ${whereClause ?? "ALL"} WITH args: ${whereArgs ?? "NONE"}',
      );

      final List<Map<String, dynamic>> coursesToSync = await db.query(
        'courses',
        where: whereClause,
        whereArgs: whereArgs,
      );

      print('📝 Found ${coursesToSync.length} courses to sync');

      for (final courseData in coursesToSync) {
        try {
          print(
            '⬆️ Syncing course: ${courseData['name']} (${courseData['id']})',
          );
          // Use upsert to update existing or create new
          await _cloudService!.upsertCourse(courseData);

          // Mark as synced
          await db.update(
            'courses',
            {'is_synced': 1, 'last_sync_at': DateTime.now().toIso8601String()},
            where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
            whereArgs: userId.isNotEmpty
                ? [courseData['id'], userId]
                : [courseData['id']],
          );
          print('✅ Course synced and marked: ${courseData['name']}');
        } catch (e) {
          print('❌ Failed to sync course ${courseData['id']}: $e');
        }
      }

      print('🎉 Sync to cloud completed');
    } catch (e) {
      print('❌ Failed to sync courses to cloud: $e');
      throw Exception('Failed to sync courses to cloud: $e');
    }
  }

  /// Forces sync of ALL courses to cloud (useful for fixing sync issues)
  Future<void> forceSyncAllToCloud() async {
    print('🔄 FORCE SYNC: Syncing all courses to cloud...');
    await syncToCloud(forceAll: true);
  }

  /// Syncs courses from cloud to local database
  Future<void> syncFromCloud() async {
    print('\n========== SYNC FROM CLOUD STARTED ==========');
    print('🔐 Auth check: ${_safeAuthController?.isAuthenticated}');
    print('☁️ Cloud service: ${_cloudService != null}');

    if (_safeAuthController?.isAuthenticated != true || _cloudService == null) {
      print(
        '❌ Sync aborted - Auth: ${_safeAuthController?.isAuthenticated}, Cloud: ${_cloudService != null}',
      );
      return;
    }

    try {
      final userId = _currentUserId;
      print('👤 Current user ID: $userId');

      print('📡 Fetching courses from Firestore...');
      final cloudCourses = await _cloudService!.getCloudDataForSync('courses');
      print('📦 Retrieved ${cloudCourses.length} courses from Firestore');

      if (cloudCourses.isEmpty) {
        print('⚠️ No courses found in Firestore for any user');
        print('💡 This could mean:');
        print('   1. You haven\'t added any courses yet');
        print('   2. Courses exist but belong to a different user_id');
        print('   3. Firestore rules are blocking access');
        print('🔍 Current user ID: $userId');
      } else {
        // Log each course to see what data we got
        for (var i = 0; i < cloudCourses.length; i++) {
          final course = cloudCourses[i];
          print('  Course $i:');
          print('    - id: ${course['id']}');
          print('    - name: ${course['name']}');
          print('    - user_id: ${course['user_id']}');
          print('    - matches current user: ${course['user_id'] == userId}');
        }
      }

      final db = await _databaseHelper.database;
      print('💾 Database ready');
      print('📥 Processing ${cloudCourses.length} courses...');

      int downloadedCount = 0;
      for (final courseData in cloudCourses) {
        // Skip courses that don't belong to current user
        if (userId.isNotEmpty && courseData['user_id'] != userId) {
          print(
            '⏭️ Skipping course ${courseData['id']} - belongs to different user',
          );
          continue;
        }

        try {
          // Convert Firestore Timestamp fields to ISO8601 strings for SQLite
          final processedData = _convertFirestoreToSQLite(courseData);

          // Check if course exists locally
          final existing = await db.query(
            'courses',
            where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
            whereArgs: userId.isNotEmpty
                ? [processedData['id'], userId]
                : [processedData['id']],
          );

          if (existing.isEmpty) {
            // Insert new course
            await db.insert('courses', {
              ...processedData,
              'is_synced': 1,
              'last_sync_at': DateTime.now().toIso8601String(),
            });
            downloadedCount++;
            print('✅ Downloaded new course: ${processedData['name']}');
          } else {
            // Update existing course if cloud version is newer
            final localUpdatedAt = DateTime.parse(
              existing.first['updated_at'] as String,
            );

            DateTime cloudUpdatedAt;
            if (courseData['updatedAt'] != null) {
              cloudUpdatedAt = (courseData['updatedAt'] as dynamic).toDate();
            } else if (courseData['updated_at'] != null) {
              cloudUpdatedAt = DateTime.parse(
                courseData['updated_at'] as String,
              );
            } else {
              cloudUpdatedAt = DateTime.now();
            }

            if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
              await db.update(
                'courses',
                {
                  ...processedData,
                  'is_synced': 1,
                  'last_sync_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: [processedData['id']],
              );
              downloadedCount++;
              print('✅ Updated course from cloud: ${processedData['name']}');
            }
          }
        } catch (e) {
          print('❌ Failed to process course ${courseData['id']}: $e');
        }
      }

      print('🎉 Sync from cloud complete: $downloadedCount courses synced');
      print('========== SYNC FROM CLOUD COMPLETED ==========\n');
    } catch (e, stackTrace) {
      print('❌ ERROR in syncFromCloud: $e');
      print('📍 Stack trace: $stackTrace');
      print('========== SYNC FROM CLOUD FAILED ==========\n');
      throw Exception('Failed to sync courses from cloud: $e');
    }
  }

  // Data Validation and Business Rules

  /// Validates course data according to business rules
  List<String> validateCourseData(CourseModel course) {
    final errors = <String>[];

    // Validate course name
    if (course.name.trim().isEmpty) {
      errors.add('Course name is required');
    } else if (course.name.trim().length < 3) {
      errors.add('Course name must be at least 3 characters');
    } else if (course.name.trim().length > 100) {
      errors.add('Course name must not exceed 100 characters');
    }

    // Validate course code if provided
    if (course.code != null && course.code!.isNotEmpty) {
      if (course.code!.length < 2) {
        errors.add('Course code must be at least 2 characters');
      } else if (course.code!.length > 20) {
        errors.add('Course code must not exceed 20 characters');
      }
    }

    // Validate teacher name
    if (course.teacherName.trim().isEmpty) {
      errors.add('Teacher name is required');
    } else if (course.teacherName.trim().length < 2) {
      errors.add('Teacher name must be at least 2 characters');
    } else if (course.teacherName.trim().length > 100) {
      errors.add('Teacher name must not exceed 100 characters');
    }

    // Validate classroom
    if (course.classroom.trim().isEmpty) {
      errors.add('Classroom is required');
    } else if (course.classroom.trim().length > 50) {
      errors.add('Classroom must not exceed 50 characters');
    }

    // Validate credits
    if (course.credits < 1 || course.credits > 10) {
      errors.add('Credits must be between 1 and 10');
    }

    // Validate schedule
    if (course.schedule.trim().isEmpty) {
      errors.add('Schedule is required');
    } else if (course.schedule.length > 200) {
      errors.add('Schedule must not exceed 200 characters');
    }

    // Validate description if provided
    if (course.description != null &&
        course.description!.isNotEmpty &&
        course.description!.length > 500) {
      errors.add('Description must not exceed 500 characters');
    }

    return errors;
  }

  /// Checks if a course name already exists
  Future<bool> courseNameExists(String name, {String? excludeId}) async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause = 'LOWER(name) = ?';
      List<dynamic> whereArgs = [name.toLowerCase()];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      if (userId.isNotEmpty) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      final result = await db.query(
        'courses',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validates business rules for a course
  Future<bool> validateBusinessRules(
    CourseModel course, {
    bool isUpdate = false,
  }) async {
    // Check for duplicate course name
    final nameExists = await courseNameExists(
      course.name,
      excludeId: isUpdate ? course.id : null,
    );
    if (nameExists) return false;

    return true;
  }

  // Import/Export Functionality

  /// Exports all courses to JSON format
  Future<String> exportCoursesToJson() async {
    try {
      final courses = await getAllCourses();
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': _currentUserId,
        'appName': 'My Pi',
        'dataType': 'courses',
        'courses': courses.map((course) => course.toJson()).toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export courses: $e');
    }
  }

  /// Imports courses from JSON data
  Future<List<CourseModel>> importCoursesFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Validate import data structure
      if (!data.containsKey('courses')) {
        throw Exception('Invalid import data: missing courses array');
      }

      final coursesData = data['courses'] as List<dynamic>;
      final importedCourses = <CourseModel>[];
      final errors = <String>[];

      for (final courseData in coursesData) {
        try {
          final course = CourseModel.fromJson(
            courseData as Map<String, dynamic>,
          );

          // Validate course data
          final validationErrors = validateCourseData(course);
          if (validationErrors.isNotEmpty) {
            errors.add(
              'Course "${course.name}": ${validationErrors.join(", ")}',
            );
            continue;
          }

          // Check business rules
          final isValid = await validateBusinessRules(course);
          if (!isValid) {
            errors.add('Course "${course.name}": Name or code already exists');
            continue;
          }

          // Generate new ID for imported course
          final newCourse = course.copyWith(
            id: generateCourseId(),
            userId: _currentUserId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSynced: false,
          );

          await createCourse(newCourse);
          importedCourses.add(newCourse);
        } catch (e) {
          errors.add('Failed to import course: $e');
        }
      }

      if (errors.isNotEmpty) {
        throw Exception('Import completed with errors: ${errors.join("; ")}');
      }

      return importedCourses;
    } catch (e) {
      throw Exception('Failed to import courses: $e');
    }
  }

  // Statistics Calculation for Dashboard

  /// Gets basic course count
  Future<int> getCourseCount() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause = userId.isNotEmpty ? 'user_id = ?' : '';
      List<dynamic> whereArgs = userId.isNotEmpty ? [userId] : [];

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
        whereArgs,
      );

      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get course count: $e');
    }
  }

  /// Gets all unique teachers
  Future<List<String>> getAllTeachers() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause = 'teacher_name IS NOT NULL AND teacher_name != ""';
      List<dynamic> whereArgs = [];

      if (userId.isNotEmpty) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      final result = await db.rawQuery(
        'SELECT DISTINCT teacher_name FROM courses WHERE $whereClause ORDER BY teacher_name',
        whereArgs,
      );

      return result
          .map((row) => row['teacher_name'] as String?)
          .where((teacher) => teacher != null && teacher.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get teachers: $e');
    }
  }

  /// Gets all unique classrooms
  Future<List<String>> getAllClassrooms() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause = 'classroom IS NOT NULL AND classroom != ""';
      List<dynamic> whereArgs = [];

      if (userId.isNotEmpty) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      final result = await db.rawQuery(
        'SELECT DISTINCT classroom FROM courses WHERE $whereClause ORDER BY classroom',
        whereArgs,
      );

      return result
          .map((row) => row['classroom'] as String?)
          .where((classroom) => classroom != null && classroom.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get classrooms: $e');
    }
  }

  /// Gets comprehensive course statistics
  Future<Map<String, int>> getCourseStatistics() async {
    try {
      final totalCourses = await getCourseCount();
      final teachers = await getAllTeachers();
      final classrooms = await getAllClassrooms();

      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      String whereClause = userId.isNotEmpty ? 'user_id = ?' : '';
      List<dynamic> whereArgs = userId.isNotEmpty ? [userId] : [];

      // Get sync statistics
      final syncedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses WHERE is_synced = 1 ${whereClause.isNotEmpty ? "AND $whereClause" : ""}',
        whereClause.isNotEmpty ? whereArgs : [],
      );

      final syncedCount = syncedResult.first['count'] as int;

      return {
        'total': totalCourses,
        'teachers': teachers.length,
        'classrooms': classrooms.length,
        'synced': syncedCount,
        'unsynced': totalCourses - syncedCount,
      };
    } catch (e) {
      throw Exception('Failed to get course statistics: $e');
    }
  }

  // Utility methods

  /// Generates a unique course ID
  String generateCourseId() {
    return 'course_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// Checks if a course exists
  Future<bool> courseExists(String id) async {
    try {
      final course = await getCourseById(id);
      return course != null;
    } catch (e) {
      return false;
    }
  }

  /// Converts Firestore Timestamp fields to ISO8601 strings for SQLite compatibility
  Map<String, dynamic> _convertFirestoreToSQLite(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);

    // Convert Firestore Timestamps to ISO8601 strings
    final timestampFields = [
      'createdAt',
      'updatedAt',
      'created_at',
      'updated_at',
      'startDate',
      'start_date',
      'endDate',
      'end_date',
      'lastSyncAt',
      'last_sync_at',
    ];

    for (final field in timestampFields) {
      if (converted.containsKey(field) && converted[field] != null) {
        try {
          if (converted[field] is String) {
            // Already a string, keep it
            continue;
          }
          // Convert Firestore Timestamp to DateTime to ISO8601 String
          final timestamp = converted[field] as dynamic;
          final dateTime = timestamp.toDate() as DateTime;
          converted[field] = dateTime.toIso8601String();
        } catch (e) {
          print('⚠️ Failed to convert timestamp field $field: $e');
        }
      }
    }

    // Remove Firestore-specific fields that don't exist in SQLite schema
    converted.remove('createdAt');
    converted.remove('updatedAt');
    converted.remove('syncStatus');

    return converted;
  }
}
