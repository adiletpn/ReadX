import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../core/theme/typography.dart';
import 'pressable.dart';

/// The 56 pt bar at the top of every screen: three slots laid out with
/// `space-between`, a hairline bottom border, and the status bar reserved
/// above it — the same structure as the web's `<header class="fixed top-0">`.
///
/// Slots that are left out become 40 pt spacers so the middle stays put, which
/// is what the placeholder `<div className="w-10" />` does in Header.tsx.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.title,
  }) : assert(middle == null || title == null, 'Pass either middle or title');

  final Widget? leading;

  /// Произвольный центральный слот (логотип).
  final Widget? middle;

  /// Заголовок 15/600 — короткая форма [middle].
  final String? title;

  final Widget? trailing;

  static const _slotWidth = 42.0;

  @override
  Size get preferredSize => const Size.fromHeight(AppMetrics.headerHeight);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      height: AppMetrics.headerHeight + topInset,
      padding: EdgeInsets.only(top: topInset, left: AppMetrics.hPadding, right: AppMetrics.hPadding),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading ?? const SizedBox(width: _slotWidth),
          if (middle != null)
            Flexible(child: middle!)
          else if (title != null)
            Flexible(
              child: Text(
                title!,
                style: AppText.action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const SizedBox.shrink(),
          trailing ?? const SizedBox(width: _slotWidth),
        ],
      ),
    );
  }
}

/// An icon sized and dimmed like the header buttons in the web app.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.size = 19,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}
