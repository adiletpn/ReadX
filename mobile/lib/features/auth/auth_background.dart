import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
        Positioned(
          top: -160,
          left: -90,
          child: _Blob(size: 380, colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0),
          ]),
        ),
        Positioned(
          bottom: -200,
          right: -120,
          child: _Blob(size: 420, colors: [
            AppColors.cyan.withValues(alpha: 0.16),
            AppColors.cyan.withValues(alpha: 0),
          ]),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
