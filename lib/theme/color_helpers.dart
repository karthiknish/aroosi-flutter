import 'package:flutter/material.dart';
import 'colors.dart';

/// Helper methods for common color operations using AppColors
class ColorHelpers {
  ColorHelpers._();

  /// Get white color for overlays (uses AppColors.onPrimary for consistency)
  static Color get white => AppColors.onPrimary;

  /// Get black color for overlays (uses AppColors.text for consistency)
  static Color get black => AppColors.text;

  /// Get transparent color
  static Color get transparent => Colors.transparent;

  /// Get white with alpha for text overlays on images
  static Color whiteWithAlpha(double alpha) {
    return AppColors.onPrimary.withValues(alpha: alpha);
  }

  /// Get black with alpha for overlays
  static Color blackWithAlpha(double alpha) {
    return AppColors.text.withValues(alpha: alpha);
  }

  /// Get primary color with alpha
  static Color primaryWithAlpha(double alpha) {
    return AppColors.primary.withValues(alpha: alpha);
  }

  /// Get error color with alpha
  static Color errorWithAlpha(double alpha) {
    return AppColors.error.withValues(alpha: alpha);
  }

  /// Get success color with alpha
  static Color successWithAlpha(double alpha) {
    return AppColors.success.withValues(alpha: alpha);
  }

  /// Get muted color with alpha
  static Color mutedWithAlpha(double alpha) {
    return AppColors.muted.withValues(alpha: alpha);
  }

  /// Get background color with alpha
  static Color backgroundWithAlpha(double alpha) {
    return AppColors.background.withValues(alpha: alpha);
  }

  /// Get gradient colors for image overlays (dark to transparent)
  static List<Color> imageOverlayGradient({double startAlpha = 0.65, double endAlpha = 0.1}) {
    return [
      AppColors.text.withValues(alpha: startAlpha),
      AppColors.text.withValues(alpha: endAlpha),
    ];
  }

  /// Get gradient colors for bottom overlay (darker)
  static List<Color> bottomOverlayGradient({double startAlpha = 0.7, double endAlpha = 0.2}) {
    return [
      AppColors.text.withValues(alpha: startAlpha),
      AppColors.text.withValues(alpha: endAlpha),
    ];
  }

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'success':
        return AppColors.success;
      case 'pending':
      case 'warning':
        return AppColors.warning;
      case 'rejected':
      case 'error':
      case 'failed':
        return AppColors.error;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.muted;
    }
  }

  /// Get match status color
  static Color getMatchStatusColor({
    required bool isMutual,
    required String status,
    required bool isBlocked,
  }) {
    if (isMutual) return AppColors.primary;
    if (isBlocked) return AppColors.muted;
    if (status == 'pending') return AppColors.secondary;
    return AppColors.primary;
  }

  /// Get interest status color
  static Color getInterestStatusColor({
    required bool isMutual,
    required bool isFamilyApproved,
    required String status,
  }) {
    if (isMutual) return AppColors.primary;
    if (isFamilyApproved) return AppColors.secondary;
    return getStatusColor(status);
  }

  /// Get compatibility score color
  static Color getCompatibilityColor(int score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }
}

