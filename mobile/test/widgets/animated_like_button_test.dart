import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/animated_like_button.dart';

import '../helpers/harness.dart';

int _paintCount(WidgetTester tester) => tester
    .widgetList(find.descendant(of: find.byType(Stack), matching: find.byType(CustomPaint)))
    .length;

void main() {
  testWidgets('shows the like count next to the heart', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 12, onTap: () {}),
    );

    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('the count turns red once the post is liked', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 3, onTap: () {}),
    );
    expect(tester.widget<Text>(find.text('3')).style?.color, AppColors.textSecondary);

    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: true, likes: 4, onTap: () {}),
    );
    expect(tester.widget<Text>(find.text('4')).style?.color, AppColors.danger);

    await tester.pumpAndSettle();
  });

  testWidgets('a tap is reported once', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 0, onTap: () => taps++),
    );

    await tester.tap(find.byType(AnimatedLikeButton));
    expect(taps, 1);
  });

  testWidgets('a busy button ignores the second tap so the like is not undone', (tester) async {
    var taps = 0;
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 0, busy: true, onTap: () => taps++),
    );

    await tester.tap(find.byType(AnimatedLikeButton));
    await tester.tap(find.byType(AnimatedLikeButton));
    expect(taps, 0);

    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0.6);
  });

  testWidgets('the burst plays when the post becomes liked and then stops', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 3, onTap: () {}),
    );
    final resting = _paintCount(tester);

    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: true, likes: 4, onTap: () {}),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_paintCount(tester), greaterThan(resting));

    await tester.pumpAndSettle();
    expect(_paintCount(tester), resting);
  });

  testWidgets('unliking does not replay the burst', (tester) async {
    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: true, likes: 4, onTap: () {}),
    );
    await tester.pumpAndSettle();
    final resting = _paintCount(tester);

    await pumpWidgetUnderTest(
      tester,
      AnimatedLikeButton(liked: false, likes: 3, onTap: () {}),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(_paintCount(tester), resting);
  });
}
