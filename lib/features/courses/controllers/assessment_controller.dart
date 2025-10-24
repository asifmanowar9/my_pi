import 'package:get/get.dart';
import '../models/assessment_model.dart';
import '../../../core/database/database_helper_clean.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/cloud_database_service.dart';
import '../../auth/controllers/auth_controller.dart';

class AssessmentController extends GetxController {
  final _dbHelper = DatabaseHelper();
  final _notificationService = Get.find<NotificationService>();
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
      if (Get.isRegistered<AuthController>()) {
        _authController = Get.find<AuthController>();
      }
    } catch (e) {
      print('Cloud service not available: $e');
    }
  }

  // Helper method to check if user is authenticated
  bool get _isAuthenticated => _authController?.isAuthenticated ?? false;

  // Observable list of assessments
  final RxList<AssessmentModel> assessments = <AssessmentModel>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Load assessments for a specific course
  Future<void> loadAssessments(String courseId) async {
    try {
      isLoading.value = true;
      final data = await _dbHelper.getAssessments(courseId);
      assessments.value = data.map((e) => AssessmentModel.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assessments: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load all assessments from all courses
  Future<void> loadAllAssessments() async {
    try {
      isLoading.value = true;
      final data = await _dbHelper.getAllAssessments();
      assessments.value = data.map((e) => AssessmentModel.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assessments: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load assessments by type
  Future<List<AssessmentModel>> loadAssessmentsByType(
    String courseId,
    AssessmentType type,
  ) async {
    try {
      final data = await _dbHelper.getAssessmentsByType(courseId, type.name);
      return data.map((e) => AssessmentModel.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assessments: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Add new assessment
  Future<bool> addAssessment(AssessmentModel assessment) async {
    try {
      // Save to local database
      await _dbHelper.insertAssessment(assessment.toMap());

      // Optional cloud backup for authenticated users
      if (_isAuthenticated && _cloudService != null) {
        try {
          await _cloudService!.createAssessment(assessment.toMap());
          print('✅ Assessment synced to Firebase: ${assessment.title}');
        } catch (e) {
          print('❌ Failed to sync assessment to Firebase: $e');
          // Continue without cloud backup
        }
      }

      // Schedule reminder if due date and reminder minutes are set
      if (assessment.dueDate != null && assessment.reminderMinutes != null) {
        await _scheduleAssessmentReminder(assessment);
      }

      // Add to list directly without full reload
      assessments.add(assessment);
      assessments.refresh(); // Trigger reactive update

      Get.snackbar(
        'Success',
        '${assessment.type.displayName} added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update assessment
  Future<bool> updateAssessment(AssessmentModel assessment) async {
    try {
      // Update in local database
      await _dbHelper.updateAssessment(assessment.id, assessment.toMap());

      // Optional cloud sync for authenticated users
      if (_isAuthenticated && _cloudService != null) {
        try {
          await _cloudService!.updateAssessment(
            assessment.id,
            assessment.toMap(),
          );
          print('✅ Assessment updated in Firebase: ${assessment.title}');
        } catch (e) {
          print('❌ Failed to sync assessment update to Firebase: $e');
          // Continue without cloud sync
        }
      }

      // Update reminder
      await _notificationService.cancelNotification(assessment.id.hashCode);
      if (assessment.dueDate != null &&
          assessment.reminderMinutes != null &&
          !assessment.isCompleted) {
        await _scheduleAssessmentReminder(assessment);
      }

      // Update in list directly without full reload
      final index = assessments.indexWhere((a) => a.id == assessment.id);
      if (index != -1) {
        assessments[index] = assessment;
        assessments.refresh(); // Trigger reactive update
      } else {
        // If not found in current list, do a full reload
        await loadAssessments(assessment.courseId);
      }

      Get.snackbar(
        'Success',
        '${assessment.type.displayName} updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update marks for assessment
  Future<bool> updateMarks(
    String assessmentId,
    double marks,
    double maxMarks,
  ) async {
    try {
      final assessment = assessments.firstWhere((a) => a.id == assessmentId);
      final updated = assessment.copyWith(
        marks: marks,
        maxMarks: maxMarks,
        updatedAt: DateTime.now(),
      );
      return await updateAssessment(updated);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update marks: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Toggle completion status
  Future<bool> toggleCompletion(String assessmentId) async {
    try {
      final index = assessments.indexWhere((a) => a.id == assessmentId);
      if (index == -1) return false;

      final assessment = assessments[index];
      final updated = assessment.copyWith(
        isCompleted: !assessment.isCompleted,
        updatedAt: DateTime.now(),
      );

      // Update in database
      await _dbHelper.updateAssessment(updated.id, updated.toMap());

      // Update in list directly without reloading
      assessments[index] = updated;
      assessments.refresh(); // Trigger reactive update

      // Cancel notification if completed, reschedule if uncompleted
      await _notificationService.cancelNotification(updated.id.hashCode);
      if (!updated.isCompleted &&
          updated.dueDate != null &&
          updated.reminderMinutes != null) {
        await _scheduleAssessmentReminder(updated);
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Delete assessment
  Future<bool> deleteAssessment(String assessmentId) async {
    try {
      await _notificationService.cancelNotification(assessmentId.hashCode);

      // Delete from local database
      await _dbHelper.deleteAssessment(assessmentId);

      // Optional cloud deletion for authenticated users
      if (_isAuthenticated && _cloudService != null) {
        try {
          await _cloudService!.deleteAssessment(assessmentId);
          print('✅ Assessment deleted from Firebase: $assessmentId');
        } catch (e) {
          print('❌ Failed to delete assessment from Firebase: $e');
          // Continue without cloud deletion
        }
      }

      assessments.removeWhere((a) => a.id == assessmentId);

      Get.snackbar(
        'Success',
        'Assessment deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Schedule reminder notification
  Future<void> _scheduleAssessmentReminder(AssessmentModel assessment) async {
    if (assessment.dueDate == null || assessment.reminderMinutes == null)
      return;

    final reminderTime = assessment.dueDate!.subtract(
      Duration(minutes: assessment.reminderMinutes!),
    );

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: assessment.id.hashCode,
        title:
            '${assessment.type.icon} ${assessment.type.displayName} Reminder',
        body:
            '${assessment.title} is due in ${assessment.reminderMinutes! >= 1440 ? "${(assessment.reminderMinutes! / 1440).round()} day(s)" : "${assessment.reminderMinutes} minutes"}',
        scheduledDate: reminderTime,
      );
    }
  }

  // Get statistics for a course
  Map<String, dynamic> getStatistics(String courseId) {
    final courseAssessments = assessments
        .where((a) => a.courseId == courseId)
        .toList();

    return {
      'total': courseAssessments.length,
      'completed': courseAssessments.where((a) => a.isCompleted).length,
      'graded': courseAssessments.where((a) => a.isGraded).length,
      'upcoming': courseAssessments
          .where(
            (a) =>
                !a.isCompleted &&
                a.dueDate != null &&
                a.dueDate!.isAfter(DateTime.now()),
          )
          .length,
      'overdue': courseAssessments.where((a) => a.isOverdue).length,
      'byType': {
        for (var type in AssessmentType.values)
          type.name: courseAssessments.where((a) => a.type == type).length,
      },
    };
  }

  // Get all assessments with reminders for rescheduling (e.g., after app restart)
  Future<void> rescheduleAllReminders() async {
    try {
      final upcoming = await _dbHelper.getUpcomingAssessments();
      for (final data in upcoming) {
        final assessment = AssessmentModel.fromMap(data);
        if (assessment.dueDate != null && assessment.reminderMinutes != null) {
          await _scheduleAssessmentReminder(assessment);
        }
      }
    } catch (e) {
      print('Error rescheduling reminders: $e');
    }
  }

  // Sync unsynced assessments to Firebase
  Future<void> syncUnsyncedAssessments() async {
    if (!_isAuthenticated || _cloudService == null) {
      print(
        '📍 Cannot sync assessments: User not authenticated or cloud service unavailable',
      );
      return;
    }

    try {
      print('🔄 Starting assessment sync to Firebase...');

      // Get all assessments from local database
      final localAssessments = await _dbHelper.getAllAssessments();
      print('📊 Found ${localAssessments.length} local assessments to sync');

      int syncedCount = 0;
      for (final assessmentData in localAssessments) {
        try {
          await _cloudService!.createAssessment(assessmentData);
          syncedCount++;
          print('✅ Synced assessment: ${assessmentData['title']}');
        } catch (e) {
          print('❌ Failed to sync assessment ${assessmentData['id']}: $e');
        }
      }

      print(
        '🎉 Assessment sync complete: $syncedCount/${localAssessments.length} assessments synced',
      );

      if (syncedCount > 0) {
        Get.snackbar(
          'Sync Complete',
          'Synced $syncedCount assessments to cloud',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Failed to sync assessments to Firebase: $e');
      Get.snackbar(
        'Sync Error',
        'Failed to sync assessments: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
