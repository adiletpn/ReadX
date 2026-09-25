import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/features/profile/profile_widgets.dart';
import 'package:readx/models/post.dart';
import 'package:readx/models/shared_habit.dart';
import 'package:readx/router.dart';
import 'package:readx/widgets/app_header.dart';
import 'package:readx/widgets/bottom_nav.dart';
import 'package:readx/widgets/post_card.dart';
import 'package:readx/widgets/readx_logo.dart';
import 'package:readx/widgets/section_header.dart';
import 'package:readx/widgets/shared_habit_card.dart';
import 'package:readx/widgets/state_views.dart';

import 'helpers/harness.dart';

/// The smallest screen the app supports. Anything that overflows does it here
/// first, and an overflow is a red-striped box in front of the user.
const _se = Size(320, 568);

void main() {
  group('on a 4.7 inch screen', () {
    testWidgets('the tab bar fits four labelled tabs', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.feed,
        routes: [
          for (final path in AppRoutes.bottomNavPaths)
            GoRoute(
              path: path,
              builder: (_, _) => const Scaffold(bottomNavigationBar: BottomNav()),
            ),
        ],
      );
      addTearDown(router.dispose);

      await tester.binding.setSurfaceSize(_se);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      for (final label in ['Feed', 'Habits', 'Points', 'Profile']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('the header holds the wordmark plus three buttons', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        AppHeader(
          leading: HeaderIconButton(icon: LucideIcons.menu, onTap: () {}),
          middle: const ReadXLogo(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeaderIconButton(icon: LucideIcons.bell, onTap: () {}),
              HeaderIconButton(icon: LucideIcons.search, onTap: () {}),
            ],
          ),
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the profile stat grid fits six tiles', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SingleChildScrollView(
          child: StatGrid(
            tiles: [
              StatTile(
                label: 'Total Points',
                value: '128400',
                icon: LucideIcons.sparkles,
                gradient: AppColors.brandGradient,
              ),
              StatTile(
                label: 'Current Streak',
                value: '365',
                icon: LucideIcons.flame,
                gradient: AppColors.streakGradient,
              ),
              StatTile(label: 'Monthly Points', value: '9999', icon: LucideIcons.calendar),
              StatTile(label: 'Monthly Rank', value: '#1024', icon: LucideIcons.trophy),
              StatTile(label: 'Posts', value: '512', icon: LucideIcons.penLine),
              StatTile(label: 'Habits', value: '5', icon: LucideIcons.target),
            ],
          ),
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a settings group survives long labels and subtitles', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsGroup(
          children: [
            SettingsRow(
              icon: LucideIcons.shieldCheck,
              label: 'Политика конфиденциальности',
              subtitle: 'Какие данные мы собираем и как их удалить навсегда',
              onTap: () {},
            ),
          ],
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a section header clips an over-long label', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SectionHeader(
          icon: LucideIcons.info,
          label: 'ОЧЕНЬ ДЛИННЫЙ ЗАГОЛОВОК РАЗДЕЛА КОТОРЫЙ НЕ ВЛЕЗЕТ',
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a post card with a long word does not overflow', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SingleChildScrollView(
          child: PostCard(
            post: Post.fromJson({
              'id': 1,
              'user_id': 2,
              'username': 'оченьдлинныйникнеймбезпробелов',
              'content': 'Сверхдлинноесловобезпробеловкотороенеперенесётся ' * 3,
              'time': '5m ago',
              'likes': 123456,
              'commentsCount': 9999,
            }),
            currentUserId: 2,
            onLike: () {},
            onComment: () {},
            onOpenUser: () {},
            onDelete: () {},
          ),
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a full shared-habit card fits', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SingleChildScrollView(
          child: SharedHabitCard(
            sharedHabit: SharedHabitSummary.fromJson({
              'id': 12,
              'title': 'Читать двадцать страниц каждый божий день без исключений',
              'member_count': 128,
              'current_streak': 365,
              'members': [
                for (var i = 0; i < 5; i++) {'user_id': i, 'username': 'user$i'},
              ],
            }),
            onChanged: (_) {},
          ),
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the illustrated empty state fits with an action button', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const EmptyState(
          illustrated: true,
          title: 'No habits yet',
          subtitle: 'Create your first habit to start tracking.',
          action: Text('Create Habit'),
        ),
        surface: _se,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('with iOS large text turned on', () {
    // Readers who raise the system text size are exactly the readers this app
    // is for, so the counters and rows have to survive it.
    testWidgets('a post card holds together at 1.5x', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SingleChildScrollView(
          child: PostCard(
            post: Post.fromJson({
              'id': 1,
              'user_id': 2,
              'username': 'reader',
              'content': 'Дочитал вторую главу, идёт тяжело но интересно.',
              'time': '12m ago',
              'likes': 128400,
              'commentsCount': 9999,
            }),
            currentUserId: 2,
            onLike: () {},
            onComment: () {},
            onOpenUser: () {},
            onDelete: () {},
          ),
        ),
        surface: _se,
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a settings row holds together at 1.5x', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        SettingsGroup(
          children: [
            SettingsRow(
              icon: LucideIcons.shieldCheck,
              label: 'Privacy Policy',
              subtitle: 'What we collect and how to delete it',
              onTap: () {},
            ),
          ],
        ),
        surface: _se,
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a section header holds together at 1.5x', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const SectionHeader(icon: LucideIcons.info, label: 'ABOUT'),
        surface: _se,
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
