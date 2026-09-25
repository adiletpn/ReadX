import 'package:flutter/widgets.dart';

import '../core/theme/colors.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
          const Positioned(
            top: -250,
            left: -170,
            child: _Glow(size: 480, color: AppColors.primary, opacity: 0.20),
          ),
          const Positioned(
            top: 60,
            right: -210,
            child: _Glow(size: 420, color: AppColors.cyan, opacity: 0.10),
          ),
          const Positioned(
            bottom: -260,
            left: -120,
            child: _Glow(size: 460, color: AppColors.primaryDeep, opacity: 0.16),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.35),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ),
    );
  }
}
