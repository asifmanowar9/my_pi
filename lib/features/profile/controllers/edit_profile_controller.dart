import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/cloud_database_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final StorageService _storageService = Get.find<StorageService>();
  CloudDatabaseService? _cloudService;

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Current user
  User? get currentUser => _authController.user;

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthDateController;
  late TextEditingController studentIdController;
  late TextEditingController gpaController;
  late TextEditingController advisorController;
  late TextEditingController expectedGraduationController;
  late TextEditingController addressController;
  late TextEditingController emergencyContactController;
  late TextEditingController emergencyPhoneController;
  late TextEditingController bioController;

  // Dropdown selections
  final selectedMajor = ''.obs;
  final selectedYear = ''.obs;
  final selectedGraduationDate = Rxn<DateTime>();

  // Dropdown options
  final List<String> majors = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
    'Business Administration',
    'Marketing',
    'Finance',
    'Accounting',
    'Economics',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Environmental Engineering',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Psychology',
    'Sociology',
    'Political Science',
    'English Literature',
    'Communications',
    'Art and Design',
    'Music',
    'Education',
    'Medicine',
    'Nursing',
    'Pharmacy',
    'Other',
  ];

  final List<String> academicYears = [
    'Freshman (1st Year)',
    'Sophomore (2nd Year)',
    'Junior (3rd Year)',
    'Senior (4th Year)',
    'Graduate Student',
    'PhD Student',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeCloudService();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeCloudService() {
    try {
      if (Get.isRegistered<CloudDatabaseService>()) {
        _cloudService = Get.find<CloudDatabaseService>();
      }
    } catch (e) {
      print('Cloud service not available: $e');
    }
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    birthDateController = TextEditingController();
    studentIdController = TextEditingController();
    gpaController = TextEditingController();
    advisorController = TextEditingController();
    expectedGraduationController = TextEditingController();
    addressController = TextEditingController();
    emergencyContactController = TextEditingController();
    emergencyPhoneController = TextEditingController();
    bioController = TextEditingController();
  }

  void _disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    studentIdController.dispose();
    gpaController.dispose();
    advisorController.dispose();
    expectedGraduationController.dispose();
    addressController.dispose();
    emergencyContactController.dispose();
    emergencyPhoneController.dispose();
    bioController.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;

      final user = currentUser;
      if (user != null) {
        // Load basic user data
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';

        // Load local data first
        Map<String, dynamic>? localProfileData = _storageService.getProfileData(
          user.uid,
        );
        print(
          '📱 Local profile data: ${localProfileData != null ? "found" : "not found"}',
        );

        // Then check Firestore for updates
        Map<String, dynamic>? profileData = localProfileData;
        if (_cloudService != null) {
          try {
            print('☁️ Checking Firestore for profile updates...');
            final cloudProfileData = await _cloudService!.getUserProfile();

            if (cloudProfileData != null) {
              // Compare timestamps to decide which version to use
              if (localProfileData != null) {
                final localUpdatedAt = localProfileData['updatedAt'] as String?;
                final cloudUpdatedAt = cloudProfileData['updatedAt'] as String?;

                if (localUpdatedAt != null && cloudUpdatedAt != null) {
                  try {
                    final localTime = DateTime.parse(localUpdatedAt);
                    final cloudTime = DateTime.parse(cloudUpdatedAt);

                    if (cloudTime.isAfter(localTime)) {
                      print('☁️ Cloud version is newer, using cloud data');
                      profileData = cloudProfileData;
                      // Update local storage with newer cloud data
                      _storageService.saveProfileData(
                        user.uid,
                        cloudProfileData,
                      );
                    } else {
                      print('📱 Local version is up-to-date');
                    }
                  } catch (e) {
                    print('⚠️ Failed to compare timestamps: $e');
                    // If timestamp comparison fails, prefer cloud data
                    profileData = cloudProfileData;
                    _storageService.saveProfileData(user.uid, cloudProfileData);
                  }
                } else {
                  // If no timestamp, prefer cloud data
                  print('☁️ No timestamps found, using cloud data');
                  profileData = cloudProfileData;
                  _storageService.saveProfileData(user.uid, cloudProfileData);
                }
              } else {
                // No local data, use cloud data
                print('☁️ No local data, using cloud data');
                profileData = cloudProfileData;
                _storageService.saveProfileData(user.uid, cloudProfileData);
              }
            } else {
              print('ℹ️ No cloud profile data found, using local data');
            }
          } catch (e) {
            print('⚠️ Failed to load from Firestore, using local data: $e');
          }
        }

        if (profileData != null) {
          phoneController.text = profileData['phone'] ?? '';
          studentIdController.text = profileData['studentId'] ?? '';
          selectedMajor.value = profileData['major'] ?? '';
          selectedYear.value = profileData['academicYear'] ?? '';
          gpaController.text = profileData['gpa'] ?? '';
          advisorController.text = profileData['advisor'] ?? '';

          // Parse graduation date if available and format it properly
          if (profileData['expectedGraduation'] != null &&
              profileData['expectedGraduation'].toString().isNotEmpty) {
            try {
              final parsedDate = DateTime.parse(
                profileData['expectedGraduation'],
              );
              selectedGraduationDate.value = parsedDate;
              expectedGraduationController.text =
                  '${parsedDate.day} ${_getMonthName(parsedDate.month)} ${parsedDate.year}';
            } catch (e) {
              // If parsing fails, keep the text as is for backward compatibility
              expectedGraduationController.text =
                  profileData['expectedGraduation'] ?? '';
              print('Failed to parse graduation date: $e');
            }
          } else {
            expectedGraduationController.text = '';
          }

          addressController.text = profileData['address'] ?? '';
          emergencyContactController.text =
              profileData['emergencyContact'] ?? '';
          emergencyPhoneController.text = profileData['emergencyPhone'] ?? '';
          bioController.text = profileData['bio'] ?? '';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Name is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (nameController.text.trim().length < 2) {
      Get.snackbar(
        'Validation Error',
        'Name must be at least 2 characters',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate GPA if provided
    if (gpaController.text.isNotEmpty) {
      final gpa = double.tryParse(gpaController.text);
      if (gpa == null || gpa < 0 || gpa > 4.0) {
        Get.snackbar(
          'Validation Error',
          'GPA must be between 0.0 and 4.0',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    // Validate phone numbers if provided
    if (phoneController.text.isNotEmpty && phoneController.text.length < 10) {
      Get.snackbar(
        'Validation Error',
        'Enter a valid phone number',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (emergencyPhoneController.text.isNotEmpty &&
        emergencyPhoneController.text.length < 10) {
      Get.snackbar(
        'Validation Error',
        'Enter a valid emergency phone number',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> pickGraduationDate() async {
    final DateTime? picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate:
            selectedGraduationDate.value ??
            DateTime.now().add(const Duration(days: 365)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        helpText: 'Select Expected Graduation Date',
        confirmText: 'SELECT',
        cancelText: 'CANCEL',
      ),
    );

    if (picked != null) {
      selectedGraduationDate.value = picked;
      expectedGraduationController.text =
          '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  Future<void> saveProfile() async {
    print('Save profile method called');

    if (!_validateForm()) {
      print('Validation failed, not saving');
      return;
    }

    try {
      print('Starting save process');
      isSaving.value = true;

      final user = currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      print('User found, preparing profile data');

      // Prepare profile data
      final profileData = {
        'phone': phoneController.text.trim(),
        'studentId': studentIdController.text.trim(),
        'major': selectedMajor.value,
        'year': selectedYear
            .value, // Use 'year' instead of 'academicYear' for consistency
        'gpa': gpaController.text.trim(),
        'advisor': advisorController.text.trim(),
        'expectedGraduation':
            selectedGraduationDate.value?.toIso8601String() ??
            expectedGraduationController.text.trim(),
        'address': addressController.text.trim(),
        'emergencyContact': emergencyContactController.text.trim(),
        'emergencyPhone': emergencyPhoneController.text.trim(),
        'bio': bioController.text.trim(),
        'campus': 'Main Campus', // Default value
        'academicYear':
            selectedYear.value, // Keep this for backward compatibility
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Save to local storage
      _storageService.saveProfileData(user.uid, profileData);
      print('✅ Profile saved to local storage');

      // Sync to Firestore
      if (_cloudService != null) {
        try {
          await _cloudService!.saveUserProfile(profileData);
          print('✅ Profile synced to Firestore');
        } catch (e) {
          print('⚠️ Failed to sync profile to Firestore: $e');
          // Don't fail the save operation if cloud sync fails
        }
      } else {
        print('ℹ️ Cloud service not available, profile saved locally only');
      }

      // Update Firebase user profile if name changed
      if (nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(nameController.text.trim());
      }

      // Refresh profile data in ProfileController if it exists
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshProfileData();
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Navigate back immediately
      print('Navigating back after successful save');

      // Use Get.until to ensure we go back to the profile screen
      Get.until(
        (route) => route.isFirst || route.settings.name != '/profile/edit',
      );

      print('Navigation completed');
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      print('Setting isSaving to false');
      isSaving.value = false;
    }
  }

  // Sync profile to cloud only if there are local changes
  Future<void> syncProfileToCloud() async {
    if (_cloudService == null) {
      print('ℹ️ Cloud service not available, skipping profile sync');
      return;
    }

    final user = currentUser;
    if (user == null) {
      print('⚠️ No user found, skipping profile sync');
      return;
    }

    try {
      print('🔄 Checking profile for cloud sync...');

      // Get local profile data
      final localProfileData = _storageService.getProfileData(user.uid);
      if (localProfileData == null) {
        print('ℹ️ No local profile data to sync');
        return;
      }

      // Get cloud profile data
      final cloudProfileData = await _cloudService!.getUserProfile();

      // Check if sync is needed
      bool needsSync = false;
      if (cloudProfileData == null) {
        print('☁️ No cloud profile found, will upload local data');
        needsSync = true;
      } else {
        // Compare timestamps
        final localUpdatedAt = localProfileData['updatedAt'] as String?;
        final cloudUpdatedAt = cloudProfileData['updatedAt'] as String?;

        if (localUpdatedAt != null && cloudUpdatedAt != null) {
          try {
            final localTime = DateTime.parse(localUpdatedAt);
            final cloudTime = DateTime.parse(cloudUpdatedAt);

            if (localTime.isAfter(cloudTime)) {
              print('📤 Local profile is newer, syncing to cloud');
              needsSync = true;
            } else {
              print('✅ Cloud profile is up-to-date, no sync needed');
            }
          } catch (e) {
            print('⚠️ Failed to compare timestamps: $e');
            needsSync = true; // Sync on error to be safe
          }
        } else {
          // If no timestamps, compare data to detect changes
          needsSync = _hasProfileChanges(localProfileData, cloudProfileData);
        }
      }

      if (needsSync) {
        await _cloudService!.saveUserProfile(localProfileData);
        print('✅ Profile synced to cloud successfully');
      }
    } catch (e) {
      print('⚠️ Failed to sync profile to cloud: $e');
      // Don't throw error as this is a background operation
    }
  }

  // Check if there are actual changes between local and cloud data
  bool _hasProfileChanges(
    Map<String, dynamic> local,
    Map<String, dynamic> cloud,
  ) {
    final fieldsToCompare = [
      'phone',
      'studentId',
      'major',
      'year',
      'gpa',
      'advisor',
      'expectedGraduation',
      'address',
      'emergencyContact',
      'emergencyPhone',
      'bio',
      'academicYear',
    ];

    for (final field in fieldsToCompare) {
      if (local[field] != cloud[field]) {
        print(
          '📝 Field "$field" has changed: "${local[field]}" != "${cloud[field]}"',
        );
        return true;
      }
    }

    print('✅ No profile changes detected');
    return false;
  }

  // Birth date picker method
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // Default to 18 years old
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
}
