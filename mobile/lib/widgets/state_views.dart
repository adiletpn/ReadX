import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../core/theme/typography.dart';
import 'empty_illustration.dart';
import 'pressable.dart';

/// Inline error block used on forms: `bg-[#FF3B30]/10`, a 30 % red hairline,
/// 13 pt red text.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger10,
        borderRadius: BorderRadius.circular(AppMetrics.radiusField),
        border: Border.all(color: AppColors.danger30),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.danger),
      ),
    );
  }
}

/// Failure state for a screen that could not load: the server's own message
/// plus a retry. Every list screen shows this instead of a blank page.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Повторить',
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger10,
                border: Border.all(color: AppColors.danger30),
              ),
              child: const Icon(LucideIcons.triangleAlert, size: 26, color: AppColors.danger),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Pressable(
              onTap: onRetry,
              scale: 0.96,
              pressedOpacity: 0.85,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.glowPrimary,
                      blurRadius: 22,
                      spreadRadius: -6,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state: an optional 64 pt circle with an icon, a white headline and a
/// grey line under it — the shape the feed, habits and notifications screens
/// all use.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.illustrated = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  /// Заменяет кружок с иконкой на стопку книг — для главных пустых экранов,
  /// где, кроме этого блока, на странице нет ничего.
  final bool illustrated;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustrated) ...[
              const BookStackIllustration(),
              const SizedBox(height: 16),
            ] else if (icon != null) ...[
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.surfaceGradient,
                  ),
                  border: Border.all(color: AppColors.borderBright),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.glowPrimary,
                      blurRadius: 32,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Icon(icon, size: 30, color: AppColors.primaryBright),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center, style: AppText.caption),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Green confirmation block used by the password-recovery screens:
/// `bg-[#22C55E]/10` with a 30 % green hairline and 14 pt green text.
class AppSuccessBanner extends StatelessWidget {
  const AppSuccessBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x1A22C55E),
        borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
        border: Border.all(color: const Color(0x4D22C55E)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.success),
      ),
    );
  }
}
