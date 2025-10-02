import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTextStyles - Comprehensive text styling system for My Pi app
/// Provides consistent typography across light and dark themes
class AppTextStyles {
  // Base font family - using system default for better compatibility
  static const String fontFamily = 'Roboto';

  // Light Theme Text Styles
  static TextTheme get lightTextTheme {
    return TextTheme(
      // Display Styles - Largest text styles
      displayLarge: const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: AppColors.lightOnSurface,
        height: 1.12,
        fontFamily: fontFamily,
      ),
      displayMedium: const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.16,
        fontFamily: fontFamily,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.22,
        fontFamily: fontFamily,
      ),

      // Headline Styles - Large text like page titles
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.25,
        fontFamily: fontFamily,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.29,
        fontFamily: fontFamily,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.33,
        fontFamily: fontFamily,
      ),

      // Title Styles - Medium emphasis text
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AppColors.lightOnSurface,
        height: 1.27,
        fontFamily: fontFamily,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: AppColors.lightOnSurface,
        height: 1.50,
        fontFamily: fontFamily,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.lightOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),

      // Label Styles - Button text and small labels
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.lightOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.lightOnSurface,
        height: 1.33,
        fontFamily: fontFamily,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.lightOnSurface,
        height: 1.45,
        fontFamily: fontFamily,
      ),

      // Body Styles - Main content text
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: AppColors.lightOnSurface,
        height: 1.50,
        fontFamily: fontFamily,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.lightOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.lightOnSurfaceVariant,
        height: 1.33,
        fontFamily: fontFamily,
      ),
    );
  }

  // Dark Theme Text Styles
  static TextTheme get darkTextTheme {
    return TextTheme(
      // Display Styles
      displayLarge: const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: AppColors.darkOnSurface,
        height: 1.12,
        fontFamily: fontFamily,
      ),
      displayMedium: const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.16,
        fontFamily: fontFamily,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.22,
        fontFamily: fontFamily,
      ),

      // Headline Styles
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.25,
        fontFamily: fontFamily,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.29,
        fontFamily: fontFamily,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.33,
        fontFamily: fontFamily,
      ),

      // Title Styles
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AppColors.darkOnSurface,
        height: 1.27,
        fontFamily: fontFamily,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: AppColors.darkOnSurface,
        height: 1.50,
        fontFamily: fontFamily,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.darkOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),

      // Label Styles
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.darkOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.darkOnSurface,
        height: 1.33,
        fontFamily: fontFamily,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.darkOnSurface,
        height: 1.45,
        fontFamily: fontFamily,
      ),

      // Body Styles
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: AppColors.darkOnSurface,
        height: 1.50,
        fontFamily: fontFamily,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.darkOnSurface,
        height: 1.43,
        fontFamily: fontFamily,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.darkOnSurfaceVariant,
        height: 1.33,
        fontFamily: fontFamily,
      ),
    );
  }

  // Custom text styles for specific use cases

  // App Bar Title Style
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    fontFamily: fontFamily,
  );

  // Card Title Style
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Card Subtitle Style
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    fontFamily: fontFamily,
  );

  // Button Text Style
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: fontFamily,
  );

  // Caption Style
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Overline Style
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
    fontFamily: fontFamily,
  );

  // Form Label Style
  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: fontFamily,
  );

  // Error Text Style
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.error,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Success Text Style
  static const TextStyle successText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.success,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Status Chip Text Style
  static const TextStyle statusChip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    fontFamily: fontFamily,
  );

  // Grade Text Style
  static const TextStyle gradeText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.50,
    fontFamily: fontFamily,
  );

  // Navigation Label Style
  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Tab Label Style
  static const TextStyle tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    fontFamily: fontFamily,
  );

  // Course Code Style
  static const TextStyle courseCode = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    fontFamily: fontFamily,
  );

  // Assignment Title Style
  static const TextStyle assignmentTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
    fontFamily: fontFamily,
  );

  // Due Date Style
  static const TextStyle dueDate = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.38,
    fontFamily: fontFamily,
  );

  // Info Badge Style
  static const TextStyle infoBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.6,
    fontFamily: fontFamily,
  );
}
