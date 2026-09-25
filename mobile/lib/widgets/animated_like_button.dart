import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme/colors.dart';

/// Heart plus counter, with the bounce and the ring of sparks the web plays
/// when a post is liked: the heart runs 1 → 1.3 → 0.95 → 1.1 → 1 over 400 ms
/// and eight dots spin outwards over 600 ms.
///
/// [busy] disables the tap while the request is in flight. These endpoints are
/// toggles, so a double tap would silently undo the like.
class AnimatedLikeButton extends StatefulWidget {
  const AnimatedLikeButton({
    super.key,
    required this.liked,
    required this.likes,
    required this.onTap,
    this.size = 18,
    this.busy = false,
  });

  final bool liked;
  final int likes;
  final VoidCallback onTap;
  final double size;
  final bool busy;

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.95), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.1), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    // The heart settles at 400 ms; the remaining third of the controller is
    // the sparks fading out.
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
  ]).animate(_controller);

  @override
  void didUpdateWidget(AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liked && !oldWidget.liked) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.liked ? AppColors.danger : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.busy ? null : widget.onTap,
      child: Opacity(
        opacity: widget.busy ? 0.6 : 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (_controller.isAnimating)
                      CustomPaint(
                        size: Size(widget.size * 2, widget.size * 2),
                        painter: _SparklePainter(progress: _controller.value),
                      ),
                    Transform.scale(scale: _scale.value, child: child),
                  ],
                ),
                child: _Heart(size: widget.size, color: color, filled: widget.liked),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${widget.likes}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.liked ? FontWeight.w500 : FontWeight.normal,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lucide's heart, drawn from its path rather than from the icon font: the web
/// fills the same outline red when a post is liked (`fill-[#FF3B30]`), and a
/// font glyph cannot be filled and stroked independently.
class _Heart extends StatelessWidget {
  const _Heart({required this.size, required this.color, required this.filled});

  final double size;
  final Color color;
  final bool filled;

  static const _path =
      'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2'
      '-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z';

  String get _hex {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hex = _hex;
    final fill = filled ? hex : 'none';
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$fill" '
      'stroke="$hex" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="$_path"/></svg>',
      width: size,
      height: size,
    );
  }
}

/// Eight dots on a circle that expand and spin as they fade — the SVG the web
/// animates with `animate-sparkle-spin`.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress});

  final double progress;

  static const _dots = <(double angle, double radius, Color color, double opacity)>[
    (-math.pi / 2, 3, AppColors.danger, 0.8),
    (0, 2.5, AppColors.warning, 0.6),
    (math.pi / 2, 3, AppColors.danger, 0.8),
    (math.pi, 2.5, AppColors.warning, 0.6),
    (-3 * math.pi / 4, 2, Color(0xFFFF2D55), 0.7),
    (-math.pi / 4, 1.5, AppColors.danger, 0.9),
    (3 * math.pi / 4, 1.5, AppColors.warning, 0.7),
    (math.pi / 4, 2, Color(0xFFFF2D55), 0.9),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final spread = size.width / 2 * (0.3 + progress * 0.7);
    final spin = progress * math.pi / 2;
    final fade = (1 - progress).clamp(0.0, 1.0);
    final scale = size.width / 100;

    for (final (angle, radius, color, opacity) in _dots) {
      final offset = Offset(
        centre.dx + spread * math.cos(angle + spin),
        centre.dy + spread * math.sin(angle + spin),
      );
      canvas.drawCircle(
        offset,
        radius * scale * 2,
        Paint()..color = color.withValues(alpha: opacity * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.progress != progress;
}
