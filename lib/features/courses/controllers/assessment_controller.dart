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
      // Get current user ID for proper data isolation
      final userId = _authController?.user?.uid;
      final data = await _dbHelper.getAllAssessments(userId);
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
      print('🗑️ Deleting assessment: $assessmentId');

      // Cancel notification
      await _notificationService.cancelNotification(assessmentId.hashCode);

      // Delete from local database
      print('🗑️ Deleting assessment from local database');
      await _dbHelper.deleteAssessment(assessmentId);
      print('✅ Assessment deleted from local database');

      // Cloud deletion for authenticated users
      if (_isAuthenticated && _cloudService != null) {
        try {
          print('☁️ Deleting assessment from Firestore: $assessmentId');
          await _cloudService!.deleteAssessment(assessmentId);
          print('✅ Assessment deleted from Firestore');
        } catch (e) {
          print('❌ Failed to delete assessment from Firestore: $e');
          // Continue - local deletion succeeded
        }
      } else {
        print(
          'ℹ️ Skipping cloud deletion (not authenticated or no cloud service)',
        );
      }

      // Remove from in-memory list
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
      // Get current user ID for proper data isolation
      final userId = _authController?.user?.uid;
      final upcoming = await _dbHelper.getUpcomingAssessments(userId);
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

  // Sync FROM cloud - Download assessments from Firestore to local database
  Future<void> syncFromCloud() async {
    if (!_isAuthenticated || _cloudService == null) {
      print(
        '📍 Cannot sync from cloud: User not authenticated or cloud service unavailable',
      );
      return;
    }

    try {
      print('🔄 Syncing assessments FROM cloud...');

      // Get current user ID
      String? currentUserId = _authController?.user?.uid;
      if (currentUserId == null) {
        print('❌ No current user ID available, skipping sync');
        return;
      }

      // Get assessments from cloud
      final cloudAssessments = await _cloudService!.getCloudDataForSync(
        'assessments',
      );
      print('📥 Found ${cloudAssessments.length} assessments in cloud');

      int downloadedCount = 0;
      for (final assessmentData in cloudAssessments) {
        try {
          final assessmentId = assessmentData['id'] as String;

          // Convert Firestore Timestamp fields to ISO8601 strings for SQLite
          final processedData = _convertFirestoreToSQLite(assessmentData);

          // Check if assessment exists locally
          final existingAssessment = await _dbHelper.getAssessmentById(
            assessmentId,
          );

          if (existingAssessment == null) {
            // Insert new assessment from cloud
            await _dbHelper.insertAssessment(processedData);
            downloadedCount++;
            print('✅ Downloaded new assessment: ${processedData['title']}');
          } else {
            // Update existing assessment if cloud version is newer
            final localUpdatedAt = DateTime.parse(
              existingAssessment['updated_at'] as String? ??
                  existingAssessment['createdAt'] as String? ??
                  DateTime.now().toIso8601String(),
            );

            DateTime cloudUpdatedAt;
            if (assessmentData['updatedAt'] != null) {
              cloudUpdatedAt = (assessmentData['updatedAt'] as dynamic)
                  .toDate();
            } else if (assessmentData['updated_at'] != null) {
              cloudUpdatedAt = DateTime.parse(
                assessmentData['updated_at'] as String,
              );
            } else {
              cloudUpdatedAt = DateTime.now();
            }

            if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
              await _dbHelper.updateAssessment(assessmentId, processedData);
              downloadedCount++;
              print(
                '✅ Updated assessment from cloud: ${processedData['title']}',
              );
            }
          }
        } catch (e) {
          print('❌ Failed to process assessment ${assessmentData['id']}: $e');
        }
      }

      print('🎉 Sync from cloud complete: $downloadedCount assessments synced');

      // Reload assessments to update UI
      await loadAssessments(currentUserId);
    } catch (e) {
      print('❌ Failed to sync assessments from cloud: $e');
    }
  }

  // Sync unsynced assessments TO Firebase (upload local changes)
  Future<void> syncUnsyncedAssessments() async {
    if (!_isAuthenticated || _cloudService == null) {
      print(
        '📍 Cannot sync assessments: User not authenticated or cloud service unavailable',
      );
      return;
    }

    try {
      print('🔄 Starting assessment sync TO Firebase...');

      // Get current user ID from AuthController
      String? currentUserId;
      if (_authController?.user?.uid != null) {
        currentUserId = _authController!.user!.uid;
        print('👤 Current user ID: $currentUserId');
      } else {
        print('❌ No current user ID available, skipping sync');
        return;
      }

      // Get only current user's assessments from local database
      final localAssessments = await _dbHelper.getAllAssessments(currentUserId);
      print(
        '📊 Found ${localAssessments.length} local assessments for current user to sync',
      );

      int syncedCount = 0;
      for (final assessmentData in localAssessments) {
        try {
          // Use upsert to update existing or create new
          await _cloudService!.upsertAssessment(assessmentData);
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

  /// Converts Firestore Timestamp fields to ISO8601 strings for SQLite compatibility
  Map<String, dynamic> _convertFirestoreToSQLite(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);

    // Convert Firestore Timestamps to ISO8601 strings
    final timestampFields = [
      'createdAt',
      'updatedAt',
      'created_at',
      'updated_at',
      'dueDate',
      'due_date',
      'completedDate',
      'completed_date',
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
    converted.remove('user_id'); // Assessments don't have user_id in SQLite

    return converted;
  }
}
