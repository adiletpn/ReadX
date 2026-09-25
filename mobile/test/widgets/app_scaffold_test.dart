import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/core/theme/spacing.dart';
import 'package:readx/widgets/app_scaffold.dart';
import 'package:readx/widgets/offline_banner.dart';

Future<void> _pump(WidgetTester tester, AppScaffold scaffold, {Size size = const Size(390, 844)}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: scaffold)),
  );
}

void main() {
  testWidgets('paints the app background', (tester) async {
    await _pump(tester, const AppScaffold(body: SizedBox.shrink()));

    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, AppColors.bg);
  });

  testWidgets('caps the content column and centres it on a wide screen', (tester) async {
    await _pump(
      tester,
      const AppScaffold(body: SizedBox.expand()),
      size: const Size(1024, 1366),
    );

    final box = tester.widget<ConstrainedBox>(
      find.descendant(of: find.byType(Center), matching: find.byType(ConstrainedBox)).first,
    );
    expect(box.constraints.maxWidth, AppMetrics.contentWidth);

    final column = tester.getRect(find.byType(Column).first);
    expect(column.width, AppMetrics.contentWidth);
    expect(column.center.dx, closeTo(512, 0.5));
  });

  testWidgets('every screen gets the offline banner for free', (tester) async {
    await _pump(tester, const AppScaffold(body: SizedBox.shrink()));

    expect(find.byType(OfflineBanner), findsOneWidget);
  });

  testWidgets('header, body, pinned bar and nav are stacked in that order', (tester) async {
    await _pump(
      tester,
      const AppScaffold(
        header: SizedBox(height: 56, child: Text('header')),
        body: Center(child: Text('body')),
        bottomBar: SizedBox(height: 60, child: Text('bar')),
        bottomNav: SizedBox(height: 68, child: Text('nav')),
      ),
    );

    final header = tester.getRect(find.text('header')).center.dy;
    final body = tester.getRect(find.text('body')).center.dy;
    final bar = tester.getRect(find.text('bar')).center.dy;
    final nav = tester.getRect(find.text('nav')).center.dy;

    expect(header, lessThan(body));
    expect(body, lessThan(bar));
    expect(bar, lessThan(nav));
  });

  testWidgets('the action button floats over the body', (tester) async {
    await _pump(
      tester,
      const AppScaffold(
        body: SizedBox.expand(),
        floatingActionButton: SizedBox(width: 56, height: 56, child: Text('+')),
      ),
    );

    expect(find.byType(Stack), findsWidgets);
    expect(find.text('+'), findsOneWidget);
  });

  testWidgets('a screen with no bars still lays out', (tester) async {
    await _pump(tester, const AppScaffold(body: Center(child: Text('body'))));

    expect(find.text('body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
