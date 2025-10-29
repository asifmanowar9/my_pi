import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/themes/app_text_styles.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile', style: AppTextStyles.appBarTitle),
            elevation: 0,
            actions: [
              Obx(
                () => TextButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveProfile,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileImageSection(controller: controller),
                  const SizedBox(height: 24),
                  _PersonalInfoSection(controller: controller),
                  const SizedBox(height: 24),
                  _AcademicInfoSection(controller: controller),
                  const SizedBox(height: 24),
                  _ContactInfoSection(controller: controller),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final EditProfileController controller;

  const _ProfileImageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Obx(() {
              final user = controller.currentUser;
              final photoUrl = user?.photoURL;
              final initials = _getInitials(
                user?.displayName ?? user?.email ?? 'User',
              );

              return CircleAvatar(
                radius: 60,
                backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Profile Picture',
              style:
                  Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'You can change your profile picture through your Google account',
              style:
                  Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ) ??
                  TextStyle(
                    fontSize: 12,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}

class _PersonalInfoSection extends StatelessWidget {
  final EditProfileController controller;

  const _PersonalInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style:
                  Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
              helperText: 'Email cannot be changed',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicInfoSection extends StatelessWidget {
  final EditProfileController controller;

  const _AcademicInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Information',
              style:
                  Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.studentIdController,
              label: 'Student ID',
              icon: Icons.school_outlined,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              value: controller.selectedMajor.value.isEmpty
                  ? null
                  : controller.selectedMajor.value,
              label: 'Major',
              icon: Icons.auto_stories_outlined,
              items: controller.majors,
              onChanged: (value) =>
                  controller.selectedMajor.value = value ?? '',
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              value: controller.selectedYear.value.isEmpty
                  ? null
                  : controller.selectedYear.value,
              label: 'Academic Year',
              icon: Icons.timeline_outlined,
              items: controller.academicYears,
              onChanged: (value) => controller.selectedYear.value = value ?? '',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.gpaController,
              label: 'Current GPA',
              icon: Icons.grade_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.advisorController,
              label: 'Academic Advisor',
              icon: Icons.supervisor_account_outlined,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildDatePickerField(
              controller: controller.expectedGraduationController,
              label: 'Expected Graduation',
              icon: Icons.calendar_today_outlined,
              onTap: controller.pickGraduationDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoSection extends StatelessWidget {
  final EditProfileController controller;

  const _ContactInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style:
                  Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.streetAddress,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.emergencyContactController,
              label: 'Emergency Contact Name',
              icon: Icons.emergency_outlined,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.emergencyPhoneController,
              label: 'Emergency Contact Phone',
              icon: Icons.phone_in_talk_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.bioController,
              label: 'Bio',
              icon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              helperText: 'Tell us a bit about yourself (optional)',
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool enabled = true,
  bool readOnly = false,
  int maxLines = 1,
  String? helperText,
  VoidCallback? onTap,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    enabled: enabled,
    readOnly: readOnly,
    maxLines: maxLines,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Get.theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.colorScheme.primary, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Get.theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      filled: true,
      fillColor: enabled
          ? Get.theme.colorScheme.surface
          : Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

Widget _buildDropdownField({
  required String? value,
  required String label,
  required IconData icon,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Get.theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Get.theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: onChanged,
    dropdownColor: Get.theme.colorScheme.surface,
  );
}

Widget _buildDatePickerField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return TextFormField(
    controller: controller,
    readOnly: true,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: const Icon(Icons.arrow_drop_down),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Get.theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Get.theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
