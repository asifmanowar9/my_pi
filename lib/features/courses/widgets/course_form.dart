import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';

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

          // Schedule
          TextFormField(
            controller: controller.scheduleController,
            decoration: const InputDecoration(
              labelText: 'Schedule',
              hintText: 'e.g., Mon, Wed, Fri 10:00-11:30',
              prefixIcon: Icon(Icons.schedule),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
          ),

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
                  '• Schedule format is flexible (e.g., "MWF 10:00-11:30")',
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
}
