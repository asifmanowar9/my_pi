import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../models/class_schedule_entry.dart';
import '../../../shared/themes/app_text_styles.dart';

class AddCoursePage extends StatelessWidget {
  final bool isEditing;

  const AddCoursePage({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Course' : 'Add Course',
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, controller),
              tooltip: 'Delete Course',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Name
                _buildTextField(
                  controller: controller.nameController,
                  label: 'Course Name',
                  hint: 'e.g., Introduction to Computer Science',
                  icon: Icons.book_outlined,
                  required: true,
                  validator: controller.validateCourseName,
                ),
                const SizedBox(height: 16),

                // Course Code (Optional)
                _buildTextField(
                  controller: controller.codeController,
                  label: 'Course Code (Optional)',
                  hint: 'e.g., CS101',
                  icon: Icons.tag_outlined,
                ),
                const SizedBox(height: 16),

                // Teacher Name
                _buildTextField(
                  controller: controller.teacherController,
                  label: 'Teacher Name',
                  hint: 'e.g., Dr. John Smith',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Classroom
                _buildTextField(
                  controller: controller.classroomController,
                  label: 'Classroom',
                  hint: 'e.g., Room 101',
                  icon: Icons.room_outlined,
                  required: true,
                  validator: controller.validateClassroom,
                ),
                const SizedBox(height: 24),

                // Class Schedule Section
                Text(
                  'Class Schedule & Reminders',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up class days and time to receive notifications before class starts',
                  style: AppTextStyles.caption.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Schedule Section - Updated for multiple day-time combinations
                _buildScheduleSection(context, controller),
                const SizedBox(height: 24),

                // Credits
                _buildTextField(
                  controller: controller.creditsController,
                  label: 'Credits',
                  hint: '3',
                  icon: Icons.school_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Start Date
                Obx(
                  () => _buildDateField(
                    label: 'Start Date (Optional)',
                    hint: controller.startDate == null
                        ? 'Select start date'
                        : '${controller.startDate!.day}/${controller.startDate!.month}/${controller.startDate!.year}',
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _selectStartDate(context, controller),
                    value: controller.startDate,
                  ),
                ),
                const SizedBox(height: 16),

                // Duration in Months
                _buildTextField(
                  controller: controller.durationController,
                  label: 'Duration (Months)',
                  hint: 'e.g., 4, 5, 6',
                  icon: Icons.timelapse_outlined,
                  keyboardType: TextInputType.number,
                  helperText: 'Course will auto-complete after this period',
                ),
                const SizedBox(height: 16),

                // Show calculated end date
                Obx(() {
                  if (controller.startDate != null &&
                      controller.durationController.text.isNotEmpty) {
                    try {
                      final months = int.parse(
                        controller.durationController.text,
                      );
                      final endDate = DateTime(
                        controller.startDate!.year,
                        controller.startDate!.month + months,
                        controller.startDate!.day,
                      );
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Get.theme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Get.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Course will end on: ${endDate.day}/${endDate.month}/${endDate.year}',
                                style: AppTextStyles.caption.copyWith(
                                  color: Get.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),

                // Description (Optional)
                _buildTextField(
                  controller: controller.descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Brief description of the course',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Course Color Selector
                Text(
                  'Course Color',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => _buildColorSelector(controller)),

                const SizedBox(height: 32),

                // Error message
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Get.theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.errorMessage,
                              style: AppTextStyles.caption.copyWith(
                                color: Get.theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clearForm();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => FilledButton(
                          onPressed:
                              (controller.isCreating || controller.isUpdating)
                              ? null
                              : () => _saveCourse(controller),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              (controller.isCreating || controller.isUpdating)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? 'Update' : 'Save'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: validator,
    );
  }

  Widget _buildColorSelector(CourseController controller) {
    final colors = controller.materialYouColors;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // No color option
        InkWell(
          onTap: () => controller.setSelectedColor(null),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selectedColor == null
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.outline,
                width: controller.selectedColor == null ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.block, color: Get.theme.colorScheme.outline),
          ),
        ),
        // Color options
        ...colors.map(
          (color) => InkWell(
            onTap: () => controller.setSelectedColor(color),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.selectedColor == color
                      ? Get.theme.colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: controller.selectedColor == color
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _saveCourse(CourseController controller) async {
    if (isEditing) {
      final success = await controller.updateCourse();
      if (success) {
        // Navigate back to courses screen after successful update
        Get.back();
      }
    } else {
      final success = await controller.createCourse();
      if (success) {
        // Navigate back to courses screen after successful creation
        Get.back();
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CourseController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await controller.deleteSelectedCourse();
              if (success) {
                Get.back(); // Go back to courses list
                Get.snackbar(
                  'Success',
                  'Course deleted successfully',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                  icon: const Icon(Icons.delete, color: Colors.red),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    DateTime? value,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        child: Text(
          value == null ? hint : '${value.day}/${value.month}/${value.year}',
          style: TextStyle(
            color: value == null
                ? Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                : Get.theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _selectStartDate(
    BuildContext context,
    CourseController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Get.theme.copyWith(colorScheme: Get.theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setStartDate(picked);
    }
  }

  Widget _buildReminderDropdown(CourseController controller) {
    return DropdownButtonFormField<int>(
      value: controller.reminderMinutes == 0
          ? null
          : controller.reminderMinutes,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.notifications_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        hintText: 'Select reminder time',
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('No reminder')),
        DropdownMenuItem(value: 10, child: Text('10 minutes before')),
        DropdownMenuItem(value: 15, child: Text('15 minutes before')),
      ],
      onChanged: (value) {
        controller.setReminderMinutes(value ?? 0);
      },
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    CourseController controller,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Class Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (controller.scheduleEntries.length < 3)
                  IconButton(
                    onPressed: () =>
                        _showAddScheduleDialog(context, controller),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add class day',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add up to 3 class days with different times',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Entries List
            Obx(() => _buildScheduleEntriesList(context, controller)),

            const SizedBox(height: 16),

            // Reminder Minutes
            Text(
              'Reminder Before Class',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Obx(() => _buildReminderDropdown(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleEntriesList(
    BuildContext context,
    CourseController controller,
  ) {
    if (controller.scheduleEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No class schedule added',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add class days and times for notifications',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add Class Day'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: controller.scheduleEntries.map((entry) {
        return _buildScheduleEntryCard(context, controller, entry);
      }).toList(),
    );
  }

  Widget _buildScheduleEntryCard(
    BuildContext context,
    CourseController controller,
    ClassScheduleEntry entry,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.dayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.formattedTime,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _editScheduleEntry(context, controller, entry),
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Edit time',
          ),
          IconButton(
            onPressed: () => controller.removeScheduleEntry(entry.dayOfWeek),
            icon: const Icon(Icons.delete, size: 20),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(
    BuildContext context,
    CourseController controller,
  ) {
    final List<Map<String, dynamic>> availableDays =
        [
              {'day': 'Monday', 'value': 1},
              {'day': 'Tuesday', 'value': 2},
              {'day': 'Wednesday', 'value': 3},
              {'day': 'Thursday', 'value': 4},
              {'day': 'Friday', 'value': 5},
              {'day': 'Saturday', 'value': 6},
              {'day': 'Sunday', 'value': 7},
            ]
            .where((day) => !controller.hasScheduleForDay(day['value'] as int))
            .toList();

    if (availableDays.isEmpty) {
      Get.snackbar(
        'No Available Days',
        'All days are already scheduled for this course',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int? selectedDay;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Class Day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Day',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                hint: const Text('Choose a day'),
                items: availableDays.map((day) {
                  return DropdownMenuItem<int>(
                    value: day['value'] as int,
                    child: Text(day['day'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Time',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatTime(selectedTime),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDay == null
                  ? null
                  : () {
                      controller.addScheduleEntry(selectedDay!, selectedTime);
                      Navigator.of(context).pop();
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editScheduleEntry(
    BuildContext context,
    CourseController controller,
    ClassScheduleEntry entry,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entry.time,
      builder: (context, child) {
        return Theme(
          data: Get.theme.copyWith(colorScheme: Get.theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateScheduleEntryTime(entry.dayOfWeek, picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
