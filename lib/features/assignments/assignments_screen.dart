import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/guest_mode_banner.dart';
import '../auth/controllers/auth_controller.dart';
import '../courses/controllers/assessment_controller.dart';
import '../courses/controllers/course_controller.dart';
import '../courses/models/assessment_model.dart';
import '../courses/pages/add_assessment_page.dart';
import 'package:intl/intl.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final assessmentController = Get.put(AssessmentController());
    final courseController = Get.put(CourseController());
    final authController = Get.find<AuthController>();

    // Load all assessments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assessmentController.loadAllAssessments();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Assessments', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => assessmentController.loadAllAssessments(),
          ),
        ],
      ),
      body: Obx(() {
        if (assessmentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final assessments = assessmentController.assessments;
        if (assessments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No assessments yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add assessments from your courses',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Group assessments by course
        final Map<String, List<AssessmentModel>> assessmentsByCourse = {};
        for (var assessment in assessments) {
          if (!assessmentsByCourse.containsKey(assessment.courseId)) {
            assessmentsByCourse[assessment.courseId] = [];
          }
          assessmentsByCourse[assessment.courseId]!.add(assessment);
        }

        return Column(
          children: [
            // Show guest mode banner if not authenticated
            if (!authController.isAuthenticated)
              GuestModeBanner(onLoginTap: () => Get.toNamed('/login')),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await assessmentController.loadAllAssessments();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: assessmentsByCourse.entries.map((entry) {
                    final courseId = entry.key;
                    final courseAssessments = entry.value;
                    final course = courseController.courses.firstWhereOrNull(
                      (c) => c.id == courseId,
                    );

                    return _CourseAssessmentsSection(
                      courseId: courseId,
                      courseName: course?.name ?? 'Unknown Course',
                      assessments: courseAssessments,
                      assessmentController: assessmentController,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CourseAssessmentsSection extends StatelessWidget {
  final String courseId;
  final String courseName;
  final List<AssessmentModel> assessments;
  final AssessmentController assessmentController;

  const _CourseAssessmentsSection({
    required this.courseId,
    required this.courseName,
    required this.assessments,
    required this.assessmentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    courseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${assessments.length} ${assessments.length == 1 ? 'assessment' : 'assessments'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddAssessmentPage(courseId: courseId),
                      ),
                    );
                    if (result == true) {
                      assessmentController.loadAllAssessments();
                    }
                  },
                  tooltip: 'Add Assessment',
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),

          // Assessments List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assessments.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              return _AssessmentTile(
                assessment: assessments[index],
                assessmentController: assessmentController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final AssessmentModel assessment;
  final AssessmentController assessmentController;

  const _AssessmentTile({
    required this.assessment,
    required this.assessmentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = assessment.isOverdue;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Checkbox(
        value: assessment.isCompleted,
        onChanged: (_) {
          assessmentController.toggleCompletion(assessment.id);
        },
      ),
      title: Text(
        '${assessment.type.icon} ${assessment.title}',
        style: theme.textTheme.bodyLarge?.copyWith(
          decoration: assessment.isCompleted
              ? TextDecoration.lineThrough
              : null,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assessment.type.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (assessment.isGraded) ...[
                const SizedBox(width: 8),
                Text(
                  '${assessment.marks?.toStringAsFixed(1)}/${assessment.maxMarks?.toStringAsFixed(0)} (${assessment.percentage?.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (assessment.dueDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.schedule,
                  size: 14,
                  color: isOverdue ? Colors.red : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat(
                    'MMM dd, yyyy - h:mm a',
                  ).format(assessment.dueDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue ? Colors.red : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          if (value == 'edit') {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AddAssessmentPage(
                  courseId: assessment.courseId,
                  assessment: assessment,
                ),
              ),
            );
            if (result == true) {
              assessmentController.loadAllAssessments();
            }
          } else if (value == 'delete') {
            _showDeleteDialog(context);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text(
          'Are you sure you want to delete "${assessment.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await assessmentController.deleteAssessment(assessment.id);
              assessmentController.loadAllAssessments();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
