import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_assignment_model.dart';
import '../controllers/course_assignment_controller.dart';

class GradeInputDialog extends StatelessWidget {
  final CourseAssignmentModel assignment;

  const GradeInputDialog({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final gradeController = TextEditingController(
      text: assignment.grade?.toString() ?? '',
    );
    final maxGradeController = TextEditingController(
      text: assignment.maxGrade?.toString() ?? '',
    );
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.grade, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Add Grade'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assignment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grade Input
            TextField(
              controller: gradeController,
              decoration: InputDecoration(
                labelText: 'Grade Received *',
                hintText: 'Enter grade received',
                prefixIcon: const Icon(Icons.grade),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'The actual grade you received',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Max Grade Input
            TextField(
              controller: maxGradeController,
              decoration: InputDecoration(
                labelText: 'Maximum Grade *',
                hintText: 'Enter maximum possible grade',
                prefixIcon: const Icon(Icons.trending_up),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'The maximum possible grade (e.g., 100)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your percentage and letter grade will be calculated automatically',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () async {
            final gradeText = gradeController.text.trim();
            final maxGradeText = maxGradeController.text.trim();

            if (gradeText.isEmpty || maxGradeText.isEmpty) {
              Get.snackbar(
                'Error',
                'Please enter both grade and maximum grade',
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[900],
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            final grade = double.tryParse(gradeText);
            final maxGrade = double.tryParse(maxGradeText);

            if (grade == null || maxGrade == null) {
              Get.snackbar(
                'Error',
                'Please enter valid numbers',
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[900],
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            final controller = Get.find<CourseAssignmentController>();
            final success = await controller.addGrade(
              assignment.id,
              grade,
              maxGrade,
            );

            if (success) {
              Get.back();
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Save Grade'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}

// Helper function to show the dialog
Future<void> showGradeInputDialog(CourseAssignmentModel assignment) {
  return Get.dialog(
    GradeInputDialog(assignment: assignment),
    barrierDismissible: false,
  );
}
