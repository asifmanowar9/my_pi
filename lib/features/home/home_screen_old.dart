import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const _WelcomeSection(),
              const SizedBox(height: 20),

              // Stats Cards
              const _StatsSection(),
              const SizedBox(height: 20),

              // Today's Schedule
              const _TodaysScheduleSection(),
              const SizedBox(height: 20),

              // Upcoming Deadlines
              const _UpcomingDeadlinesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back!', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  Text(
                    'You have 3 assignments due this week.',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/assignments'),
                    child: const Text('View Assignments'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.school,
                size: 40,
                color: Get.theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  const _QuickStatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Overview', style: AppTextStyles.cardTitle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.book,
                title: 'Courses',
                value: '5',
                color: Get.theme.colorScheme.primary,
                onTap: () => Get.toNamed('/courses'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.assignment,
                title: 'Assignments',
                value: '12',
                color: Get.theme.colorScheme.secondary,
                onTap: () => Get.toNamed('/assignments'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.grade,
                title: 'GPA',
                value: '3.8',
                color: Get.theme.colorScheme.tertiary,
                onTap: () => Get.toNamed('/grades'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                title: 'Progress',
                value: '85%',
                color: Colors.green,
                onTap: () => Get.toNamed('/grades'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
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
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.cardTitle?.copyWith(
                  color: color,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.cardSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivitiesSection extends StatelessWidget {
  const _RecentActivitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activities', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: () {
                // TODO: Navigate to activities
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.grade,
                title: 'Grade Posted',
                subtitle: 'Math 101 - Assignment 3',
                time: '2 hours ago',
                color: Colors.green,
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.assignment_turned_in,
                title: 'Assignment Submitted',
                subtitle: 'Physics 201 - Lab Report',
                time: '1 day ago',
                color: Colors.blue,
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.notification_important,
                title: 'Reminder',
                subtitle: 'Chemistry 301 - Exam next week',
                time: '2 days ago',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: AppTextStyles.cardSubtitle),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Text(time, style: AppTextStyles.caption),
      onTap: () {
        // TODO: Navigate to activity detail
      },
    );
  }
}

class _UpcomingDeadlinesSection extends StatelessWidget {
  const _UpcomingDeadlinesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Deadlines', style: AppTextStyles.cardTitle),
            TextButton(
              onPressed: () => Get.toNamed('/assignments'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _DeadlineItem(
                title: 'Math 101 - Problem Set 5',
                dueDate: 'Due Tomorrow',
                course: 'Mathematics',
                priority: 'High',
                color: Colors.red,
              ),
              const Divider(height: 1),
              _DeadlineItem(
                title: 'Physics 201 - Lab Report',
                dueDate: 'Due in 3 days',
                course: 'Physics',
                priority: 'Medium',
                color: Colors.orange,
              ),
              const Divider(height: 1),
              _DeadlineItem(
                title: 'English 101 - Essay',
                dueDate: 'Due in 1 week',
                course: 'English',
                priority: 'Low',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeadlineItem extends StatelessWidget {
  final String title;
  final String dueDate;
  final String course;
  final String priority;
  final Color color;

  const _DeadlineItem({
    required this.title,
    required this.dueDate,
    required this.course,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(title, style: AppTextStyles.cardSubtitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(dueDate, style: AppTextStyles.dueDate),
        ],
      ),
      trailing: Chip(
        label: Text(
          priority,
          style: AppTextStyles.statusChip.copyWith(fontSize: 10),
        ),
        backgroundColor: color.withOpacity(0.1),
      ),
      onTap: () {
        // TODO: Navigate to assignment detail
      },
    );
  }
}
