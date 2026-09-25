import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/theme/colors.dart';

class BookStackIllustration extends StatelessWidget {
  const BookStackIllustration({super.key, this.size = 132});

  final double size;

  @override
  Widget build(BuildContext context) {
    final unit = size / 132;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.glowPrimary, Color(0x000077FF)],
              ),
            ),
          ),
          Positioned(
            bottom: 26 * unit,
            child: _Spine(
              width: 92 * unit,
              height: 17 * unit,
              angle: -0.06,
              colors: const [Color(0xFF2B3140), Color(0xFF1F242F)],
            ),
          ),
          Positioned(
            bottom: 41 * unit,
            child: _Spine(
              width: 82 * unit,
              height: 16 * unit,
              angle: 0.05,
              colors: AppColors.streakGradient,
            ),
          ),
          Positioned(
            bottom: 55 * unit,
            child: _Spine(
              width: 70 * unit,
              height: 16 * unit,
              angle: -0.04,
              colors: AppColors.brandGradient,
            ),
          ),
          Positioned(top: 12 * unit, right: 16 * unit, child: _Sparkle(size: 15 * unit)),
          Positioned(
            top: 34 * unit,
            left: 10 * unit,
            child: _Sparkle(size: 10 * unit, color: AppColors.warning),
          ),
          Positioned(
            top: 6 * unit,
            left: 40 * unit,
            child: _Sparkle(size: 7 * unit, color: AppColors.cyan),
          ),
        ],
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({
    required this.width,
    required this.height,
    required this.angle,
    required this.colors,
  });

  final double width;
  final double height;
  final double angle;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.32),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.30),
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: height * 0.34),
            width: height * 0.14,
            height: height * 0.52,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, this.color = AppColors.primaryBright});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter(color)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2;
    final waist = radius * 0.28;

    final path = Path();
    for (var i = 0; i < 4; i++) {
      final tip = i * math.pi / 2 - math.pi / 2;
      final next = tip + math.pi / 4;
      final tipPoint = Offset(
        centre.dx + radius * math.cos(tip),
        centre.dy + radius * math.sin(tip),
      );
      final waistPoint = Offset(
        centre.dx + waist * math.cos(next),
        centre.dy + waist * math.sin(next),
      );
      if (i == 0) {
        path.moveTo(tipPoint.dx, tipPoint.dy);
      } else {
        path.lineTo(tipPoint.dx, tipPoint.dy);
      }
      path.lineTo(waistPoint.dx, waistPoint.dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}
