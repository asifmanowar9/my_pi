import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import '../widgets/course_form.dart';
import '../widgets/loading_widget.dart';

class EditCoursePage extends StatelessWidget {
  final CourseModel course;

  const EditCoursePage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();

    // Pre-fill the form with course data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectCourseForEditing(course);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () => controller.syncCourseToCloud(course.id),
            tooltip: 'Sync to Cloud',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isUpdating) {
          return const LoadingWidget(message: 'Updating course...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course info header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Editing Course',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (course.code != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Course Code: ${course.code}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Course form
              CourseForm(controller: controller, isEditing: true),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearForm();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isUpdating
                          ? null
                          : () async {
                              final success = await controller.updateCourse();
                              if (success) {
                                // Schedule navigation after the current frame to avoid snackbar conflicts
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (Get.isRegistered<CourseController>()) {
                                    Get.offAndToNamed('/courses');
                                  }
                                });
                              }
                            },
                      child: controller.isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Course'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Created',
                        _formatDate(course.createdAt),
                        Icons.calendar_today,
                        context,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Last Updated',
                        _formatDate(course.updatedAt),
                        Icons.update,
                        context,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Course ID',
                        course.id,
                        Icons.fingerprint,
                        context,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
