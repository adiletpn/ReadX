import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/app_switch.dart';

import '../helpers/harness.dart';

BoxDecoration _track(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;

void main() {
  testWidgets('keeps the 46 x 26 pill the web draws', (tester) async {
    await pumpWidgetUnderTest(tester, AppSwitch(value: false, onChanged: (_) {}));

    final size = tester.getSize(find.byType(AnimatedContainer));
    expect(size.width, 46);
    expect(size.height, 26);
  });

  testWidgets('the track is blue when on and grey when off', (tester) async {
    await pumpWidgetUnderTest(tester, AppSwitch(value: true, onChanged: (_) {}));
    expect(_track(tester).color, AppColors.primary);

    await pumpWidgetUnderTest(tester, AppSwitch(value: false, onChanged: (_) {}));
    expect(_track(tester).color, AppColors.surfaceHi2);
  });

  testWidgets('a tap reports the flipped value', (tester) async {
    bool? reported;
    await pumpWidgetUnderTest(tester, AppSwitch(value: false, onChanged: (v) => reported = v));

    await tester.tap(find.byType(AppSwitch));
    expect(reported, isTrue);
  });

  testWidgets('a disabled switch swallows the tap instead of desyncing', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      AppSwitch(value: false, enabled: false, onChanged: (_) => taps++),
    );

    await tester.tap(find.byType(AppSwitch));
    expect(taps, 0);

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.5);
  });

  testWidgets('a null callback also disables it', (tester) async {
    await pumpWidgetUnderTest(tester, const AppSwitch(value: true, onChanged: null));

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.5);
  });
}
