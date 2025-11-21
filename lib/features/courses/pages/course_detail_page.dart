import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../models/assessment_model.dart';
import '../controllers/course_controller.dart';
import '../controllers/assessment_controller.dart';
import '../services/grade_calculation_service.dart';
import 'add_course_page.dart';
import 'add_assessment_page.dart';

class CourseDetailPage extends StatelessWidget {
  final CourseModel course;

  const CourseDetailPage({super.key, required this.course});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle_filled;
      case 'completed':
        return Icons.check_circle;
      case 'upcoming':
        return Icons.schedule;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find<CourseController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              controller.selectCourseForEditing(course);
              Get.to(() => const AddCoursePage(isEditing: true));
            },
            tooltip: 'Edit Course',
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: course.isCompleted
                ? null
                : () => _showMarkCompleteConfirmation(context, controller),
            tooltip: 'Mark Course Completed',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header with Course Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Code Badge
                    if (course.code?.isNotEmpty == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          course.code!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Course Name
                    Text(
                      course.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status and Credits Row
                    Row(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(course.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(course.status),
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Credits Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.school,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.credits} Credits',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
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

            // Course Progress Card (if duration is set)
            if (course.startDate != null && course.endDate != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timeline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Course Progress',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (course.progressPercentage ?? 0) / 100,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(course.status),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${course.progressPercentage?.toStringAsFixed(1)}% Complete',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (course.daysRemaining != null &&
                                course.daysRemaining! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${course.daysRemaining} days left',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Duration Info
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateInfo(
                                context,
                                'Start Date',
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(course.startDate!),
                                Icons.play_arrow,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDateInfo(
                                context,
                                'End Date',
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(course.endDate!),
                                Icons.flag,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (course.durationMonths != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration: ${course.durationText}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Description Card (if available)
            if (course.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course.description!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Course Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Course Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        context,
                        'Teacher',
                        course.teacherName,
                        Icons.person,
                        Colors.blue,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        'Classroom',
                        course.classroom,
                        Icons.room,
                        Colors.green,
                      ),
                      if (course.schedule.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          'Schedule',
                          _getCleanSchedule(course.schedule),
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sync Status Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Sync Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        context,
                        'Sync Status',
                        course.isSynced ? 'Synced' : 'Not Synced',
                        course.isSynced ? Icons.check_circle : Icons.cancel,
                        course.isSynced ? Colors.green : Colors.red,
                      ),
                      if (course.lastSyncAt != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          'Last Synced',
                          _formatDateTime(course.lastSyncAt!),
                          Icons.update,
                          Colors.blue,
                        ),
                      ],
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        'Created',
                        _formatDateTime(course.createdAt),
                        Icons.add_circle_outline,
                        Colors.purple,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        'Last Updated',
                        _formatDateTime(course.updatedAt),
                        Icons.history,
                        Colors.indigo,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Assessments Section (Unified - includes quizzes, labs, midterm, etc.)
            _buildAssessmentsSection(context),

            const SizedBox(height: 16),

            // Overall Grade Section (Calculated from all assessments)
            _buildOverallGradeSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showMarkCompleteConfirmation(
    BuildContext context,
    CourseController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Mark Course Completed'),
        content: const Text(
          'Are you sure you want to mark this course as completed? This will set the end date to today and stop reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await controller.markCourseCompleted(course.id);
    if (success) {
      // Close the details page so the caller can refresh and show updated status
      Get.back();
    }
  }

  Widget _buildAssessmentsSection(BuildContext context) {
    final theme = Theme.of(context);
    final assessmentController = Get.put(AssessmentController());

    // Load assessments when building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assessmentController.loadAssessments(course.id);
    });

    return Obx(() {
      final assessments = assessmentController.assessments;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Assessments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (assessmentController.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (assessments.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Assessments Yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add assessments to track grades',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Group by assessment type
                  Column(
                    children: AssessmentType.values.map((type) {
                      final ofType = assessments
                          .where((a) => a.type == type)
                          .toList();
                      if (ofType.isEmpty) return const SizedBox.shrink();

                      return _buildAssessmentTypeGroup(
                        context,
                        type,
                        ofType,
                        assessmentController,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),

                // Add Assessment Button
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AssessmentType.values.map((type) {
                    return OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAssessmentPage(
                              courseId: course.id,
                              preselectedType: type,
                            ),
                          ),
                        );
                        // Refresh assessments if successful
                        if (result == true) {
                          assessmentController.loadAssessments(course.id);
                        }
                      },
                      icon: Text(type.icon),
                      label: Text('Add ${type.displayName}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAssessmentTypeGroup(
    BuildContext context,
    AssessmentType type,
    List<AssessmentModel> assessments,
    AssessmentController controller,
  ) {
    final theme = Theme.of(context);
    final graded = assessments.where((a) => a.isGraded).toList();
    double avgPercentage = 0;
    if (graded.isNotEmpty) {
      avgPercentage =
          graded.map((a) => a.percentage!).reduce((a, b) => a + b) /
          graded.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              type.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${graded.length}/${assessments.length} graded',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (graded.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  'Avg: ${avgPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...assessments.map((assessment) {
          return _buildAssessmentCard(context, assessment, controller);
        }).toList(),
      ],
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    AssessmentModel assessment,
    AssessmentController controller,
  ) {
    final theme = Theme.of(context);
    final isOverdue = assessment.isOverdue;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddAssessmentPage(
                courseId: course.id,
                assessment: assessment,
              ),
            ),
          );
          // Refresh assessments if successful
          if (result == true) {
            controller.loadAssessments(course.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: assessment.isCompleted,
                    onChanged: (value) {
                      controller.toggleCompletion(assessment.id);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: assessment.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (assessment.dueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${DateFormat('MMM dd, HH:mm').format(assessment.dueDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOverdue
                                      ? Colors.red
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isOverdue) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (assessment.isGraded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${assessment.percentage?.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '${assessment.marks}/${assessment.maxMarks}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (assessment.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  assessment.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallGradeSection(BuildContext context) {
    final theme = Theme.of(context);
    final assessmentController = Get.find<AssessmentController>();

    return Obx(() {
      final assessments = assessmentController.assessments;
      final gradedAssessments = assessments.where((a) => a.isGraded).toList();

      if (gradedAssessments.isEmpty) {
        return const SizedBox.shrink();
      }

      final gradeData = GradeCalculationService.calculateCourseGrade(
        assessments,
      );
      final gpa = gradeData['gpa'] as double;
      final letterGrade = gradeData['letterGrade'] as String;
      final percentage = gradeData['percentage'] as double;
      final totalMarks = gradeData['totalMarks'] as double;
      final status = gradeData['status'] as String;
      final completionPercentage =
          GradeCalculationService.getCompletionPercentage(assessments);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Overall Grade',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GPA Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGradeMetric(
                        context,
                        'GPA',
                        gpa.toStringAsFixed(2),
                        Icons.assessment,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      _buildGradeMetric(
                        context,
                        'Grade',
                        letterGrade,
                        Icons.grade,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      _buildGradeMetric(
                        context,
                        'Score',
                        '${totalMarks.toStringAsFixed(1)}/100',
                        Icons.score,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: percentage >= 50
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: percentage >= 50
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 50 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Completion Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assessment Completion',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completionPercentage.toStringAsFixed(0)}% assessment types graded',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Grade Breakdown by Type
                Text(
                  'Grade Breakdown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...AssessmentType.values.map((type) {
                  final breakdown = GradeCalculationService.getTypeBreakdown(
                    assessments,
                    type,
                  );
                  if (breakdown['graded'] == 0) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            type.displayName,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${breakdown['percentage'].toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Weight: ${type.weight}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGradeMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    String label,
    String date,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
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
                // Navigate back to courses page
                // Use Get.back() to pop this detail page
                try {
                  Get.back();
                } catch (e) {
                  // If Get.back() fails, try Navigator.pop
                  if (Navigator.canPop(Get.context!)) {
                    Navigator.pop(Get.context!);
                  }
                }
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
    controller.scheduleController.text = _getCleanSchedule(course.schedule);
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

  // Helper function to clean schedule string by removing DETAILED information
  String _getCleanSchedule(String schedule) {
    if (schedule.contains('|DETAILED:')) {
      return schedule.split('|DETAILED:')[0];
    }
    return schedule;
  }
}
