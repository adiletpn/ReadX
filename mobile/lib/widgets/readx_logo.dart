import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The wordmark, exported from the same SVG paths the web renders
/// (src/imports/svg-xb8gue966q.ts) so the white → #0077FF → white gradient is
/// identical. The artwork is 196.474 × 36, and only the height is ever set —
/// width follows the aspect ratio.
class ReadXLogo extends StatelessWidget {
  const ReadXLogo({super.key, this.height = 20});

  static const _aspectRatio = 196.474 / 36;

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/readx_logo.svg',
      height: height,
      width: height * _aspectRatio,
      fit: BoxFit.contain,
    );
  }
}
