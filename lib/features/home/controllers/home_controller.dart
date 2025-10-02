import 'package:get/get.dart';
import '../../../core/database/database_helper_clean.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/models/assignment.dart';

class HomeController extends GetxController {
  final DatabaseHelper _databaseHelper = Get.find<DatabaseHelper>();

  // Observable data
  final RxInt activeCourses = 0.obs;
  final RxInt pendingTasks = 0.obs;
  final RxList<Map<String, dynamic>> todaysSchedule =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingDeadlines =
      <Map<String, dynamic>>[].obs;
  final RxString userName = 'Student'.obs;
  final RxBool isLoading = false.obs;

  // Get current user ID
  String get _currentUserId {
    try {
      final authController = Get.find<AuthController>();
      return authController.user?.uid ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadUserInfo(),
        loadStatistics(),
        loadTodaysSchedule(),
        loadUpcomingDeadlines(),
      ]);
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserInfo() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.user;

      if (user != null) {
        // Get name from Firebase user or database
        String name = user.displayName ?? '';

        if (name.isEmpty) {
          // Try to get from database
          final db = await _databaseHelper.database;
          final result = await db.query(
            'users',
            where: 'id = ?',
            whereArgs: [user.uid],
            limit: 1,
          );

          if (result.isNotEmpty) {
            name = result.first['name'] as String? ?? '';
          }
        }

        if (name.isEmpty) {
          name = user.email?.split('@').first ?? 'Student';
        }

        userName.value = name;
      }
    } catch (e) {
      print('Error loading user info: $e');
      userName.value = 'Student';
    }
  }

  Future<void> loadStatistics() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      if (userId.isEmpty) {
        // Load all data if no user
        final coursesResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM courses',
        );
        activeCourses.value = coursesResult.first['count'] as int? ?? 0;

        final assignmentsResult = await db.rawQuery(
          "SELECT COUNT(*) as count FROM assignments WHERE status != 'completed'",
        );
        pendingTasks.value = assignmentsResult.first['count'] as int? ?? 0;
      } else {
        // Load user-specific data
        final coursesResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM courses WHERE user_id = ?',
          [userId],
        );
        activeCourses.value = coursesResult.first['count'] as int? ?? 0;

        final assignmentsResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.status != 'completed'
          ''',
          [userId],
        );
        pendingTasks.value = assignmentsResult.first['count'] as int? ?? 0;
      }
    } catch (e) {
      print('Error loading statistics: $e');
      activeCourses.value = 0;
      pendingTasks.value = 0;
    }
  }

  Future<void> loadTodaysSchedule() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;
      final today = DateTime.now();
      final dayOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][today.weekday - 1];

      List<Map<String, dynamic>> result;

      if (userId.isEmpty) {
        result = await db.rawQuery(
          '''
          SELECT name, teacher_name, classroom, schedule
          FROM courses
          WHERE schedule LIKE ?
          ORDER BY schedule
          LIMIT 10
          ''',
          ['%$dayOfWeek%'],
        );
      } else {
        result = await db.rawQuery(
          '''
          SELECT name, teacher_name, classroom, schedule
          FROM courses
          WHERE user_id = ? AND schedule LIKE ?
          ORDER BY schedule
          LIMIT 10
          ''',
          [userId, '%$dayOfWeek%'],
        );
      }

      // Parse schedule to extract time
      todaysSchedule.value = result.map((course) {
        final schedule = course['schedule'] as String? ?? '';
        final timeMatch = RegExp(
          r'(\d{1,2}:\d{2}\s*[AP]M)',
        ).firstMatch(schedule);
        final time = timeMatch?.group(1) ?? 'TBA';

        return {
          'time': time,
          'subject': course['name'] as String? ?? 'Unknown',
          'room': course['classroom'] as String? ?? 'TBA',
        };
      }).toList();

      // Sort by time
      todaysSchedule.sort((a, b) {
        final timeA = a['time'] as String;
        final timeB = b['time'] as String;
        return timeA.compareTo(timeB);
      });
    } catch (e) {
      print('Error loading today\'s schedule: $e');
      todaysSchedule.clear();
    }
  }

  Future<void> loadUpcomingDeadlines() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;
      final now = DateTime.now().toIso8601String();

      List<Map<String, dynamic>> result;

      if (userId.isEmpty) {
        result = await db.rawQuery(
          '''
          SELECT a.*, c.name as course_name
          FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE a.due_date >= ? AND a.status != 'completed'
          ORDER BY a.due_date ASC
          LIMIT 5
          ''',
          [now],
        );
      } else {
        result = await db.rawQuery(
          '''
          SELECT a.*, c.name as course_name
          FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.due_date >= ? AND a.status != 'completed'
          ORDER BY a.due_date ASC
          LIMIT 5
          ''',
          [userId, now],
        );
      }

      upcomingDeadlines.value = result.map((map) {
        // Store course name separately in the map before creating Assignment
        final courseName = map['course_name'] as String? ?? 'Unknown Course';

        // Create a modified map for Assignment.fromJson that doesn't have course_name
        final assignmentMap = Map<String, dynamic>.from(map);
        assignmentMap.remove('course_name');

        // Create assignment and add course name as a custom field
        final assignment = Assignment.fromJson(assignmentMap);
        // We'll pass course name through the map for display
        return {'assignment': assignment, 'courseName': courseName};
      }).toList();
    } catch (e) {
      print('Error loading upcoming deadlines: $e');
      upcomingDeadlines.clear();
    }
  }

  @override
  Future<void> refresh() async {
    await loadData();
  }
}
