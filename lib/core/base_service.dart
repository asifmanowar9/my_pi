import 'package:get/get.dart';

abstract class BaseService extends GetxService {
  // Common API configuration
  static const String baseUrl = 'https://your-api-base-url.com';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // HTTP Client instance
  final GetConnect _httpClient = GetConnect(
    timeout: timeoutDuration,
    userAgent: 'MyPi/1.0.0',
  );

  GetConnect get httpClient => _httpClient;

  @override
  void onInit() {
    super.onInit();
    _configureHttpClient();
  }

  void _configureHttpClient() {
    _httpClient.baseUrl = baseUrl;
    _httpClient.timeout = timeoutDuration;

    // Add request interceptor for auth tokens
    _httpClient.httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      // Add auth token if available
      // final token = StorageService.getAuthToken();
      // if (token != null) {
      //   request.headers['Authorization'] = 'Bearer $token';
      // }
      return request;
    });

    // Add response interceptor for error handling
    _httpClient.httpClient.addResponseModifier((request, response) {
      if (response.statusCode != 200) {
        handleError(response.statusCode, response.statusText);
      }
      return response;
    });
  }

  void handleError(int? statusCode, String? statusText) {
    switch (statusCode) {
      case 401:
        Get.offAllNamed('/login');
        break;
      case 403:
        Get.snackbar(
          'Access Denied',
          'You don\'t have permission to access this resource',
        );
        break;
      case 404:
        Get.snackbar('Not Found', 'The requested resource was not found');
        break;
      case 500:
        Get.snackbar('Server Error', 'Internal server error occurred');
        break;
      default:
        Get.snackbar('Error', statusText ?? 'Unknown error occurred');
    }
  }

  Future<T?> handleApiCall<T>(Future<Response<T>> apiCall) async {
    try {
      final response = await apiCall;
      if (response.isOk) {
        return response.body;
      } else {
        handleError(response.statusCode, response.statusText);
        return null;
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Please check your internet connection');
      return null;
    }
  }
}
