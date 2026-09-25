import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/core/theme/spacing.dart';
import 'package:readx/core/theme/surfaces.dart';

void main() {
  group('card', () {
    test('is the layered surface gradient with a hairline', () {
      final card = AppSurfaces.card();

      expect((card.gradient! as LinearGradient).colors, AppColors.surfaceGradient);
      expect((card.border! as Border).top.color, AppColors.border);
      expect(card.borderRadius, BorderRadius.circular(AppMetrics.radiusCard));
    });

    test('always carries its drop shadow', () {
      expect(AppSurfaces.card().boxShadow, hasLength(1));
    });

    test('the glow variant adds a second, coloured shadow', () {
      final glowing = AppSurfaces.card(glow: true);

      expect(glowing.boxShadow, hasLength(2));
      expect(glowing.boxShadow!.last.color, AppColors.glowPrimary);
    });

    test('the glow colour and radius can be overridden per card', () {
      final warm = AppSurfaces.card(
        glow: true,
        glowColor: AppColors.glowWarning,
        radius: AppMetrics.radiusHero,
        borderColor: AppColors.borderBright,
      );

      expect(warm.boxShadow!.last.color, AppColors.glowWarning);
      expect(warm.borderRadius, BorderRadius.circular(AppMetrics.radiusHero));
      expect((warm.border! as Border).top.color, AppColors.borderBright);
    });
  });

  group('hero', () {
    test('paints the brand gradient at the hero radius', () {
      final hero = AppSurfaces.hero();

      expect((hero.gradient! as LinearGradient).colors, AppColors.brandGradient);
      expect(hero.borderRadius, BorderRadius.circular(AppMetrics.radiusHero));
    });

    test('its shadow is tinted from the gradient it was given', () {
      final streak = AppSurfaces.hero(colors: AppColors.streakGradient);

      expect(
        streak.boxShadow!.single.color.toARGB32() & 0xFFFFFF,
        AppColors.warning.toARGB32() & 0xFFFFFF,
      );
    });

    test('a hero has no border, only light', () {
      expect(AppSurfaces.hero().border, isNull);
    });
  });

  group('flat', () {
    test('is a plain fill with a hairline and no shadow', () {
      final flat = AppSurfaces.flat();

      expect(flat.color, AppColors.surface);
      expect(flat.gradient, isNull);
      expect(flat.boxShadow, isNull);
      expect(flat.borderRadius, BorderRadius.circular(AppMetrics.radiusField));
    });

    test('the fill and border can be overridden', () {
      final done = AppSurfaces.flat(
        color: AppColors.habitDoneBg,
        borderColor: AppColors.habitDoneBorder,
      );

      expect(done.color, AppColors.habitDoneBg);
      expect((done.border! as Border).top.color, AppColors.habitDoneBorder);
    });
  });

  group('text gradients', () {
    test('mirror the palette gradients', () {
      expect((AppSurfaces.textBrand as LinearGradient).colors, AppColors.brandGradient);
      expect((AppSurfaces.textStreak as LinearGradient).colors, AppColors.streakGradient);
    });
  });
}
