import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/models/assignment.dart';
import '../../shared/widgets/guest_mode_banner.dart';
import '../auth/controllers/auth_controller.dart';
import 'controllers/assignment_controller.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(AssignmentController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAssignments(),
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

        if (controller.assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No assignments yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first assignment to get started',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
                onRefresh: controller.loadAssignments,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AssignmentSummary(controller: controller),
                      const SizedBox(height: 24),
                      _AssignmentsList(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AssignmentSummary extends StatelessWidget {
  final AssignmentController controller;

  const _AssignmentSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignment Overview', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Pending',
                    count: controller.pendingCount,
                    color: AppColors.getStatusColor('pending'),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'In Progress',
                    count: controller.inProgressCount,
                    color: AppColors.getStatusColor('in_progress'),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Completed',
                    count: controller.completedCount,
                    color: AppColors.getStatusColor('completed'),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Overdue',
                    count: controller.overdueCount,
                    color: AppColors.getStatusColor('overdue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _AssignmentsList extends StatelessWidget {
  final AssignmentController controller;

  const _AssignmentsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Assignments', style: AppTextStyles.cardTitle),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.assignments.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AssignmentCard(
                assignment: controller.assignments[index],
                controller: controller,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AssignmentCard extends StatefulWidget {
  final Assignment assignment;
  final AssignmentController controller;

  const _AssignmentCard({required this.assignment, required this.controller});

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  String _courseCode = '';

  @override
  void initState() {
    super.initState();
    _loadCourseCode();
  }

  Future<void> _loadCourseCode() async {
    final code = await widget.controller.getCourseCode(
      widget.assignment.courseId,
    );
    if (mounted) {
      setState(() => _courseCode = code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(widget.assignment.status.name);
    final priorityColor = AppColors.getPriorityColor(
      widget.assignment.priority.name,
    );

    return Card(
      child: InkWell(
        onTap: () {
          Get.toNamed('/assignment/${widget.assignment.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assignment.title,
                          style: AppTextStyles.assignmentTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _courseCode.isEmpty ? 'Loading...' : _courseCode,
                          style: AppTextStyles.courseCode,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.assignment.status.name
                              .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
                              .toUpperCase(),
                          style: AppTextStyles.statusChip.copyWith(
                            color: statusColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.assignment.type.name.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.assignment.description.isEmpty
                    ? 'No description'
                    : widget.assignment.description,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.assignment.timeUntilDueString,
                    style: AppTextStyles.dueDate.copyWith(
                      color: widget.assignment.isOverdue() ? Colors.red : null,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.assignment.priority.name.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 16,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.assignment.type.name.toUpperCase(),
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  if (widget.assignment.status == AssignmentStatus.pending ||
                      widget.assignment.status == AssignmentStatus.inProgress)
                    TextButton(
                      onPressed: () {
                        Get.toNamed(
                          '/assignment/${widget.assignment.id}/submit',
                        );
                      },
                      child: const Text('Submit'),
                    )
                  else if (widget.assignment.status ==
                      AssignmentStatus.completed)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
