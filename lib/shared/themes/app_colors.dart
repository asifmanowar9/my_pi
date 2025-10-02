import 'package:flutter/material.dart';

/// AppColors - Comprehensive color system for My Pi app
/// Contains primary, secondary, accent colors and status indicator colors
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryDark = Color(0xFF9575CD);
  static const Color primaryContainer = Color(0xFFE8DEF8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Secondary Colors
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryDark = Color(0xFF7986CB);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  // Accent/Tertiary Colors
  static const Color accent = Color(0xFF7D5260);
  static const Color accentDark = Color(0xFFEFB8C8);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // Error Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF81C784);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);

  // Info Colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF64B5F6);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Light Theme Surface Colors
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  // Dark Theme Surface Colors
  static const Color darkSurface = Color(0xFF141218);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurface = Color(0xFFE6E0E9);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkBackground = Color(0xFF141218);
  static const Color darkOnBackground = Color(0xFFE6E0E9);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  // Status Indicator Colors for App States
  /// Pending state color (orange/amber)
  static const Color pending = Color(0xFFFF8F00);
  static const Color pendingContainer = Color(0xFFFFF3E0);
  static const Color onPending = Color(0xFFFFFFFF);
  static const Color onPendingContainer = Color(0xFFE65100);

  /// Completed state color (green)
  static const Color completed = Color(0xFF2E7D32);
  static const Color completedContainer = Color(0xFFE8F5E8);
  static const Color onCompleted = Color(0xFFFFFFFF);
  static const Color onCompletedContainer = Color(0xFF1B5E20);

  /// Overdue state color (red)
  static const Color overdue = Color(0xFFD32F2F);
  static const Color overdueContainer = Color(0xFFFFEBEE);
  static const Color onOverdue = Color(0xFFFFFFFF);
  static const Color onOverdueContainer = Color(0xFFB71C1C);

  /// In Progress state color (blue)
  static const Color inProgress = Color(0xFF1976D2);
  static const Color inProgressContainer = Color(0xFFE3F2FD);
  static const Color onInProgress = Color(0xFFFFFFFF);
  static const Color onInProgressContainer = Color(0xFF0D47A1);

  /// Draft state color (gray)
  static const Color draft = Color(0xFF616161);
  static const Color draftContainer = Color(0xFFF5F5F5);
  static const Color onDraft = Color(0xFFFFFFFF);
  static const Color onDraftContainer = Color(0xFF212121);

  /// Archived state color (purple-gray)
  static const Color archived = Color(0xFF6A4C93);
  static const Color archivedContainer = Color(0xFFF3E5F5);
  static const Color onArchived = Color(0xFFFFFFFF);
  static const Color onArchivedContainer = Color(0xFF4A148C);

  // Grade/Score Colors
  static const Color gradeA = Color(0xFF4CAF50); // Green - Excellent
  static const Color gradeB = Color(0xFF8BC34A); // Light Green - Good
  static const Color gradeC = Color(0xFFFFEB3B); // Yellow - Average
  static const Color gradeD = Color(0xFFFF9800); // Orange - Below Average
  static const Color gradeF = Color(0xFFF44336); // Red - Fail

  // Priority Colors
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1F000000);

  // Helper methods for status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'completed':
        return completed;
      case 'overdue':
        return overdue;
      case 'in_progress':
      case 'in-progress':
        return inProgress;
      case 'draft':
        return draft;
      case 'archived':
        return archived;
      default:
        return info;
    }
  }

  static Color getStatusContainerColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingContainer;
      case 'completed':
        return completedContainer;
      case 'overdue':
        return overdueContainer;
      case 'in_progress':
      case 'in-progress':
        return inProgressContainer;
      case 'draft':
        return draftContainer;
      case 'archived':
        return archivedContainer;
      default:
        return infoContainer;
    }
  }

  static Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
      case 'A-':
        return gradeA;
      case 'B':
      case 'B+':
      case 'B-':
        return gradeB;
      case 'C':
      case 'C+':
      case 'C-':
        return gradeC;
      case 'D':
      case 'D+':
      case 'D-':
        return gradeD;
      case 'F':
        return gradeF;
      default:
        return info;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return info;
    }
  }
}
