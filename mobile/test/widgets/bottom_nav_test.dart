import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/router.dart';
import 'package:readx/widgets/bottom_nav.dart';

Future<GoRouter> _pumpNavAt(WidgetTester tester, String location) async {
  Widget page(String label) => Scaffold(
        body: Center(child: Text(label)),
        bottomNavigationBar: const BottomNav(),
      );

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: AppRoutes.feed, builder: (_, _) => page('feed')),
      GoRoute(path: AppRoutes.habits, builder: (_, _) => page('habits')),
      GoRoute(path: AppRoutes.points, builder: (_, _) => page('points')),
      GoRoute(path: AppRoutes.profile, builder: (_, _) => page('profile')),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => page('settings')),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pumpAndSettle();
  return router;
}

Color _iconColour(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color!;

void main() {
  testWidgets('shows the four tabs the web has', (tester) async {
    await _pumpNavAt(tester, AppRoutes.feed);

    expect(find.byIcon(LucideIcons.house), findsOneWidget);
    expect(find.byIcon(LucideIcons.target), findsOneWidget);
    expect(find.byIcon(LucideIcons.trophy), findsOneWidget);
    expect(find.byIcon(LucideIcons.user), findsOneWidget);
  });

  testWidgets('the tab for the current route is the blue one', (tester) async {
    await _pumpNavAt(tester, AppRoutes.habits);

    expect(_iconColour(tester, LucideIcons.target), AppColors.primary);
    expect(_iconColour(tester, LucideIcons.house), AppColors.textMuted);
  });

  testWidgets('settings still highlights the profile tab', (tester) async {
    await _pumpNavAt(tester, AppRoutes.settings);

    expect(_iconColour(tester, LucideIcons.user), AppColors.primary);
  });

  testWidgets('tapping a tab navigates to it', (tester) async {
    final router = await _pumpNavAt(tester, AppRoutes.feed);

    await tester.tap(find.byIcon(LucideIcons.trophy));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRoutes.points);
    expect(_iconColour(tester, LucideIcons.trophy), AppColors.primary);
  });

  testWidgets('every tab carries its label for VoiceOver', (tester) async {
    await _pumpNavAt(tester, AppRoutes.feed);

    final labels = tester.widgetList<Icon>(find.byType(Icon)).map((i) => i.semanticLabel).toList();
    expect(labels, containsAll(<String>['Feed', 'Habits', 'Points', 'Profile']));
  });
}
