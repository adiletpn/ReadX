import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/spacing.dart';

void main() {
  group('AppMetrics', () {
    test('the content column is capped and padded like the web', () {
      expect(AppMetrics.contentWidth, 420);
      expect(AppMetrics.hPadding, 18);
    });

    test('the bars keep the heights the layout is built around', () {
      expect(AppMetrics.headerHeight, 56);
      expect(AppMetrics.bottomNavHeight, 64);
    });

    test('a scroll view clears the tab bar with room to spare', () {
      expect(AppMetrics.bottomContentPadding, greaterThan(AppMetrics.bottomNavHeight));
    });

    test('a toast floats above the tab bar', () {
      expect(AppMetrics.toastBottom, greaterThan(AppMetrics.bottomNavHeight));
    });

    test('the radii step down from hero to field', () {
      expect(AppMetrics.radiusHero, greaterThan(AppMetrics.radiusCard));
      expect(AppMetrics.radiusCard, greaterThan(AppMetrics.radiusField));
    });

    test('the chip radius is large enough to always read as a pill', () {
      expect(AppMetrics.radiusChip, greaterThanOrEqualTo(999));
    });

    test('the tab bar corners are softer than the item it highlights', () {
      expect(AppMetrics.radiusNav, greaterThan(AppMetrics.radiusNavItem));
      expect(AppMetrics.radiusNavItem, greaterThan(AppMetrics.radiusField * 0.8));
    });

    test('the content column still fits the narrowest iPhone after padding', () {
      const smallestPhone = 320.0;
      expect(AppMetrics.hPadding * 2, lessThan(smallestPhone / 2));
    });
  });

  group('AppDuration', () {
    test('the three speeds are ordered and stay under half a second', () {
      expect(AppDuration.fast, lessThan(AppDuration.medium));
      expect(AppDuration.medium, lessThan(AppDuration.slow));
      expect(AppDuration.slow.inMilliseconds, lessThanOrEqualTo(500));
    });

    test('the fastest feedback is still perceptible', () {
      expect(AppDuration.fast.inMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
