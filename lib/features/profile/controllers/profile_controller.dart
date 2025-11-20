import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/cloud_database_service.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final StorageService _storageService = Get.find<StorageService>();
  CloudDatabaseService? _cloudService;

  // Reactive profile data
  final profileData = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  // Current user
  User? get currentUser => _authController.user;

  @override
  void onInit() {
    super.onInit();
    _initializeCloudService();
    loadProfileData();
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

  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;

      final user = currentUser;
      if (user != null) {
        // First, try to get updated data from cloud
        if (_cloudService != null) {
          try {
            print('📥 Syncing profile from cloud...');
            final cloudData = await _cloudService!.getUserProfile();

            if (cloudData != null) {
              // Save cloud data to local storage
              _storageService.saveProfileData(user.uid, cloudData);
              profileData.value = cloudData;
              print('✅ Profile synced from cloud');
            } else {
              // No cloud data, load from local
              final localData = _storageService.getProfileData(user.uid);
              if (localData != null) {
                profileData.value = localData;
                print('📱 Profile loaded from local storage');
              }
            }
          } catch (e) {
            print('⚠️ Failed to sync from cloud, using local data: $e');
            // Fallback to local data
            final localData = _storageService.getProfileData(user.uid);
            if (localData != null) {
              profileData.value = localData;
            }
          }
        } else {
          // No cloud service, load from local
          final data = _storageService.getProfileData(user.uid);
          if (data != null) {
            profileData.value = data;
            print('📱 Profile loaded from local storage');
          }
        }

        // Trigger UI update
        update();
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getProfileValue(String key, {String defaultValue = 'Not available'}) {
    final value = profileData[key];
    if (value == null || value.toString().trim().isEmpty) {
      return defaultValue;
    }

    // Special formatting for expectedGraduation
    if (key == 'expectedGraduation') {
      return _formatGraduationDate(value.toString());
    }

    return value.toString();
  }

  String _formatGraduationDate(String dateString) {
    try {
      // Try to parse as ISO date
      final date = DateTime.parse(dateString);
      return _formatDateToReadable(date);
    } catch (e) {
      // If parsing fails, return as is (for backward compatibility)
      return dateString;
    }
  }

  String _formatDateToReadable(DateTime date) {
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
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> refreshProfileData() async {
    await loadProfileData();
    update();
  }
}
