import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../models/course_assignment_model.dart';
import '../controllers/course_controller.dart';
import '../controllers/course_assignment_controller.dart';
import '../widgets/grade_input_dialog.dart';
import 'add_course_page.dart';
import 'course_assignment_page.dart';

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
                          course.schedule,
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

            // Assignments Section
            _buildAssignmentsSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection(BuildContext context) {
    final theme = Theme.of(context);
    final assignmentController = Get.put(CourseAssignmentController());

    // Load assignments when building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assignmentController.loadAssignments(course.id);
    });

    return Obx(() {
      final assignments = assignmentController.assignments;
      final stats = assignmentController.statistics;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignments Header with Add Button
            Card(
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
                          Icons.assignment,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assignments & Grades',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            Get.to(() => CourseAssignmentPage(course: course));
                          },
                          tooltip: 'Add Assignment',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    if (assignments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Statistics Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatChip(
                            'Total',
                            stats['total'].toString(),
                            Icons.assignment,
                            Colors.blue,
                          ),
                          _buildStatChip(
                            'Completed',
                            stats['completed'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatChip(
                            'Pending',
                            stats['pending'].toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                          if (stats['graded'] > 0)
                            _buildStatChip(
                              'Graded',
                              stats['graded'].toString(),
                              Icons.grade,
                              Colors.purple,
                            ),
                        ],
                      ),

                      if (stats['averageGrade'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                'Average Grade: ${stats['averageGrade'].toStringAsFixed(1)}%',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Assignments List
            if (assignmentController.isLoading.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (assignments.isEmpty)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Assignments Yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first assignment to start tracking',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => CourseAssignmentPage(course: course));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Assignment'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return _buildAssignmentCard(
                    context,
                    assignment,
                    assignmentController,
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    CourseAssignmentModel assignment,
    CourseAssignmentController controller,
  ) {
    final theme = Theme.of(context);
    final isOverdue = assignment.isOverdue;
    final hasGrade = assignment.hasGrade;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
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
        onTap: () {
          Get.to(
            () => CourseAssignmentPage(course: course, assignment: assignment),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Completion checkbox
                  Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (value) {
                      controller.toggleCompletion(assignment);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: assignment.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (assignment.dueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${DateFormat('MMM dd').format(assignment.dueDate!)}',
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
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                  // Grade badge or add grade button
                  if (hasGrade)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${assignment.gradePercentage?.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            assignment.gradeStatus ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (assignment.isCompleted)
                    IconButton(
                      icon: const Icon(Icons.grade),
                      onPressed: () {
                        showGradeInputDialog(assignment);
                      },
                      tooltip: 'Add Grade',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                ],
              ),

              if (assignment.description != null &&
                  assignment.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (hasGrade) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.grade, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${assignment.grade}/${assignment.maxGrade}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
