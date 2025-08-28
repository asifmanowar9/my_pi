import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setError(String error) {
    _errorMessage.value = error;
  }

  void clearError() {
    _errorMessage.value = '';
  }

  void showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Get.theme.colorScheme.error
          : Get.theme.colorScheme.primary,
      colorText: isError
          ? Get.theme.colorScheme.onError
          : Get.theme.colorScheme.onPrimary,
    );
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
