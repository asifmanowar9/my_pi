import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import 'add_course_page.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  // Static state for expanded/collapsed completed section
  static final RxBool _isCompletedExpanded = true.obs;

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.put(CourseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sync_to_cloud':
                  controller.syncToCloud();
                  break;
                case 'force_sync_all':
                  controller.forceSyncAllToCloud();
                  break;
                case 'sync_from_cloud':
                  controller.syncFromCloud();
                  break;
                case 'sync_settings':
                  _showSyncSettings(context, controller);
                  break;
                case 'statistics':
                  _showStatistics(context, controller);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync_to_cloud',
                child: ListTile(
                  leading: Icon(Icons.cloud_upload),
                  title: Text('Sync to Cloud'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'force_sync_all',
                child: ListTile(
                  leading: Icon(Icons.sync, color: Colors.orange),
                  title: Text('Force Sync All'),
                  subtitle: Text(
                    'Sync all courses',
                    style: TextStyle(fontSize: 11),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sync_from_cloud',
                child: ListTile(
                  leading: Icon(Icons.cloud_download),
                  title: Text('Sync from Cloud'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'debug_firestore',
                child: ListTile(
                  leading: Icon(Icons.bug_report, color: Colors.red),
                  title: Text('Debug & Cleanup Firestore'),
                  subtitle: Text(
                    'Remove duplicates',
                    style: TextStyle(fontSize: 11),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sync_settings',
                child: ListTile(
                  leading: Icon(Icons.sync_alt),
                  title: Text('Auto-Sync Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Statistics'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter status
          Obx(() {
            if (controller.isFilterActive) {
              return Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceVariant,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFilterDescription(controller),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Course list with sections
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const LoadingWidget(message: 'Loading courses...');
              }

              if (controller.filteredCourses.isEmpty &&
                  controller.courses.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.school,
                  title: 'No Courses Yet',
                  message: 'Start by adding your first course',
                  actionText: 'Add Course',
                  onActionPressed: () => Get.to(() => const AddCoursePage()),
                );
              }

              if (controller.filteredCourses.isEmpty &&
                  controller.courses.isNotEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off,
                  title: 'No Results Found',
                  message: 'Try adjusting your search or filters',
                  actionText: 'Clear Filters',
                  onActionPressed: () => controller.clearFilters(),
                );
              }

              // Separate courses by status
              final activeCourses = controller.filteredCourses
                  .where((course) => !course.isCompleted)
                  .toList();
              final completedCourses = controller.filteredCourses
                  .where((course) => course.isCompleted)
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.syncFromCloud();
                  await controller.loadCourses();
                },
                child: CustomScrollView(
                  slivers: [
                    // Active Courses Section
                    if (activeCourses.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Active Courses (${activeCourses.length})',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final course = activeCourses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CourseCard(
                                course: course,
                                onTap: () => Get.to(
                                  () => CourseDetailPage(course: course),
                                ),
                                onEdit: () {
                                  controller.selectCourseForEditing(course);
                                  Get.to(
                                    () => const AddCoursePage(isEditing: true),
                                  );
                                },
                                onDelete: () =>
                                    controller.deleteCourse(course.id),
                              ),
                            );
                          }, childCount: activeCourses.length),
                        ),
                      ),
                    ],

                    // Completed Courses Section
                    if (completedCourses.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _buildCompletedSectionHeader(
                            context,
                            completedCourses.length,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: _buildCompletedCoursesSection(
                          completedCourses,
                          controller,
                        ),
                      ),
                    ],

                    // Add some bottom padding
                    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.to(() => const AddCoursePage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, CourseController controller) {
    final searchController = TextEditingController(
      text: controller.searchQuery,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Courses'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name, teacher, classroom...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            controller.setSearchQuery(value);
            Get.back();
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.setSearchQuery(searchController.text);
              Get.back();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, CourseController controller) {
    String selectedTeacher = controller.selectedTeacher;
    String selectedClassroom = controller.selectedClassroom;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Courses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Teacher filter
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedTeacher.isEmpty ? null : selectedTeacher,
                decoration: const InputDecoration(
                  labelText: 'Teacher',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All Teachers'),
                  ),
                  ...controller.teachers.map(
                    (teacher) =>
                        DropdownMenuItem(value: teacher, child: Text(teacher)),
                  ),
                ],
                onChanged: (value) => selectedTeacher = value ?? '',
              ),
            ),
            const SizedBox(height: 16),
            // Classroom filter
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedClassroom.isEmpty ? null : selectedClassroom,
                decoration: const InputDecoration(
                  labelText: 'Classroom',
                  prefixIcon: Icon(Icons.room),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All Classrooms'),
                  ),
                  ...controller.classrooms.map(
                    (classroom) => DropdownMenuItem(
                      value: classroom,
                      child: Text(classroom),
                    ),
                  ),
                ],
                onChanged: (value) => selectedClassroom = value ?? '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.setTeacherFilter(selectedTeacher);
              controller.setClassroomFilter(selectedClassroom);
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSyncSettings(BuildContext context, CourseController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Sync Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => SwitchListTile(
                title: const Text('Enable Auto-Sync'),
                subtitle: const Text(
                  'Sync to cloud once per day automatically',
                ),
                value: controller.autoSyncEnabled,
                onChanged: (value) => controller.toggleAutoSync(value),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sync Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.getSyncStatusMessage(),
                style: TextStyle(
                  color: controller.needsSync() ? Colors.orange : Colors.green,
                ),
              ),
            ),
            if (controller.needsSync()) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.syncToCloud();
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context, CourseController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Course Statistics'),
        content: Obx(() {
          final stats = controller.statistics;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Courses', stats['total']?.toString() ?? '0'),
              _buildStatRow('Teachers', stats['teachers']?.toString() ?? '0'),
              _buildStatRow(
                'Classrooms',
                stats['classrooms']?.toString() ?? '0',
              ),
              _buildStatRow('Synced', stats['synced']?.toString() ?? '0'),
              _buildStatRow('Unsynced', stats['unsynced']?.toString() ?? '0'),
            ],
          );
        }),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getFilterDescription(CourseController controller) {
    final filters = <String>[];

    if (controller.searchQuery.isNotEmpty) {
      filters.add('Search: "${controller.searchQuery}"');
    }

    if (controller.selectedTeacher.isNotEmpty) {
      filters.add('Teacher: ${controller.selectedTeacher}');
    }

    if (controller.selectedClassroom.isNotEmpty) {
      filters.add('Classroom: ${controller.selectedClassroom}');
    }

    return filters.join(' • ');
  }

  Widget _buildCompletedSectionHeader(BuildContext context, int count) {
    return Obx(
      () => InkWell(
        onTap: () => _isCompletedExpanded.toggle(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Completed Courses ($count)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const Spacer(),
              Icon(
                _isCompletedExpanded.value
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.blue.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedCoursesSection(
    List<dynamic> completedCourses,
    CourseController controller,
  ) {
    return Obx(() {
      if (!_isCompletedExpanded.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final course = completedCourses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Opacity(
              opacity: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    CourseCard(
                      course: course,
                      onTap: () =>
                          Get.to(() => CourseDetailPage(course: course)),
                      onEdit: () {
                        controller.selectCourseForEditing(course);
                        Get.to(() => const AddCoursePage(isEditing: true));
                      },
                      onDelete: () => controller.deleteCourse(course.id),
                    ),
                    // Completion overlay
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: completedCourses.length),
      );
    });
  }
}
