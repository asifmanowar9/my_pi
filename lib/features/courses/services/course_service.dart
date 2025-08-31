import '../../../core/database/database_helper_clean.dart';
import '../../../shared/services/cloud_database_service.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../models/course_model.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';

class CourseService {
  static final CourseService _instance = CourseService._internal();
  factory CourseService() => _instance;
  CourseService._internal();

  final DatabaseHelper _localDb = DatabaseHelper();
  final CloudDatabaseService _cloudDb = CloudDatabaseService();
  AuthController? _authController;

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

  // Local CRUD operations

  Future<String> createCourse(CourseModel course) async {
    try {
      final db = await _localDb.database;
      final courseData = course.toJson();

      await db.insert('courses', courseData);

      // Optional cloud backup for authenticated users
      if (_safeAuthController?.isAuthenticated == true) {
        try {
          await _cloudDb.createCourse(courseData);
          // Update local record to mark as synced
          await db.update(
            'courses',
            {'is_synced': 1, 'last_sync_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [course.id],
          );
        } catch (e) {
          print('Cloud backup failed: $e');
          // Continue without cloud backup
        }
      }

      return course.id;
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  Future<List<CourseModel>> getAllCourses() async {
    try {
      final db = await _localDb.database;
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

  Future<CourseModel?> getCourseById(String id) async {
    try {
      final db = await _localDb.database;
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

  Future<void> updateCourse(CourseModel course) async {
    try {
      final db = await _localDb.database;
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

      // Optional cloud backup for authenticated users
      if (_safeAuthController?.isAuthenticated == true) {
        try {
          await _cloudDb.updateCourse(course.id, courseData);
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

  Future<void> deleteCourse(String id) async {
    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      await db.delete(
        'courses',
        where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
        whereArgs: userId.isNotEmpty ? [id, userId] : [id],
      );

      // Optional cloud deletion for authenticated users
      if (_safeAuthController?.isAuthenticated == true) {
        try {
          await _cloudDb.deleteCourse(id);
        } catch (e) {
          print('Cloud deletion failed: $e');
          // Continue without cloud deletion
        }
      }
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // Search and filter operations

  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      String whereClause =
          'name LIKE ? OR teacher_name LIKE ? OR classroom LIKE ?';
      List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%'];

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

  Future<List<CourseModel>> getCoursesByTeacher(String teacherName) async {
    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      String whereClause = 'teacher_name = ?';
      List<dynamic> whereArgs = [teacherName];

      if (userId.isNotEmpty) {
        whereClause = '$whereClause AND user_id = ?';
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
      throw Exception('Failed to get courses by teacher: $e');
    }
  }

  // Cloud synchronization methods

  Future<void> syncToCloud() async {
    if (_safeAuthController?.isAuthenticated != true) return;

    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      String whereClause = 'is_synced = ?';
      List<dynamic> whereArgs = [0];

      if (userId.isNotEmpty) {
        whereClause = '$whereClause AND user_id = ?';
        whereArgs.add(userId);
      }

      final List<Map<String, dynamic>> unsyncedCourses = await db.query(
        'courses',
        where: whereClause,
        whereArgs: whereArgs,
      );

      for (final courseData in unsyncedCourses) {
        try {
          await _cloudDb.createCourse(courseData);
          // Mark as synced
          await db.update(
            'courses',
            {'is_synced': 1, 'last_sync_at': DateTime.now().toIso8601String()},
            where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
            whereArgs: userId.isNotEmpty
                ? [courseData['id'], userId]
                : [courseData['id']],
          );
        } catch (e) {
          print('Failed to sync course ${courseData['id']}: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to sync courses to cloud: $e');
    }
  }

  Future<void> syncFromCloud() async {
    if (_safeAuthController?.isAuthenticated != true) return;

    try {
      final cloudCourses = await _cloudDb.getCloudDataForSync('courses');
      final db = await _localDb.database;
      final userId = _currentUserId;

      for (final courseData in cloudCourses) {
        // Skip courses that don't belong to current user
        if (userId.isNotEmpty && courseData['user_id'] != userId) {
          continue;
        }

        // Check if course exists locally
        final existing = await db.query(
          'courses',
          where: userId.isNotEmpty ? 'id = ? AND user_id = ?' : 'id = ?',
          whereArgs: userId.isNotEmpty
              ? [courseData['id'], userId]
              : [courseData['id']],
        );

        if (existing.isEmpty) {
          // Insert new course
          await db.insert('courses', {
            ...courseData,
            'is_synced': 1,
            'last_sync_at': DateTime.now().toIso8601String(),
          });
        } else {
          // Update existing course if cloud version is newer
          final localUpdatedAt = DateTime.parse(
            existing.first['updated_at'] as String,
          );
          final cloudUpdatedAt = courseData['updatedAt'] != null
              ? (courseData['updatedAt'] as dynamic).toDate()
              : DateTime.now();

          if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
            await db.update(
              'courses',
              {
                ...courseData,
                'is_synced': 1,
                'last_sync_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [courseData['id']],
            );
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to sync courses from cloud: $e');
    }
  }

  // Statistics and analytics

  Future<int> getCourseCount() async {
    try {
      final db = await _localDb.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM courses');
      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get course count: $e');
    }
  }

  Future<List<String>> getAllTeachers() async {
    try {
      final db = await _localDb.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT teacher_name FROM courses WHERE teacher_name IS NOT NULL AND teacher_name != "" ORDER BY teacher_name',
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

  Future<List<String>> getAllClassrooms() async {
    try {
      final db = await _localDb.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT classroom FROM courses WHERE classroom IS NOT NULL AND classroom != "" ORDER BY classroom',
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

  Future<Map<String, int>> getCourseStatistics() async {
    try {
      final totalCourses = await getCourseCount();
      final teachers = await getAllTeachers();
      final classrooms = await getAllClassrooms();

      final db = await _localDb.database;
      final syncedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses WHERE is_synced = 1',
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

  String generateCourseId() {
    return 'course_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  Future<bool> courseExists(String id) async {
    try {
      final course = await getCourseById(id);
      return course != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> courseNameExists(String name, {String? excludeId}) async {
    try {
      final db = await _localDb.database;
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

  // Data validation and business rules

  List<String> validateCourseData(CourseModel course) {
    List<String> errors = [];

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

    // Validate schedule if provided
    if (course.schedule.isNotEmpty && course.schedule.length > 200) {
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

  Future<bool> isValidCourseCode(String code, {String? excludeId}) async {
    if (code.trim().isEmpty) return true; // Code is optional

    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      String whereClause = 'LOWER(code) = ?';
      List<dynamic> whereArgs = [code.toLowerCase()];

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

      return result.isEmpty;
    } catch (e) {
      return false;
    }
  }

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

    // Check for duplicate course code if provided
    if (course.code != null && course.code!.isNotEmpty) {
      final codeValid = await isValidCourseCode(
        course.code!,
        excludeId: isUpdate ? course.id : null,
      );
      if (!codeValid) return false;
    }

    return true;
  }

  // Import/Export functionality

  Future<String> exportCoursesToJson() async {
    try {
      final courses = await getAllCourses();
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': _currentUserId,
        'courses': courses.map((course) => course.toJson()).toList(),
      };
      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export courses: $e');
    }
  }

  Future<File> exportCoursesToFile(String filePath) async {
    try {
      final jsonData = await exportCoursesToJson();
      final file = File(filePath);
      await file.writeAsString(jsonData);
      return file;
    } catch (e) {
      throw Exception('Failed to export courses to file: $e');
    }
  }

  Future<List<CourseModel>> importCoursesFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final coursesData = data['courses'] as List<dynamic>;

      List<CourseModel> importedCourses = [];
      List<String> errors = [];

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

  Future<List<CourseModel>> importCoursesFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonData = await file.readAsString();
      return await importCoursesFromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to import courses from file: $e');
    }
  }

  // Enhanced statistics calculation

  Future<Map<String, dynamic>> getAdvancedCourseStatistics() async {
    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      String whereClause = userId.isNotEmpty ? 'user_id = ?' : '';
      List<dynamic> whereArgs = userId.isNotEmpty ? [userId] : [];

      // Basic counts
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
        whereArgs,
      );
      final totalCourses = totalResult.first['count'] as int;

      // Get unique teachers
      final teachersResult = await db.rawQuery(
        'SELECT DISTINCT teacher_name FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
        whereArgs,
      );
      final teachers = teachersResult
          .map((row) => row['teacher_name'] as String)
          .toList();

      // Get unique classrooms
      final classroomsResult = await db.rawQuery(
        'SELECT DISTINCT classroom FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
        whereArgs,
      );
      final classrooms = classroomsResult
          .map((row) => row['classroom'] as String)
          .toList();

      // Credits distribution
      final creditsResult = await db.rawQuery(
        'SELECT credits, COUNT(*) as count FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""} GROUP BY credits',
        whereArgs,
      );
      Map<int, int> creditsDistribution = {};
      for (final row in creditsResult) {
        creditsDistribution[row['credits'] as int] = row['count'] as int;
      }

      // Total credits
      final totalCreditsResult = await db.rawQuery(
        'SELECT SUM(credits) as total FROM courses ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}',
        whereArgs,
      );
      final totalCredits = totalCreditsResult.first['total'] as int? ?? 0;

      // Sync status
      final syncedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses WHERE is_synced = 1 ${whereClause.isNotEmpty ? "AND $whereClause" : ""}',
        whereClause.isNotEmpty ? whereArgs : [],
      );
      final syncedCount = syncedResult.first['count'] as int;

      // Courses by month (creation date)
      final monthlyResult = await db.rawQuery('''SELECT 
           strftime('%Y-%m', created_at) as month, 
           COUNT(*) as count 
           FROM courses 
           ${whereClause.isNotEmpty ? "WHERE $whereClause" : ""}
           GROUP BY strftime('%Y-%m', created_at) 
           ORDER BY month DESC 
           LIMIT 12''', whereArgs);
      Map<String, int> monthlyDistribution = {};
      for (final row in monthlyResult) {
        monthlyDistribution[row['month'] as String] = row['count'] as int;
      }

      return {
        'totalCourses': totalCourses,
        'totalTeachers': teachers.length,
        'totalClassrooms': classrooms.length,
        'totalCredits': totalCredits,
        'averageCredits': totalCourses > 0
            ? (totalCredits / totalCourses).toStringAsFixed(1)
            : '0.0',
        'syncedCourses': syncedCount,
        'unsyncedCourses': totalCourses - syncedCount,
        'syncPercentage': totalCourses > 0
            ? ((syncedCount / totalCourses) * 100).toStringAsFixed(1)
            : '0.0',
        'creditsDistribution': creditsDistribution,
        'monthlyDistribution': monthlyDistribution,
        'teachers': teachers,
        'classrooms': classrooms,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get advanced course statistics: $e');
    }
  }

  // Conflict resolution for sync operations

  Future<CourseModel?> resolveConflict(
    CourseModel localCourse,
    CourseModel cloudCourse,
  ) async {
    try {
      // Simple conflict resolution: use the most recently updated course
      if (localCourse.updatedAt.isAfter(cloudCourse.updatedAt)) {
        return localCourse;
      } else if (cloudCourse.updatedAt.isAfter(localCourse.updatedAt)) {
        return cloudCourse;
      } else {
        // If same timestamp, prefer local changes
        return localCourse;
      }
    } catch (e) {
      print('Error resolving conflict: $e');
      return localCourse; // Default to local version
    }
  }

  Future<void> syncWithConflictResolution() async {
    if (_safeAuthController?.isAuthenticated != true) return;

    try {
      final db = await _localDb.database;
      final userId = _currentUserId;

      // Get all local courses
      final localCourses = await getAllCourses();

      // Get all cloud courses for user
      final cloudCourses = await _cloudDb.getCloudDataForSync('courses');

      // Create map for easier lookup
      Map<String, dynamic> cloudMap = {
        for (var courseData in cloudCourses.where(
          (c) => c['user_id'] == userId,
        ))
          courseData['id']: courseData,
      };

      List<String> conflicts = [];

      // Process each local course
      for (final localCourse in localCourses) {
        if (cloudMap.containsKey(localCourse.id)) {
          // Conflict: exists in both local and cloud
          final cloudData = cloudMap[localCourse.id];
          final cloudCourse = CourseModel.fromJson(cloudData);

          final resolved = await resolveConflict(localCourse, cloudCourse);
          if (resolved != null) {
            if (resolved.id == localCourse.id) {
              // Use local version - upload to cloud
              await _cloudDb.updateCourse(localCourse.id, localCourse.toJson());
              await db.update(
                'courses',
                {
                  'is_synced': 1,
                  'last_sync_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ? AND user_id = ?',
                whereArgs: [localCourse.id, userId],
              );
            } else {
              // Use cloud version - update local
              await db.update(
                'courses',
                {
                  ...cloudCourse.toJson(),
                  'is_synced': 1,
                  'last_sync_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ? AND user_id = ?',
                whereArgs: [localCourse.id, userId],
              );
            }
          }
          cloudMap.remove(localCourse.id);
        } else {
          // Local only - upload to cloud
          if (!localCourse.isSynced) {
            await _cloudDb.createCourse(localCourse.toJson());
            await db.update(
              'courses',
              {
                'is_synced': 1,
                'last_sync_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ? AND user_id = ?',
              whereArgs: [localCourse.id, userId],
            );
          }
        }
      }

      // Process remaining cloud courses (cloud only)
      for (final cloudData in cloudMap.values) {
        final cloudCourse = CourseModel.fromJson(cloudData);
        await db.insert('courses', {
          ...cloudCourse.toJson(),
          'is_synced': 1,
          'last_sync_at': DateTime.now().toIso8601String(),
        });
      }

      if (conflicts.isNotEmpty) {
        print('Resolved ${conflicts.length} conflicts during sync');
      }
    } catch (e) {
      throw Exception('Failed to sync with conflict resolution: $e');
    }
  }
}
