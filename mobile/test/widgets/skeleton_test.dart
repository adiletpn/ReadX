import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/widgets/skeleton.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('a skeleton block keeps the size it was given', (tester) async {
    await pumpWidgetUnderTest(tester, const Skeleton(width: 110, height: 13));

    final size = tester.getSize(find.byType(Skeleton));
    expect(size.width, 110);
    expect(size.height, 13);
  });

  testWidgets('the circle variant is square and fully rounded', (tester) async {
    await pumpWidgetUnderTest(tester, const Skeleton.circle(size: 42));

    final size = tester.getSize(find.byType(Skeleton));
    expect(size.width, 42);
    expect(size.height, 42);

    final decoration =
        tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(21));
  });

  testWidgets('the shimmer keeps animating', (tester) async {
    await pumpWidgetUnderTest(tester, const Skeleton(width: 100, height: 12));

    final first = (tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration)
        .gradient! as LinearGradient;
    await tester.pump(const Duration(milliseconds: 400));
    final later = (tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration)
        .gradient! as LinearGradient;

    expect(later.begin, isNot(first.begin));
  });

  testWidgets('the feed placeholder draws one row per pending post', (tester) async {
    await pumpWidgetUnderTest(tester, const FeedSkeleton(count: 3));

    expect(find.byType(PostSkeleton), findsNWidgets(3));
  });

  testWidgets('the list placeholder draws one card per pending row', (tester) async {
    await pumpWidgetUnderTest(tester, const ListSkeleton(count: 4));

    expect(find.byType(CardSkeleton), findsNWidgets(4));
  });

  testWidgets('each row down the list is fainter than the one above', (tester) async {
    await pumpWidgetUnderTest(tester, const FeedSkeleton(count: 3));

    final opacities = tester
        .widgetList<Opacity>(find.ancestor(of: find.byType(PostSkeleton), matching: find.byType(Opacity)))
        .map((o) => o.opacity)
        .toList();

    expect(opacities.first, greaterThan(opacities.last));
  });
}
