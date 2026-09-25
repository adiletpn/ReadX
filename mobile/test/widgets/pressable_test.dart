import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/widgets/pressable.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('reports a tap', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      Pressable(onTap: () => taps++, child: const SizedBox(width: 100, height: 40)),
    );

    await tester.tap(find.byType(Pressable));
    expect(taps, 1);
  });

  testWidgets('reports a long press', (tester) async {
    var presses = 0;
    await pumpWidgetUnderTest(
      tester,
      Pressable(onLongPress: () => presses++, child: const SizedBox(width: 100, height: 40)),
    );

    await tester.longPress(find.byType(Pressable));
    expect(presses, 1);
  });

  testWidgets('dims and shrinks while held down', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      Pressable(
        scale: 0.96,
        pressedOpacity: 0.7,
        onTap: () {},
        child: const SizedBox(width: 100, height: 40),
      ),
    );

    final gesture = await tester.press(find.byType(Pressable));
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 0.96);
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0.7);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);
  });

  testWidgets('a pressable with no callbacks never animates', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      const Pressable(scale: 0.9, child: SizedBox(width: 100, height: 40)),
    );

    final gesture = await tester.press(find.byType(Pressable));
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);
    await gesture.up();
  });
}
