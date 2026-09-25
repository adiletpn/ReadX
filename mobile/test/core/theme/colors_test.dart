import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';

void main() {
  group('palette', () {
    test('the accent is the web #0077FF', () {
      expect(AppColors.primary.toARGB32(), 0xFF0077FF);
    });

    test('the dark surfaces stay in their intended order', () {
      final ladder = [
        AppColors.bg,
        AppColors.surface,
        AppColors.surfaceAlt,
        AppColors.surfaceHi,
        AppColors.surfaceHi2,
      ];

      for (var i = 1; i < ladder.length; i++) {
        expect(
          ladder[i].computeLuminance(),
          greaterThan(ladder[i - 1].computeLuminance()),
          reason: 'surface $i should be lighter than $i-1',
        );
      }
    });

    test('text shades run from white down to the faintest', () {
      final ladder = [
        AppColors.textPrimary,
        AppColors.textBody,
        AppColors.textSecondary,
        AppColors.textMuted,
        AppColors.textFaint,
        AppColors.textDisabled,
      ];

      for (var i = 1; i < ladder.length; i++) {
        expect(ladder[i].computeLuminance(), lessThan(ladder[i - 1].computeLuminance()));
      }
    });

    test('body text clears the WCAG AA ratio on the app background', () {
      double ratio(double a, double b) => (a + 0.05) / (b + 0.05);

      expect(
        ratio(AppColors.textBody.computeLuminance(), AppColors.bg.computeLuminance()),
        greaterThan(4.5),
      );
    });

    test('every status colour is fully opaque', () {
      for (final colour in [
        AppColors.danger,
        AppColors.success,
        AppColors.warning,
        AppColors.ember,
      ]) {
        expect(colour.a, 1.0);
      }
    });

    test('the tints carry the alpha their names promise', () {
      expect(AppColors.primary10.a, closeTo(0.1, 0.005));
      expect(AppColors.primary30.a, closeTo(0.3, 0.005));
      expect(AppColors.danger10.a, closeTo(0.1, 0.005));
      expect(AppColors.danger30.a, closeTo(0.3, 0.005));
    });

    test('the tints are the accent and the danger colour', () {
      expect(AppColors.primary10.toARGB32() & 0xFFFFFF, AppColors.primary.toARGB32() & 0xFFFFFF);
      expect(AppColors.danger30.toARGB32() & 0xFFFFFF, AppColors.danger.toARGB32() & 0xFFFFFF);
    });

    test('the gradients are two-stop and start from their base colour', () {
      expect(AppColors.brandGradient.length, 2);
      expect(AppColors.brandGradient.first, AppColors.primary);
      expect(AppColors.brandGradient.last, AppColors.cyan);

      expect(AppColors.streakGradient.first, AppColors.warning);
      expect(AppColors.streakGradient.last, AppColors.ember);
    });

    test('the glows are translucent so they read as light, not as fill', () {
      expect(AppColors.glowPrimary.a, lessThan(0.5));
      expect(AppColors.glowWarning.a, lessThan(0.5));
    });
  });
}
