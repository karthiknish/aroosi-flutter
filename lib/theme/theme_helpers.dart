import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

/// Utilities for bridging between Cupertino and Material theming.
class CupertinoThemeHelpers {
  CupertinoThemeHelpers._();

  /// Safely resolve the active [CupertinoThemeData], falling back to the
  /// app's configured theme when running outside a [CupertinoApp] scope.
  static CupertinoThemeData getMaterialTheme(BuildContext context) {
    try {
      return CupertinoTheme.of(context);
    } catch (_) {
      return buildCupertinoTheme();
    }
  }
}

/// Helper methods for accessing theme consistently across the app.
class ThemeHelpers {
  ThemeHelpers._();

  /// Retrieve a [ThemeData] backed by the current Cupertino theme so Material
  /// widgets carry the same visual language.
  static ThemeData getMaterialTheme(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    final brightness = cupertinoTheme.brightness ?? Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: cupertinoTheme.primaryColor,
      brightness: brightness,
    ).copyWith(
      surface: cupertinoTheme.barBackgroundColor,
      primary: cupertinoTheme.primaryColor,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cupertinoTheme.scaffoldBackgroundColor,
      textTheme: TextTheme(
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.caption,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
      ),
    );
  }

  /// Primary text color derived from the active theme.
  static Color getTextColor(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.brightness == Brightness.dark
      ? AppColors.onDark
      : AppColors.text;
  }

  /// Muted/secondary text color.
  static Color getMutedTextColor(BuildContext context) {
    return AppColors.muted;
  }

  /// Scaffold background color.
  static Color getBackgroundColor(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.scaffoldBackgroundColor;
  }

  /// Surface color for cards and sheets.
  static Color getSurfaceColor(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.barBackgroundColor;
  }

  /// Primary accent color.
  static Color getPrimaryColor(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.primaryColor;
  }

  /// Base text style for Cupertino typography.
  static TextStyle? getTextStyle(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.textTheme.textStyle;
  }

  /// Title text style for navigation bars.
  static TextStyle? getNavTitleStyle(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.textTheme.navTitleTextStyle;
  }

  /// Large title text style for navigation bars.
  static TextStyle? getNavLargeTitleStyle(BuildContext context) {
    final cupertinoTheme = CupertinoThemeHelpers.getMaterialTheme(context);
    return cupertinoTheme.textTheme.navLargeTitleTextStyle;
  }
}

