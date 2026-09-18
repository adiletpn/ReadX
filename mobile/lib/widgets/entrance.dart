import 'package:flutter/material.dart';

import '../core/theme/spacing.dart';

class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 18,
    this.stagger = const Duration(milliseconds: 45),
    this.maxStaggered = 8,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration stagger;
  final int maxStaggered;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDuration.medium,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, widget.maxStaggered);
    final delay = widget.stagger * steps;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
  });

  final int value;
  final TextStyle style;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppDuration.slow,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(
        '$prefix${animated.round()}',
        style: style,
      ),
    );
  }
}
