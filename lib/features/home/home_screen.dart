import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';
import '../../core/controllers/navigation_controller.dart';
import '../courses/controllers/course_controller.dart';
import '../courses/models/course_model.dart';
import '../courses/pages/course_detail_page.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _WelcomeSection(userName: controller.userName.value),
                  const SizedBox(height: 20),

                  // Stats Cards
                  _StatsSection(
                    activeCourses: controller.activeCourses.value,
                    pendingTasks: controller.pendingTasks.value,
                  ),
                  const SizedBox(height: 20),

                  // Today's Schedule
                  _TodaysScheduleSection(schedule: controller.todaysSchedule),
                  const SizedBox(height: 20),

                  // Upcoming Deadlines
                  _UpcomingDeadlinesSection(
                    deadlines: controller.upcomingDeadlines,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String userName;

  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Welcome Back, $userName!',
        style: AppTextStyles.lightTextTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int activeCourses;
  final int pendingTasks;

  const _StatsSection({
    required this.activeCourses,
    required this.pendingTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.book_outlined,
            title: 'Active Courses',
            value: activeCourses.toString(),
            backgroundColor: const Color(0xFFFFF3E0),
            iconColor: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_outlined,
            title: 'Pending Tasks',
            value: pendingTasks.toString(),
            backgroundColor: const Color(0xFFE8F5E8),
            iconColor: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color backgroundColor;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.black87 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.black54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysScheduleSection extends StatelessWidget {
  final RxList<Map<String, dynamic>> schedule;

  const _TodaysScheduleSection({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Schedule",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (schedule.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No classes scheduled for today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: schedule.map((item) {
                return _ScheduleItem(
                  courseId: item['courseId'] as String? ?? '',
                  time: item['time'] as String,
                  subject: item['subject'] as String,
                  room: item['room'] as String,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String courseId;
  final String time;
  final String subject;
  final String room;

  const _ScheduleItem({
    required this.courseId,
    required this.time,
    required this.subject,
    required this.room,
  });

  Future<void> _navigateToCourseDetail() async {
    if (courseId.isEmpty) return;

    try {
      // Get or create the course controller to find the course
      final courseController = Get.isRegistered<CourseController>()
          ? Get.find<CourseController>()
          : Get.put(CourseController());

      // Wait for courses to load if they haven't yet
      if (courseController.courses.isEmpty && !courseController.isLoading) {
        await courseController.loadCourses();
      }

      // Find the course by ID
      final CourseModel? course = courseController.courses.firstWhereOrNull(
        (c) => c.id == courseId,
      );

      if (course != null) {
        // Navigate to course detail page
        Get.to(() => CourseDetailPage(course: course));
      } else {
        // Course not found, show error
        Get.snackbar(
          'Error',
          'Course not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Error finding course controller or course
      Get.snackbar(
        'Error',
        'Unable to open course details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _navigateToCourseDetail,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingDeadlinesSection extends StatelessWidget {
  final RxList deadlines;

  const _UpcomingDeadlinesSection({required this.deadlines});

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Deadlines',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (deadlines.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No upcoming deadlines',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            }

            // Show up to 10 upcoming deadlines
            final displayCount = deadlines.length > 10 ? 10 : deadlines.length;
            final hasMore = deadlines.length > 10;

            return Column(
              children: [
                ...deadlines.take(displayCount).map((item) {
                  final assignment = item['assignment'];
                  final courseName = item['courseName'] as String;
                  // assignment.dueDate is already a DateTime object, not a String
                  final dueDate = assignment.dueDate;
                  final formattedDate = DateFormat('MMM dd').format(dueDate);

                  // Convert enum to String (e.g., AssignmentPriority.high -> "high")
                  final priorityString = assignment.priority
                      .toString()
                      .split('.')
                      .last;

                  return _DeadlineItem(
                    title: assignment.title,
                    subject: courseName,
                    dueDate: formattedDate,
                    priority: priorityString,
                    priorityColor: _getPriorityColor(priorityString),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Switch to Assignments tab (index 2)
                      final navController = Get.find<NavigationController>();
                      navController.changeTab(2);
                    },
                    child: Text(
                      hasMore
                          ? 'View All ${deadlines.length} Assignments'
                          : 'View All Assignments',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DeadlineItem extends StatelessWidget {
  final String title;
  final String subject;
  final String dueDate;
  final String priority;
  final Color priorityColor;

  const _DeadlineItem({
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dueDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
