import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../models/class_schedule_entry.dart';

class CourseForm extends StatelessWidget {
  final CourseController controller;
  final bool isEditing;

  const CourseForm({
    super.key,
    required this.controller,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Name
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Course Name *',
              hintText: 'e.g., Mathematics 101',
              prefixIcon: Icon(Icons.book),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Course name is required';
              }
              if (value.trim().length < 3) {
                return 'Course name must be at least 3 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Course Code
          TextFormField(
            controller: controller.codeController,
            decoration: const InputDecoration(
              labelText: 'Course Code',
              hintText: 'e.g., CS101, MATH201',
              prefixIcon: Icon(Icons.qr_code),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value != null &&
                  value.trim().isNotEmpty &&
                  value.trim().length < 2) {
                return 'Course code must be at least 2 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Brief description of the course',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Teacher Name
          TextFormField(
            controller: controller.teacherController,
            decoration: const InputDecoration(
              labelText: 'Teacher Name *',
              hintText: 'e.g., Dr. John Smith',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Teacher name is required';
              }
              if (value.trim().length < 2) {
                return 'Teacher name must be at least 2 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Classroom
          TextFormField(
            controller: controller.classroomController,
            decoration: const InputDecoration(
              labelText: 'Classroom *',
              hintText: 'e.g., Room 101, Building A',
              prefixIcon: Icon(Icons.room),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Classroom is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Credits
          TextFormField(
            controller: controller.creditsController,
            decoration: const InputDecoration(
              labelText: 'Credits *',
              hintText: 'e.g., 3',
              prefixIcon: Icon(Icons.school),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Credits is required';
              }
              final credits = int.tryParse(value.trim());
              if (credits == null) {
                return 'Please enter a valid number';
              }
              if (credits < 1 || credits > 10) {
                return 'Credits must be between 1 and 10';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Structured Schedule Picker
          _buildScheduleSection(context, controller),

          const SizedBox(height: 16),

          // Course Color
          Obx(
            () => InkWell(
              onTap: () => _showColorPicker(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.palette, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.selectedColor != null
                            ? 'Course Color Selected'
                            : 'Select Course Color (Optional)',
                        style: TextStyle(
                          color: controller.selectedColor != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (controller.selectedColor != null)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: controller.selectedColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Validation errors
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Form instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Form Guidelines',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Fields marked with * are required\n'
                  '• Course name must be unique\n'
                  '• Credits should be between 1 and 10\n'
                  '• Select class days and time to receive notifications',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    onPressed: () => _showAddScheduleDialog(context, controller),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => _buildReminderDropdown(context, controller)),
          ],
        ),
      ),
    );
  }



  Widget _buildReminderDropdown(BuildContext context, CourseController controller) {
    return DropdownButtonFormField<int>(
      value: controller.reminderMinutes == 0 ? 10 : controller.reminderMinutes,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.notifications_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      items: const [
        DropdownMenuItem(value: 10, child: Text('10 minutes before')),
        DropdownMenuItem(value: 15, child: Text('15 minutes before')),
      ],
      onChanged: (value) {
        if (value != null) {
          controller.setReminderMinutes(value);
        }
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }



  void _showColorPicker(BuildContext context) {
    final List<Color> predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Course Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: predefinedColors.length + 1, // +1 for "no color" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "No color" option
                return GestureDetector(
                  onTap: () {
                    controller.setSelectedColor(null);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.clear, color: Colors.grey),
                  ),
                );
              } else {
                final color = predefinedColors[index - 1];
                return GestureDetector(
                  onTap: () {
                    controller.setSelectedColor(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
    final List<Map<String, dynamic>> availableDays = [
      {'day': 'Monday', 'value': 1},
      {'day': 'Tuesday', 'value': 2},
      {'day': 'Wednesday', 'value': 3},
      {'day': 'Thursday', 'value': 4},
      {'day': 'Friday', 'value': 5},
      {'day': 'Saturday', 'value': 6},
      {'day': 'Sunday', 'value': 7},
    ].where((day) => !controller.hasScheduleForDay(day['value'] as int)).toList();

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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
}
