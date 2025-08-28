import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  // Generic storage methods
  void write(String key, dynamic value) {
    _box.write(key, value);
  }

  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  void remove(String key) {
    _box.remove(key);
  }

  void clear() {
    _box.erase();
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }

  // App-specific storage methods
  void saveUserToken(String token) {
    write(AppConstants.userTokenKey, token);
  }

  String? getUserToken() {
    return read<String>(AppConstants.userTokenKey);
  }

  void removeUserToken() {
    remove(AppConstants.userTokenKey);
  }

  void saveUserData(Map<String, dynamic> userData) {
    write(AppConstants.userDataKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    return read<Map<String, dynamic>>(AppConstants.userDataKey);
  }

  void removeUserData() {
    remove(AppConstants.userDataKey);
  }

  void saveThemeMode(bool isDarkMode) {
    write(AppConstants.themeKey, isDarkMode);
  }

  bool? getThemeMode() {
    return read<bool>(AppConstants.themeKey);
  }

  void saveLanguage(String languageCode) {
    write(AppConstants.languageKey, languageCode);
  }

  String? getLanguage() {
    return read<String>(AppConstants.languageKey);
  }

  // Clear all user-related data
  void clearUserData() {
    removeUserToken();
    removeUserData();
  }
}
