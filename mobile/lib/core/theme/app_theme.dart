import 'package:flutter/cupertino.dart' show CupertinoThemeData;
import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// The app is dark-only, exactly like the web build — there is no light
/// palette to fall back to, so the theme is built once and forced via
/// `themeMode: ThemeMode.dark`.
abstract class AppTheme {
  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textPrimary,
      ),
      // The web signals taps with `active:opacity-60`, not with a ripple.
      // Turning the Material ink effects off keeps ports of those buttons
      // feeling native instead of Android-y.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary30,
        selectionHandleColor: AppColors.primary,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bg,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        bodyMedium: AppText.field,
        bodyLarge: AppText.body,
        titleMedium: AppText.action,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceHi2,
      ),
    );
  }
}
