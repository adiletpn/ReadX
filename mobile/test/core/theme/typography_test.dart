import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/core/theme/typography.dart';

void main() {
  group('type scale', () {
    test('runs from the display size down to the smallest meta', () {
      final sizes = [
        AppText.display.fontSize!,
        AppText.counter.fontSize!,
        AppText.counterMd.fontSize!,
        AppText.counterSm.fontSize!,
        AppText.h1.fontSize!,
        AppText.modalTitle.fontSize!,
        AppText.cardTitle.fontSize!,
        AppText.body.fontSize!,
        AppText.commentBody.fontSize!,
        AppText.caption.fontSize!,
        AppText.meta.fontSize!,
        AppText.metaSm.fontSize!,
      ];

      for (var i = 1; i < sizes.length; i++) {
        expect(sizes[i], lessThanOrEqualTo(sizes[i - 1]), reason: 'step $i');
      }
    });

    test('nothing drops below 11 pt', () {
      expect(AppText.metaSm.fontSize, greaterThanOrEqualTo(11));
      expect(AppText.overline.fontSize, greaterThanOrEqualTo(11));
    });
  });

  group('numerals', () {
    test('every style that shows a number uses tabular figures', () {
      const numeric = [
        AppText.display,
        AppText.counter,
        AppText.counterMd,
        AppText.counterSm,
        AppText.meta,
        AppText.metaSm,
      ];

      for (final style in numeric) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('the big counters are tightened so they do not look airy', () {
      expect(AppText.display.letterSpacing, lessThan(0));
      expect(AppText.counter.letterSpacing, lessThan(0));
      expect(AppText.display.height, 1.0);
    });
  });

  group('colours', () {
    test('headlines are white and captions are the secondary grey', () {
      expect(AppText.h1.color, AppColors.textPrimary);
      expect(AppText.cardTitle.color, AppColors.textPrimary);
      expect(AppText.caption.color, AppColors.textSecondary);
      expect(AppText.commentBody.color, AppColors.textBody);
      expect(AppText.metaSm.color, AppColors.textMuted);
    });
  });

  group('weights', () {
    test('counters are the heaviest and body text is regular', () {
      expect(AppText.counter.fontWeight, FontWeight.w800);
      expect(AppText.h1.fontWeight, FontWeight.w700);
      expect(AppText.cardTitle.fontWeight, FontWeight.w600);
      expect(AppText.body.fontWeight, isNull);
    });

    test('the overline is spaced out, unlike everything else', () {
      expect(AppText.overline.letterSpacing, greaterThan(1));
    });
  });

  group('reading comfort', () {
    test('multi-line styles carry a line height above 1.4', () {
      expect(AppText.body.height, greaterThanOrEqualTo(1.4));
      expect(AppText.commentBody.height, greaterThanOrEqualTo(1.4));
    });
  });
}
