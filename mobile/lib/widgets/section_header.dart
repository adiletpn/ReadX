import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import 'pressable.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.primaryBright,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppText.overline.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rows stacked into one card with hairlines between them, the way iOS groups
/// a settings list. Separate cards for each row read as unrelated boxes.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.surfaceGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 52),
                child: Divider(height: 1, thickness: 1, color: AppColors.border),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint = AppColors.textSecondary,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color tint;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Pressable, not InkWell: the theme turns every Material ink effect off so
    // taps feel like the web's `active:opacity-60`, which would leave an
    // InkWell row with no touch feedback at all.
    return Pressable(
      onTap: onTap,
      pressedOpacity: 0.55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 13, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: tint == AppColors.danger
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  LucideIcons.chevronRight,
                  size: 17,
                  color: tint == AppColors.danger
                      ? AppColors.danger
                      : AppColors.textFaint,
                ),
          ],
        ),
      ),
    );
  }
}
