import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/gradient_text.dart';
import 'package:readx/widgets/readx_logo.dart';

import '../helpers/harness.dart';

void main() {
  group('GradientText', () {
    testWidgets('renders the text through a shader', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const GradientText(
          '1 250',
          style: TextStyle(fontSize: 40),
          gradient: LinearGradient(colors: AppColors.brandGradient),
        ),
      );

      expect(find.text('1 250'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('paints only the glyphs, not the box behind them', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const GradientText(
          'Streak',
          style: TextStyle(fontSize: 22),
          gradient: LinearGradient(colors: AppColors.streakGradient),
        ),
      );

      expect(tester.widget<ShaderMask>(find.byType(ShaderMask)).blendMode, BlendMode.srcIn);
    });

    testWidgets('passes the alignment through to the text', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const GradientText(
          'ReadX',
          style: TextStyle(fontSize: 18),
          gradient: LinearGradient(colors: AppColors.brandGradient),
          textAlign: TextAlign.center,
        ),
      );

      expect(tester.widget<Text>(find.byType(Text)).textAlign, TextAlign.center);
    });
  });

  group('ReadXLogo', () {
    testWidgets('keeps the wordmark aspect ratio when only the height is set', (tester) async {
      await pumpWidgetUnderTest(tester, const ReadXLogo(height: 36));

      final size = tester.getSize(find.byType(ReadXLogo));
      expect(size.height, 36);
      expect(size.width, closeTo(196.474, 0.01));
    });

    testWidgets('defaults to the 20 pt header size', (tester) async {
      await pumpWidgetUnderTest(tester, const ReadXLogo());

      expect(tester.getSize(find.byType(ReadXLogo)).height, 20);
    });
  });
}
