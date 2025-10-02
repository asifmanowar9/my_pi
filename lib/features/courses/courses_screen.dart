import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/guest_mode_banner.dart';
import '../auth/controllers/auth_controller.dart';
import 'controllers/course_controller.dart';
import 'models/course_model.dart';
import 'pages/add_course_page.dart';
import 'pages/course_detail_page.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize CourseController if not already registered
    final controller = Get.put(CourseController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasCourses) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Get.theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses yet',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first course to get started',
                  style: AppTextStyles.cardSubtitle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Show guest mode banner if not authenticated
            if (!authController.isAuthenticated)
              GuestModeBanner(onLoginTap: () => Get.toNamed('/login')),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadCourses();
                  await controller.loadStatistics();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatisticsSection(controller: controller),
                      const SizedBox(height: 24),
                      _CoursesListSection(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.to(() => const AddCoursePage());
        },
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final CourseController controller;

  const _StatisticsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use actual course count from the filtered courses list
      final totalCourses = controller.courses.length;
      final totalCredits =
          controller.advancedStats['totalCredits']?.toInt() ??
          controller.courses.fold<int>(
            0,
            (sum, course) => sum + course.credits,
          );
      final averageCredits =
          controller.advancedStats['averageCredits'] ??
          (totalCourses > 0 ? totalCredits / totalCourses : 0.0);
      final uniqueTeachers =
          controller.advancedStats['uniqueTeachers']?.toInt() ??
          controller.courses.map((c) => c.teacherName).toSet().length;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text('Course Statistics', style: AppTextStyles.cardTitle),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Total Courses',
                      value: totalCourses.toString(),
                      icon: Icons.school,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      label: 'Total Credits',
                      value: totalCredits.toString(),
                      icon: Icons.grade,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Avg Credits',
                      value: averageCredits.toStringAsFixed(1),
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatItem(
                      label: 'Teachers',
                      value: uniqueTeachers.toString(),
                      icon: Icons.person,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CoursesListSection extends StatelessWidget {
  final CourseController controller;

  const _CoursesListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final courses = controller.filteredCourses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Courses', style: AppTextStyles.cardTitle),
              Text(
                '${courses.length} course${courses.length != 1 ? 's' : ''}',
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseCard(
                  course: courses[index],
                  controller: controller,
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final CourseController controller;

  const _CourseCard({required this.course, required this.controller});

  Color _getCourseColor() {
    if (course.color != null && course.color!.isNotEmpty) {
      try {
        String colorString = course.color!;
        if (colorString.startsWith('#')) {
          colorString = colorString.substring(1);
        }
        if (colorString.length == 6) {
          colorString = 'FF$colorString';
        }
        final colorValue = int.parse(colorString, radix: 16);
        return Color(colorValue);
      } catch (e) {
        return Get.theme.colorScheme.primary;
      }
    }
    return Get.theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final courseColor = _getCourseColor();

    return Card(
      child: InkWell(
        onTap: () {
          Get.to(() => CourseDetailPage(course: course));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: courseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (course.code != null && course.code!.isNotEmpty)
                          Text(
                            course.code!,
                            style: AppTextStyles.courseCode.copyWith(
                              color: courseColor,
                            ),
                          ),
                        Text(
                          course.name,
                          style: AppTextStyles.cardSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () {
                      controller.selectCourseForEditing(course);
                      Get.to(() => const AddCoursePage(isEditing: true));
                    },
                    tooltip: 'Edit Course',
                    style: IconButton.styleFrom(
                      backgroundColor: courseColor.withOpacity(0.1),
                      foregroundColor: courseColor,
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: courseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.credits} CR',
                      style: AppTextStyles.caption.copyWith(
                        color: courseColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.teacherName,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.room_outlined,
                    size: 16,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(course.classroom, style: AppTextStyles.caption),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.schedule,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (course.description != null &&
                  course.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.description!,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
