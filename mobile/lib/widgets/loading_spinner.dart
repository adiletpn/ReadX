import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// The web's only loading indicator: a 24 pt ring, 2 pt thick, blue with a
/// transparent top quarter, spinning forever
/// (`border-2 border-[#0077FF] border-t-transparent animate-spin`).
class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key, this.size = 24, this.color = AppColors.primary});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
        // Leaves the rest of the ring visible at a quarter opacity gap, the
        // closest match to a transparent top border on a full circle.
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

/// Full-area loading state — what a list shows before its first response.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.padding = const EdgeInsets.symmetric(vertical: 80)});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: padding, child: const LoadingSpinner()),
    );
  }
}
