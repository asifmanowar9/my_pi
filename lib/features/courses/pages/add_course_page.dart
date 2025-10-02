import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
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
                const SizedBox(height: 16),

                // Schedule
                _buildTextField(
                  controller: controller.scheduleController,
                  label: 'Schedule',
                  hint: 'e.g., Mon, Wed, Fri 10:00 AM',
                  icon: Icons.schedule_outlined,
                  required: true,
                  validator: controller.validateSchedule,
                ),
                const SizedBox(height: 16),

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
}
