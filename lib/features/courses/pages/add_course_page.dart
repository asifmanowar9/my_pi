import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../widgets/course_form.dart';

class AddCoursePage extends StatelessWidget {
  final bool isEditing;

  const AddCoursePage({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add New Course'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, controller),
              tooltip: 'Delete Course',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Course Details' : 'Create New Course',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing
                      ? 'Update the course information below'
                      : 'Fill in the details to add a new course to your schedule',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Form section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CourseForm(controller: controller, isEditing: isEditing),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action buttons section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.clearForm();
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed:
                          (controller.isCreating || controller.isUpdating)
                          ? null
                          : () => _saveCourse(controller),
                      icon: (controller.isCreating || controller.isUpdating)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(isEditing ? Icons.update : Icons.save),
                      label: Text(
                        (controller.isCreating || controller.isUpdating)
                            ? (isEditing ? 'Updating...' : 'Saving...')
                            : (isEditing ? 'Update Course' : 'Save Course'),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveCourse(CourseController controller) async {
    if (isEditing) {
      final success = await controller.updateCourse();
      if (success) {
        // Schedule navigation after the current frame to avoid snackbar conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<CourseController>()) {
            Get.offAndToNamed('/courses');
          }
        });
      }
    } else {
      final success = await controller.createCourse();
      if (success) {
        // Schedule navigation after the current frame to avoid snackbar conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<CourseController>()) {
            Get.offAndToNamed('/courses');
          }
        });
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CourseController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await controller.deleteSelectedCourse();
              if (success) {
                Get.back(); // Go back to courses list
                Get.snackbar(
                  'Success',
                  'Course deleted successfully',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                  icon: const Icon(Icons.delete, color: Colors.red),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
