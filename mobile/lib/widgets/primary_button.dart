import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import 'pressable.dart';

/// The full-width blue action button repeated on nearly every screen:
/// `py-4 rounded-2xl text-[15px] font-semibold`, blue when it can be pressed
/// and `#1A1A1A` / `#3A3A3A` when it cannot.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.icon,
    this.color = AppColors.primary,
    this.textColor = AppColors.textPrimary,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Явное отключение — например, пока поле пустое.
  final bool enabled;

  /// While a request is in flight the button is inert, which is also the
  /// double-tap guard for the toggle endpoints (like, follow, complete, join).
  final bool loading;

  final IconData? icon;
  final Color color;
  final Color textColor;

  bool get _active => enabled && !loading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _active ? onPressed : null,
      pressedOpacity: 0.8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _active ? color : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: _active ? textColor : AppColors.textDisabled),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _active ? textColor : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
