import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Custom Light Color Scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.accent,
    error: AppColors.error,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
  );

  // Custom Dark Color Scheme
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    tertiary: AppColors.accentDark,
    error: AppColors.errorDark,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,

      // Text Theme
      textTheme: AppTextStyles.lightTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: _lightColorScheme.surface,
        foregroundColor: _lightColorScheme.onSurface,
        titleTextStyle: AppTextStyles.lightTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _lightColorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: _lightColorScheme.onSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shadowColor: Colors.black26,
        surfaceTintColor: _lightColorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: _lightColorScheme.onPrimary,
          disabledBackgroundColor: _lightColorScheme.onSurface.withOpacity(
            0.12,
          ),
          disabledForegroundColor: _lightColorScheme.onSurface.withOpacity(
            0.38,
          ),
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
          textStyle: AppTextStyles.lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          side: BorderSide(color: _lightColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
          textStyle: AppTextStyles.lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 8,
          ),
          textStyle: AppTextStyles.lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _lightColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _lightColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
        labelStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: _lightColorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: _lightColorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        errorStyle: AppTextStyles.lightTextTheme.bodySmall?.copyWith(
          color: _lightColorScheme.error,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightColorScheme.surface,
        selectedItemColor: _lightColorScheme.primary,
        unselectedItemColor: _lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightColorScheme.surface,
        indicatorColor: _lightColorScheme.primaryContainer,
        elevation: 3,
        surfaceTintColor: _lightColorScheme.surfaceTint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.lightTextTheme.bodySmall?.copyWith(
              color: _lightColorScheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.lightTextTheme.bodySmall?.copyWith(
            color: _lightColorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightColorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: _lightColorScheme.onInverseSurface,
        ),
        actionTextColor: _lightColorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 6,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _lightColorScheme.surface,
        surfaceTintColor: _lightColorScheme.surfaceTint,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.defaultBorderRadius * 2,
          ),
        ),
        titleTextStyle: AppTextStyles.lightTextTheme.headlineSmall?.copyWith(
          color: _lightColorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
          color: _lightColorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _lightColorScheme.surface,
        surfaceTintColor: _lightColorScheme.surfaceTint,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.defaultBorderRadius * 2),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightColorScheme.surfaceContainerHighest,
        selectedColor: _lightColorScheme.primaryContainer,
        disabledColor: _lightColorScheme.onSurface.withOpacity(0.12),
        labelStyle: AppTextStyles.lightTextTheme.bodySmall?.copyWith(
          color: _lightColorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 0,
        pressElevation: 2,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightColorScheme.onPrimary;
          }
          return _lightColorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightColorScheme.primary;
          }
          return _lightColorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightColorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_lightColorScheme.onPrimary),
        side: BorderSide(color: _lightColorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightColorScheme.primary;
          }
          return _lightColorScheme.outline;
        }),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,

      // Text Theme
      textTheme: AppTextStyles.darkTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: _darkColorScheme.surface,
        foregroundColor: _darkColorScheme.onSurface,
        titleTextStyle: AppTextStyles.darkTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _darkColorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: _darkColorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: _darkColorScheme.onSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shadowColor: Colors.black54,
        surfaceTintColor: _darkColorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: _darkColorScheme.onPrimary,
          disabledBackgroundColor: _darkColorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: _darkColorScheme.onSurface.withOpacity(0.38),
          elevation: 2,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
          textStyle: AppTextStyles.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          side: BorderSide(color: _darkColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
          textStyle: AppTextStyles.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 8,
          ),
          textStyle: AppTextStyles.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _darkColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: _darkColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
        labelStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: _darkColorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: _darkColorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        errorStyle: AppTextStyles.darkTextTheme.bodySmall?.copyWith(
          color: _darkColorScheme.error,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkColorScheme.surface,
        selectedItemColor: _darkColorScheme.primary,
        unselectedItemColor: _darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkColorScheme.surface,
        indicatorColor: _darkColorScheme.primaryContainer,
        elevation: 3,
        surfaceTintColor: _darkColorScheme.surfaceTint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.darkTextTheme.bodySmall?.copyWith(
              color: _darkColorScheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.darkTextTheme.bodySmall?.copyWith(
            color: _darkColorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkColorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: _darkColorScheme.onInverseSurface,
        ),
        actionTextColor: _darkColorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 6,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _darkColorScheme.surface,
        surfaceTintColor: _darkColorScheme.surfaceTint,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.defaultBorderRadius * 2,
          ),
        ),
        titleTextStyle: AppTextStyles.darkTextTheme.headlineSmall?.copyWith(
          color: _darkColorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
          color: _darkColorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _darkColorScheme.surface,
        surfaceTintColor: _darkColorScheme.surfaceTint,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.defaultBorderRadius * 2),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkColorScheme.surfaceContainerHighest,
        selectedColor: _darkColorScheme.primaryContainer,
        disabledColor: _darkColorScheme.onSurface.withOpacity(0.12),
        labelStyle: AppTextStyles.darkTextTheme.bodySmall?.copyWith(
          color: _darkColorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 0,
        pressElevation: 2,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkColorScheme.onPrimary;
          }
          return _darkColorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkColorScheme.primary;
          }
          return _darkColorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkColorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_darkColorScheme.onPrimary),
        side: BorderSide(color: _darkColorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkColorScheme.primary;
          }
          return _darkColorScheme.outline;
        }),
      ),
    );
  }
}

class ThemeController extends GetxController {
  final RxBool _isDarkMode = false.obs;
  final GetStorage _storage = GetStorage();

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get theme => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    // Load theme preference from storage
    final isDark = _storage.read(AppConstants.themeKey) ?? false;
    _isDarkMode.value = isDark;

    // Apply the theme without animation on app start
    Get.changeThemeMode(theme);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(theme);
    _saveThemeToStorage();

    // Show feedback to user
    Get.snackbar(
      'Theme Changed',
      _isDarkMode.value ? 'Dark theme enabled' : 'Light theme enabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      colorText: Get.theme.colorScheme.onInverseSurface,
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      borderRadius: AppConstants.defaultBorderRadius,
    );
  }

  void setTheme(bool isDark) {
    if (_isDarkMode.value != isDark) {
      _isDarkMode.value = isDark;
      Get.changeThemeMode(theme);
      _saveThemeToStorage();
    }
  }

  void setLightTheme() {
    setTheme(false);
  }

  void setDarkTheme() {
    setTheme(true);
  }

  void setSystemTheme() {
    // Get system brightness
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isSystemDark = brightness == Brightness.dark;
    setTheme(isSystemDark);
  }

  void _saveThemeToStorage() {
    // Save theme preference to storage
    _storage.write(AppConstants.themeKey, _isDarkMode.value);
  }

  // Helper methods for checking current theme
  bool get isLightTheme => !_isDarkMode.value;

  // Get current color scheme
  ColorScheme get currentColorScheme {
    return _isDarkMode.value
        ? AppTheme._darkColorScheme
        : AppTheme._lightColorScheme;
  }

  // Get status colors based on current theme
  Color getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }

  Color getStatusContainerColor(String status) {
    return AppColors.getStatusContainerColor(status);
  }

  Color getGradeColor(String grade) {
    return AppColors.getGradeColor(grade);
  }

  Color getPriorityColor(String priority) {
    return AppColors.getPriorityColor(priority);
  }

  // Get adaptive colors that work well in both themes
  Color get adaptiveTextColor {
    return _isDarkMode.value
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
  }

  Color get adaptiveSurfaceColor {
    return _isDarkMode.value ? AppColors.darkSurface : AppColors.lightSurface;
  }

  Color get adaptiveCardColor {
    return _isDarkMode.value ? AppColors.darkSurface : AppColors.lightSurface;
  }

  // Convenience method for getting contrast color
  Color getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
