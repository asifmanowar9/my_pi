import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../models/course_assignment_model.dart';
import '../controllers/course_assignment_controller.dart';

class CourseAssignmentPage extends StatelessWidget {
  final CourseModel course;
  final CourseAssignmentModel? assignment; // For editing

  const CourseAssignmentPage({
    super.key,
    required this.course,
    this.assignment,
  });

  bool get isEditing => assignment != null;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourseAssignmentController());
    final theme = Theme.of(context);

    // Initialize form if editing
    if (isEditing && assignment != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectAssignmentForEditing(assignment!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearForm();
        controller.currentCourseId = course.id;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'Add Assignment'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              Text(
                                course.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Assignment Form
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    TextField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter assignment title',
                        prefixIcon: const Icon(Icons.assignment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    TextField(
                      controller: controller.descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter assignment description',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Due Date Field
                    Obx(
                      () => InkWell(
                        onTap: () => _selectDueDate(context, controller),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Due Date',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.dueDate != null
                                          ? DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(controller.dueDate!)
                                          : 'Select due date',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.dueDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => controller.dueDate = null,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Completion Status
                    Obx(
                      () => SwitchListTile(
                        title: const Text('Mark as Completed'),
                        subtitle: Text(
                          controller.isCompleted.value
                              ? 'Assignment is completed'
                              : 'Assignment is pending',
                        ),
                        value: controller.isCompleted.value,
                        onChanged: (value) =>
                            controller.isCompleted.value = value,
                        secondary: Icon(
                          controller.isCompleted.value
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: controller.isCompleted.value
                              ? Colors.green
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grade Section (only if completed)
                    Obx(
                      () => AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: controller.isCompleted.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Grade Information',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.gradeController,
                                          decoration: InputDecoration(
                                            labelText: 'Grade Received',
                                            hintText: '0',
                                            prefixIcon: const Icon(Icons.grade),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.maxGradeController,
                                          decoration: InputDecoration(
                                            labelText: 'Max Grade',
                                            hintText: '100',
                                            prefixIcon: const Icon(
                                              Icons.trending_up,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Enter both grade received and maximum grade to calculate percentage',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.blue[700],
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool success;
                  if (isEditing) {
                    success = await controller.updateAssignment(assignment!.id);
                  } else {
                    success = await controller.addAssignment();
                  }

                  if (success) {
                    Get.back();
                  }
                },
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                  isEditing ? 'Update Assignment' : 'Add Assignment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(
    BuildContext context,
    CourseAssignmentController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.dueDate = picked;
    }
  }
}
