import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../controllers/course_controller.dart';
import 'edit_course_page.dart';
import 'add_course_page.dart';

class CourseDetailPage extends StatelessWidget {
  final CourseModel course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => EditCoursePage(course: course));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context, controller);
                  break;
                case 'duplicate':
                  _duplicateCourse(controller);
                  break;
                case 'sync':
                  controller.syncCourseToCloud(course.id);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sync',
                child: ListTile(
                  leading: Icon(Icons.cloud_upload),
                  title: Text('Sync to Cloud'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '${course.credits} Credits',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (course.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        course.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Course details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      'Teacher',
                      course.teacherName,
                      Icons.person,
                    ),
                    _buildDetailRow(
                      context,
                      'Classroom',
                      course.classroom,
                      Icons.room,
                    ),
                    _buildDetailRow(
                      context,
                      'Credits',
                      course.credits.toString(),
                      Icons.school,
                    ),
                    if (course.schedule.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Schedule',
                        course.schedule,
                        Icons.schedule,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metadata',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      'Created',
                      _formatDateTime(course.createdAt),
                      Icons.add_circle_outline,
                    ),
                    _buildDetailRow(
                      context,
                      'Updated',
                      _formatDateTime(course.updatedAt),
                      Icons.update,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CourseController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await controller.deleteCourse(course.id);
              if (success) {
                // Schedule navigation after the current frame to avoid snackbar conflicts
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.isRegistered<CourseController>()) {
                    Get.offAndToNamed('/courses'); // Go to courses page
                  }
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateCourse(CourseController controller) {
    // Set up the form with the course data for duplication
    controller.clearForm();
    controller.nameController.text = '${course.name} (Copy)';
    controller.codeController.text = course.code ?? '';
    controller.teacherController.text = course.teacherName;
    controller.classroomController.text = course.classroom;
    controller.scheduleController.text = course.schedule;
    controller.descriptionController.text = course.description ?? '';
    controller.creditsController.text = course.credits.toString();

    // Navigate to add course page
    Get.to(() => const AddCoursePage());

    Get.snackbar(
      'Course Duplicated',
      'Course data copied. You can now edit and save it.',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      icon: const Icon(Icons.copy, color: Colors.blue),
    );
  }
}
