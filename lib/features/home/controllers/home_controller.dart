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

      print('=== Loading Statistics ===');
      print('User ID: ${userId.isEmpty ? "EMPTY (loading all data)" : userId}');

      // Get start of today for comparison
      final today = DateTime.now();
      final startOfToday = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      print('Start of today: $startOfToday');

      if (userId.isEmpty) {
        // Load all data if no user
        final coursesResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM courses',
        );
        activeCourses.value = coursesResult.first['count'] as int? ?? 0;
        print('Active courses (all): ${activeCourses.value}');

        // Debug: Check assessments table (this is where the quiz data is!)
        final allAssessments = await db.rawQuery(
          'SELECT id, title, due_date, is_completed FROM assessments',
        );
        print('Total assessments in DB: ${allAssessments.length}');
        for (var a in allAssessments) {
          print(
            '  - ${a['title']}: due=${a['due_date']}, completed=${a['is_completed']}',
          );
        }

        // Also check assignments table (for legacy data)
        final allAssignments = await db.rawQuery(
          'SELECT id, title, due_date, status FROM assignments',
        );
        print('Total assignments in DB: ${allAssignments.length}');
        for (var a in allAssignments) {
          print(
            '  - ${a['title']}: due=${a['due_date']}, status=${a['status']}',
          );
        }

        // Count pending tasks from assessments table (is_completed = 0)
        final assessmentsResult = await db.rawQuery(
          "SELECT COUNT(*) as count FROM assessments WHERE is_completed = 0 AND due_date >= ?",
          [startOfToday],
        );

        // Also count from assignments table
        final assignmentsResult = await db.rawQuery(
          "SELECT COUNT(*) as count FROM assignments WHERE status != 'completed' AND due_date >= ?",
          [startOfToday],
        );

        pendingTasks.value =
            (assessmentsResult.first['count'] as int? ?? 0) +
            (assignmentsResult.first['count'] as int? ?? 0);
        print(
          'Pending tasks from assessments: ${assessmentsResult.first['count']}',
        );
        print(
          'Pending tasks from assignments: ${assignmentsResult.first['count']}',
        );
        print('Total pending tasks: ${pendingTasks.value}');
      } else {
        // Load user-specific data
        final coursesResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM courses WHERE user_id = ?',
          [userId],
        );
        activeCourses.value = coursesResult.first['count'] as int? ?? 0;
        print('Active courses (user): ${activeCourses.value}');

        // Count from assessments table (is_completed = 0)
        final assessmentsResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count FROM assessments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.is_completed = 0 AND a.due_date >= ?
          ''',
          [userId, startOfToday],
        );

        // Also count from assignments table (for legacy data)
        final assignmentsResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.status != 'completed' AND a.due_date >= ?
          ''',
          [userId, startOfToday],
        );

        pendingTasks.value =
            (assessmentsResult.first['count'] as int? ?? 0) +
            (assignmentsResult.first['count'] as int? ?? 0);
        print('Pending tasks (user): ${pendingTasks.value}');
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
      final startOfToday = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      final dayOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][today.weekday - 1];

      print('=== Loading Today\'s Schedule ===');
      print('Day of week: $dayOfWeek');
      print('User ID: ${userId.isEmpty ? "EMPTY" : userId}');

      // Debug: Check all courses
      final allCourses = await db.rawQuery(
        'SELECT id, name, schedule FROM courses',
      );
      print('Total courses in DB: ${allCourses.length}');
      for (var c in allCourses) {
        print('  - ${c['name']}: schedule=${c['schedule']}');
      }

      List<Map<String, dynamic>> result;

      // First, try to get courses that match today's schedule
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

      print('Query result: ${result.length} courses for $dayOfWeek');

      // If no courses found with proper schedule format, show all courses with assessments due today
      if (result.isEmpty) {
        print('No courses found with schedule matching $dayOfWeek');
        print('Checking for courses with assessments due today...');

        if (userId.isEmpty) {
          result = await db.rawQuery(
            '''
            SELECT DISTINCT c.name, c.teacher_name, c.classroom, c.schedule
            FROM courses c
            INNER JOIN assessments a ON c.id = a.course_id
            WHERE DATE(a.due_date) = DATE(?)
            ORDER BY a.due_date
            LIMIT 10
            ''',
            [startOfToday],
          );
        } else {
          result = await db.rawQuery(
            '''
            SELECT DISTINCT c.name, c.teacher_name, c.classroom, c.schedule
            FROM courses c
            INNER JOIN assessments a ON c.id = a.course_id
            WHERE c.user_id = ? AND DATE(a.due_date) = DATE(?)
            ORDER BY a.due_date
            LIMIT 10
            ''',
            [userId, startOfToday],
          );
        }
        print('Found ${result.length} courses with assessments due today');
      }

      // Parse schedule to extract time
      todaysSchedule.value = result.map((course) {
        final schedule = course['schedule'] as String? ?? '';
        final timeMatch = RegExp(
          r'(\d{1,2}:\d{2}\s*[AP]M)',
        ).firstMatch(schedule);
        final time = timeMatch?.group(1) ?? 'TBA';

        print('Parsed: ${course['name']} at $time');

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

      print('Today\'s schedule loaded: ${todaysSchedule.length} classes');
    } catch (e) {
      print('Error loading today\'s schedule: $e');
      todaysSchedule.clear();
    }
  }

  Future<void> loadUpcomingDeadlines() async {
    try {
      final db = await _databaseHelper.database;
      final userId = _currentUserId;

      print('=== Loading Upcoming Deadlines ===');

      // Get start of today to include all assignments due today or later
      final today = DateTime.now();
      final startOfToday = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      print('Start of today: $startOfToday');

      List<Map<String, dynamic>> result;

      if (userId.isEmpty) {
        result = await db.rawQuery(
          '''
          SELECT a.id, a.course_id as courseId, a.title, a.description, 
                 a.due_date as dueDate, a.assignment_type as type, 
                 a.status, a.priority, a.created_at as createdAt, 
                 a.updated_at as updatedAt, a.is_synced as isSynced, 
                 a.last_sync_at as lastSyncAt, c.name as course_name
          FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE a.due_date >= ? AND a.status != 'completed'
          ORDER BY a.due_date ASC
          ''',
          [startOfToday],
        );
      } else {
        result = await db.rawQuery(
          '''
          SELECT a.id, a.course_id as courseId, a.title, a.description, 
                 a.due_date as dueDate, a.assignment_type as type, 
                 a.status, a.priority, a.created_at as createdAt, 
                 a.updated_at as updatedAt, a.is_synced as isSynced, 
                 a.last_sync_at as lastSyncAt, c.name as course_name
          FROM assignments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.due_date >= ? AND a.status != 'completed'
          ORDER BY a.due_date ASC
          ''',
          [userId, startOfToday],
        );
      }

      print(
        'Query returned ${result.length} upcoming deadlines from assignments table',
      );
      for (var r in result) {
        print('  - ${r['title']}: due=${r['dueDate']}, status=${r['status']}');
      }

      // Also check assessments table (this is where the quiz data is!)
      List<Map<String, dynamic>> assessmentsResult;
      if (userId.isEmpty) {
        assessmentsResult = await db.rawQuery('''
          SELECT a.id, a.course_id as courseId, a.title, 
                 COALESCE(a.description, 'No description') as description, 
                 a.due_date as dueDate, a.type as type,
                 CASE WHEN a.is_completed = 1 THEN 'completed' ELSE 'pending' END as status,
                 'medium' as priority,
                 a.created_at as createdAt, a.updated_at as updatedAt,
                 0 as isSynced, null as lastSyncAt, c.name as course_name
          FROM assessments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE a.is_completed = 0 AND a.due_date IS NOT NULL
          ORDER BY a.due_date ASC
          ''');
      } else {
        assessmentsResult = await db.rawQuery(
          '''
          SELECT a.id, a.course_id as courseId, a.title, 
                 COALESCE(a.description, 'No description') as description,
                 a.due_date as dueDate, a.type as type,
                 CASE WHEN a.is_completed = 1 THEN 'completed' ELSE 'pending' END as status,
                 'medium' as priority,
                 a.created_at as createdAt, a.updated_at as updatedAt,
                 0 as isSynced, null as lastSyncAt, c.name as course_name
          FROM assessments a
          INNER JOIN courses c ON a.course_id = c.id
          WHERE c.user_id = ? AND a.is_completed = 0 AND a.due_date IS NOT NULL
          ORDER BY a.due_date ASC
          ''',
          [userId],
        );
      }

      print(
        'Query returned ${assessmentsResult.length} from assessments table',
      );
      for (var a in assessmentsResult) {
        print('  - ${a['title']}: due=${a['dueDate']}, type=${a['type']}');
      }

      // Combine results from both tables
      final allResults = [...result, ...assessmentsResult];

      print('Combined results: ${allResults.length} total items');

      upcomingDeadlines.value = allResults.map((map) {
        try {
          // Store course name separately in the map before creating Assignment
          final courseName = map['course_name'] as String? ?? 'Unknown Course';

          // Create a modified map for Assignment.fromJson that doesn't have course_name
          final assignmentMap = Map<String, dynamic>.from(map);
          assignmentMap.remove('course_name');

          // Convert integer isSynced to boolean (SQLite stores booleans as 0/1)
          if (assignmentMap['isSynced'] is int) {
            assignmentMap['isSynced'] = assignmentMap['isSynced'] == 1;
          }

          print('Parsing assignment: ${assignmentMap['title']}');
          print('  Due date: ${assignmentMap['dueDate']}');
          print('  Type: ${assignmentMap['type']}');

          // Create assignment and add course name as a custom field
          final assignment = Assignment.fromJson(assignmentMap);
          print('  ✅ Successfully parsed: ${assignment.title}');

          // We'll pass course name through the map for display
          return {'assignment': assignment, 'courseName': courseName};
        } catch (e) {
          print('❌ Error parsing assignment ${map['title']}: $e');
          print('   Data: $map');
          rethrow;
        }
      }).toList();

      // Sort by due date
      upcomingDeadlines.sort((a, b) {
        final aDate = (a['assignment'] as Assignment).dueDate;
        final bDate = (b['assignment'] as Assignment).dueDate;
        return aDate.compareTo(bDate);
      });

      print('Total upcoming deadlines loaded: ${upcomingDeadlines.length}');
    } catch (e) {
      print('Error loading upcoming deadlines: $e');
      print('Stack trace: ${StackTrace.current}');
      upcomingDeadlines.clear();
    }
  }

  @override
  Future<void> refresh() async {
    await loadData();
  }
}
