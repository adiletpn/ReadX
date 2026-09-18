import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = size / 2;

  final double width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 - 2 * (1 - t), 0),
              colors: const [
                AppColors.surfaceHi,
                AppColors.surfaceHi2,
                AppColors.surfaceHi,
              ],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.hPadding,
        16,
        AppMetrics.hPadding,
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton.circle(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Skeleton(width: 110, height: 13),
                    const Spacer(),
                    const Skeleton(width: 46, height: 11),
                  ],
                ),
                const SizedBox(height: 12),
                const Skeleton(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                const Skeleton(width: 190, height: 12),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Skeleton(width: 44, height: 14, radius: 7),
                    SizedBox(width: 18),
                    Skeleton(width: 44, height: 14, radius: 7),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Opacity(opacity: 1 - i * 0.14, child: const PostSkeleton()),
      ],
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.height = 108});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Skeleton(
        width: double.infinity,
        height: height,
        radius: AppMetrics.radiusCard,
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.count = 4, this.height = 108});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMetrics.hPadding),
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Opacity(opacity: 1 - i * 0.16, child: CardSkeleton(height: height)),
        ],
      ),
    );
  }
}
