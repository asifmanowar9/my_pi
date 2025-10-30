import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/themes/app_text_styles.dart';
import '../../courses/controllers/course_controller.dart';
import '../../courses/models/course_model.dart';
import '../../courses/models/course_grade_model.dart';
import '../controllers/transcript_controller.dart';
import '../../../core/database/database_helper_clean.dart' as DatabaseHelperClean;

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({super.key});

  static Future<CourseGradeModel?> getCourseGrade(String courseId) async {
    try {
      final gradeData = await DatabaseHelperClean.DatabaseHelper().getCourseGrade(courseId);
      if (gradeData != null) {
        return CourseGradeModel.fromJson(gradeData);
      }
    } catch (e) {
      print('Error getting grade for course $courseId: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TranscriptController());
    final courseController = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Transcript', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => controller.generateFullTranscript(),
            tooltip: 'Download Full Transcript',
          ),
        ],
      ),
      body: Column(
        children: [
          // Transcript Options Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primaryContainer.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: Get.theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate Academic Reports',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Download individual course reports or complete academic transcripts',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.description,
                    title: 'Full Transcript',
                    subtitle: 'Complete academic record',
                    onTap: () => controller.generateFullTranscript(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.grading,
                    title: 'Completed Only',
                    subtitle: 'Finished courses',
                    onTap: () => controller.generateCompletedTranscript(),
                  ),
                ),
              ],
            ),
          ),

          // Course Selection
          Expanded(
            child: Obx(() {
              final courses = courseController.courses;
              if (courses.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No courses found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add some courses to generate transcripts',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Courses',
                          style: AppTextStyles.cardTitle,
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => controller.selectAll(courses),
                              child: const Text('Select All'),
                            ),
                            TextButton(
                              onPressed: () => controller.clearSelection(),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Obx(() {
                          final isSelected = controller.selectedCourses
                              .contains(course.id.toString());
                          return _CourseSelectionTile(
                            course: course,
                            isSelected: isSelected,
                            onSelectionChanged: (selected) {
                              controller.toggleCourseSelection(
                                course.id.toString(),
                                selected,
                              );
                            },
                          );
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Get.theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Obx(() {
              final selectedCount = controller.selectedCourses.length;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCount > 0
                          ? '$selectedCount course${selectedCount == 1 ? '' : 's'} selected'
                          : 'No courses selected',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedCount > 0
                        ? () => controller.generateSelectedTranscript()
                        : null,
                    icon: const Icon(Icons.download),
                    label: const Text('Generate Report'),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Get.theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseSelectionTile extends StatelessWidget {
  final CourseModel course;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const _CourseSelectionTile({
    required this.course,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onSelectionChanged(value ?? false),
        title: Text(
          course.name,
          style: AppTextStyles.cardSubtitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${course.code ?? 'N/A'} • ${course.teacherName}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusChip(
                  label: course.status.toUpperCase(),
                  color: _getStatusColor(course.status),
                ),
                const SizedBox(width: 8),
                if (course.credits > 0)
                  _StatusChip(
                    label: '${course.credits} Credits',
                    color: Get.theme.colorScheme.secondary,
                  ),
                const Spacer(),
                FutureBuilder<CourseGradeModel?>(
                  future: TranscriptPage.getCourseGrade(course.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final grade = snapshot.data!.totalPercentage;
                      return Text(
                        'Grade: ${grade.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(grade),
                        ),
                      );
                    }
                    return Text(
                      'Grade: N/A',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'upcoming':
        return Colors.orange;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    if (grade >= 60) return Colors.red.shade300;
    return Colors.red;
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}