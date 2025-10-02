import 'package:get/get.dart';
import '../../../core/database/database_helper_clean.dart';
import '../../../shared/models/assignment.dart';

class AssignmentController extends GetxController {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();

  final RxList<Assignment> _assignments = <Assignment>[].obs;
  final RxBool _isLoading = false.obs;

  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading.value;

  // Statistics
  int get pendingCount =>
      _assignments.where((a) => a.status == AssignmentStatus.pending).length;
  int get inProgressCount =>
      _assignments.where((a) => a.status == AssignmentStatus.inProgress).length;
  int get completedCount =>
      _assignments.where((a) => a.status == AssignmentStatus.completed).length;
  int get overdueCount => _assignments
      .where((a) => a.status == AssignmentStatus.overdue || a.isOverdue())
      .length;

  @override
  void onInit() {
    super.onInit();
    loadAssignments();
  }

  Future<void> loadAssignments() async {
    try {
      _isLoading.value = true;
      final data = await _dbHelper.getAllAssignments();

      _assignments.value = data
          .map((json) {
            try {
              return Assignment(
                id: json['id'] as String? ?? '',
                courseId: json['course_id'] as String? ?? '',
                title: json['title'] as String? ?? 'Untitled Assignment',
                description: json['description'] as String? ?? '',
                dueDate: json['due_date'] != null
                    ? DateTime.parse(json['due_date'] as String)
                    : DateTime.now(),
                type: _parseType(json['type'] as String?),
                status: _parseStatus(json['status'] as String?),
                priority: _parsePriority(json['priority'] as String?),
                createdAt: json['created_at'] != null
                    ? DateTime.parse(json['created_at'] as String)
                    : DateTime.now(),
                updatedAt: json['updated_at'] != null
                    ? DateTime.parse(json['updated_at'] as String)
                    : DateTime.now(),
                isSynced: (json['is_synced'] as int?) == 1,
                lastSyncAt: json['last_sync_at'] != null
                    ? DateTime.parse(json['last_sync_at'] as String)
                    : null,
              );
            } catch (e) {
              print('Error parsing assignment: $e');
              return null;
            }
          })
          .whereType<Assignment>()
          .toList();

      // Update overdue statuses
      _assignments.value = _assignments.map((a) => a.updateStatus()).toList();
    } catch (e) {
      print('Error loading assignments: $e');
      _assignments.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  AssignmentType _parseType(String? type) {
    if (type == null) return AssignmentType.other;
    try {
      return AssignmentType.values.firstWhere(
        (e) => e.name.toLowerCase() == type.toLowerCase(),
        orElse: () => AssignmentType.other,
      );
    } catch (e) {
      return AssignmentType.other;
    }
  }

  AssignmentStatus _parseStatus(String? status) {
    if (status == null) return AssignmentStatus.pending;
    try {
      return AssignmentStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => AssignmentStatus.pending,
      );
    } catch (e) {
      return AssignmentStatus.pending;
    }
  }

  AssignmentPriority _parsePriority(String? priority) {
    if (priority == null) return AssignmentPriority.medium;
    try {
      return AssignmentPriority.values.firstWhere(
        (e) => e.name.toLowerCase() == priority.toLowerCase(),
        orElse: () => AssignmentPriority.medium,
      );
    } catch (e) {
      return AssignmentPriority.medium;
    }
  }

  // Get course code for an assignment
  Future<String> getCourseCode(String courseId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'courses',
        columns: ['code', 'name'],
        where: 'id = ?',
        whereArgs: [courseId],
      );
      if (result.isNotEmpty) {
        return result.first['code'] as String? ??
            result.first['name'] as String? ??
            'Unknown';
      }
    } catch (e) {
      print('Error getting course code: $e');
    }
    return 'Unknown';
  }
}
