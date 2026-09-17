import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// The inline toggle from the habit and settings cards: a 46 × 26 pill with a
/// 20 pt white knob, `#2A2A2A` when off and blue when on.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Off while a request is in flight — the settings and habit toggles are
  /// write-through, so a second tap mid-request would desync them.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: active ? 1 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 46,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : AppColors.surfaceHi2,
            borderRadius: BorderRadius.circular(13),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
