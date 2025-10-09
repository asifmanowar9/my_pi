import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/course_assignment_model.dart';
import '../../../core/database/database_helper_clean.dart';

class CourseAssignmentController extends GetxController {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();

  // Observable lists
  final RxList<CourseAssignmentModel> assignments =
      <CourseAssignmentModel>[].obs;
  final RxBool isLoading = false.obs;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final gradeController = TextEditingController();
  final maxGradeController = TextEditingController();

  // Form state
  final Rx<DateTime?> _dueDate = Rx<DateTime?>(null);
  DateTime? get dueDate => _dueDate.value;
  set dueDate(DateTime? value) => _dueDate.value = value;

  final RxBool isCompleted = false.obs;
  String? currentCourseId;
  String? editingAssignmentId;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    gradeController.dispose();
    maxGradeController.dispose();
    super.onClose();
  }

  // Load assignments for a specific course
  Future<void> loadAssignments(String courseId) async {
    try {
      isLoading.value = true;
      currentCourseId = courseId;

      final result = await _dbHelper.getCourseAssignments(courseId);
      assignments.value = result
          .map((json) => CourseAssignmentModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load assignments: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new assignment
  Future<bool> addAssignment() async {
    try {
      if (currentCourseId == null) {
        Get.snackbar(
          'Error',
          'No course selected',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (titleController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter assignment title',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final assignment = CourseAssignmentModel(
        id: const Uuid().v4(),
        courseId: currentCourseId!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        dueDate: dueDate,
        isCompleted: isCompleted.value,
        grade: gradeController.text.trim().isNotEmpty
            ? double.tryParse(gradeController.text.trim())
            : null,
        maxGrade: maxGradeController.text.trim().isNotEmpty
            ? double.tryParse(maxGradeController.text.trim())
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Validate
      final errors = assignment.validate();
      if (errors.isNotEmpty) {
        Get.snackbar(
          'Validation Error',
          errors.join('\n'),
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await _dbHelper.insertCourseAssignment(assignment.toJson());
      await loadAssignments(currentCourseId!);

      Get.snackbar(
        'Success',
        'Assignment added successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
      );

      clearForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add assignment: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update existing assignment
  Future<bool> updateAssignment(String id) async {
    try {
      if (currentCourseId == null) {
        Get.snackbar(
          'Error',
          'No course selected',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (titleController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter assignment title',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final assignment = CourseAssignmentModel(
        id: id,
        courseId: currentCourseId!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        dueDate: dueDate,
        isCompleted: isCompleted.value,
        grade: gradeController.text.trim().isNotEmpty
            ? double.tryParse(gradeController.text.trim())
            : null,
        maxGrade: maxGradeController.text.trim().isNotEmpty
            ? double.tryParse(maxGradeController.text.trim())
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Validate
      final errors = assignment.validate();
      if (errors.isNotEmpty) {
        Get.snackbar(
          'Validation Error',
          errors.join('\n'),
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await _dbHelper.updateCourseAssignment(id, assignment.toJson());
      await loadAssignments(currentCourseId!);

      Get.snackbar(
        'Success',
        'Assignment updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
      );

      clearForm();
      editingAssignmentId = null;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update assignment: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Delete assignment
  Future<bool> deleteAssignment(String id) async {
    try {
      await _dbHelper.deleteCourseAssignment(id);
      assignments.removeWhere((assignment) => assignment.id == id);

      Get.snackbar(
        'Success',
        'Assignment deleted successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete assignment: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Toggle completion status
  Future<void> toggleCompletion(CourseAssignmentModel assignment) async {
    try {
      final updated = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
        updatedAt: DateTime.now(),
      );

      await _dbHelper.updateCourseAssignment(assignment.id, updated.toJson());
      await loadAssignments(currentCourseId!);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update assignment: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add grade to completed assignment
  Future<bool> addGrade(
    String assignmentId,
    double grade,
    double maxGrade,
  ) async {
    try {
      final assignment = assignments.firstWhere((a) => a.id == assignmentId);

      if (!assignment.isCompleted) {
        Get.snackbar(
          'Error',
          'Assignment must be completed before adding a grade',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final updated = assignment.copyWith(
        grade: grade,
        maxGrade: maxGrade,
        updatedAt: DateTime.now(),
      );

      // Validate
      final errors = updated.validate();
      if (errors.isNotEmpty) {
        Get.snackbar(
          'Validation Error',
          errors.join('\n'),
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await _dbHelper.updateCourseAssignment(assignmentId, updated.toJson());
      await loadAssignments(currentCourseId!);

      Get.snackbar(
        'Success',
        'Grade added successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add grade: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Select assignment for editing
  void selectAssignmentForEditing(CourseAssignmentModel assignment) {
    editingAssignmentId = assignment.id;
    titleController.text = assignment.title;
    descriptionController.text = assignment.description ?? '';
    dueDate = assignment.dueDate;
    isCompleted.value = assignment.isCompleted;
    gradeController.text = assignment.grade?.toString() ?? '';
    maxGradeController.text = assignment.maxGrade?.toString() ?? '';
  }

  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    gradeController.clear();
    maxGradeController.clear();
    dueDate = null;
    isCompleted.value = false;
    editingAssignmentId = null;
  }

  // Get statistics
  Map<String, dynamic> get statistics {
    final total = assignments.length;
    final completed = assignments.where((a) => a.isCompleted).length;
    final graded = assignments.where((a) => a.hasGrade).length;
    final overdue = assignments.where((a) => a.isOverdue).length;

    double? averageGrade;
    if (graded > 0) {
      final totalGradePercentage = assignments
          .where((a) => a.gradePercentage != null)
          .fold<double>(0, (sum, a) => sum + a.gradePercentage!);
      averageGrade = totalGradePercentage / graded;
    }

    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
      'graded': graded,
      'overdue': overdue,
      'averageGrade': averageGrade,
    };
  }

  // Get completed assignments
  List<CourseAssignmentModel> get completedAssignments =>
      assignments.where((a) => a.isCompleted).toList();

  // Get pending assignments
  List<CourseAssignmentModel> get pendingAssignments =>
      assignments.where((a) => !a.isCompleted).toList();

  // Get graded assignments
  List<CourseAssignmentModel> get gradedAssignments =>
      assignments.where((a) => a.hasGrade).toList();

  // Get overdue assignments
  List<CourseAssignmentModel> get overdueAssignments =>
      assignments.where((a) => a.isOverdue).toList();
}
