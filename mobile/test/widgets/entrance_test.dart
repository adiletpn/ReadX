import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/widgets/entrance.dart';

import '../helpers/harness.dart';

double _opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.descendant(of: find.byType(Entrance), matching: find.byType(Opacity)))
        .opacity;

void main() {
  group('Entrance', () {
    testWidgets('fades and slides the first item in immediately', (tester) async {
      await pumpWidgetUnderTest(tester, const Entrance(child: Text('Пост')));

      expect(_opacity(tester), 0);

      await tester.pumpAndSettle();

      expect(_opacity(tester), 1);
      expect(find.text('Пост'), findsOneWidget);
    });

    testWidgets('a later item waits out its stagger before starting', (tester) async {
      await pumpWidgetUnderTest(tester, const Entrance(index: 3, child: Text('Пост')));

      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester), 0);

      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);
    });

    testWidgets('the stagger stops growing past maxStaggered', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const Entrance(index: 400, stagger: Duration(milliseconds: 10), child: Text('Пост')),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(_opacity(tester), 1);
    });

    testWidgets('disposing mid-delay does not throw', (tester) async {
      await pumpWidgetUnderTest(tester, const Entrance(index: 5, child: Text('Пост')));
      await pumpWidgetUnderTest(tester, const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });
  });

  group('AnimatedCounter', () {
    testWidgets('counts up from zero to the value', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnimatedCounter(value: 120, style: TextStyle(fontSize: 40)),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets('keeps the prefix in front of every frame', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnimatedCounter(value: 7, prefix: '+', style: TextStyle(fontSize: 40)),
      );

      expect(find.text('+0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('+7'), findsOneWidget);
    });

    testWidgets('zero points render as a plain zero', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnimatedCounter(value: 0, style: TextStyle(fontSize: 40)),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });
  });
}
