import 'package:flutter/painting.dart';

import 'colors.dart';
import 'spacing.dart';

abstract class AppSurfaces {
  static BoxDecoration card({
    double radius = AppMetrics.radiusCard,
    Color? borderColor,
    bool glow = false,
    Color glowColor = AppColors.glowPrimary,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.surfaceGradient,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: [
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
        if (glow)
          BoxShadow(
            color: glowColor,
            blurRadius: 34,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
      ],
    );
  }

  static BoxDecoration hero({List<Color> colors = AppColors.brandGradient}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(AppMetrics.radiusHero),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.32),
          blurRadius: 30,
          spreadRadius: -8,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration flat({
    double radius = AppMetrics.radiusField,
    Color color = AppColors.surface,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
    );
  }

  static const Gradient textBrand = LinearGradient(
    colors: AppColors.brandGradient,
  );

  static const Gradient textStreak = LinearGradient(
    colors: AppColors.streakGradient,
  );
}
