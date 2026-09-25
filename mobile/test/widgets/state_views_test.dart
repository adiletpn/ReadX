import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/widgets/empty_illustration.dart';
import 'package:readx/widgets/state_views.dart';

import '../helpers/harness.dart';

void main() {
  group('ErrorState', () {
    testWidgets('shows the message and a retry that fires', (tester) async {
      var retries = 0;
      await pumpWidgetUnderTest(
        tester,
        ErrorState(message: 'Сервер недоступен', onRetry: () => retries++),
      );

      expect(find.text('Сервер недоступен'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);

      await tester.tap(find.text('Повторить'));
      expect(retries, 1);
    });

    testWidgets('the retry label can be overridden', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        ErrorState(message: 'Ошибка', onRetry: () {}, retryLabel: 'Ещё раз'),
      );

      expect(find.text('Ещё раз'), findsOneWidget);
    });

    testWidgets('fits a 4.7 inch screen without overflowing', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        ErrorState(message: 'Сервер недоступен. Попробуйте позже', onRetry: () {}),
        surface: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('EmptyState', () {
    testWidgets('renders a title, a subtitle and an icon', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const EmptyState(
          title: 'Пока пусто',
          subtitle: 'Создайте первую привычку',
          icon: LucideIcons.target,
        ),
      );

      expect(find.text('Пока пусто'), findsOneWidget);
      expect(find.text('Создайте первую привычку'), findsOneWidget);
      expect(find.byIcon(LucideIcons.target), findsOneWidget);
    });

    testWidgets('the icon circle is optional', (tester) async {
      await pumpWidgetUnderTest(tester, const EmptyState(title: 'Пока пусто'));

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('the illustrated variant draws the book stack instead of an icon', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const EmptyState(
          illustrated: true,
          title: 'No habits yet',
          subtitle: 'Create your first habit to start tracking.',
          icon: LucideIcons.flame,
        ),
      );

      expect(find.byType(BookStackIllustration), findsOneWidget);
      expect(find.byIcon(LucideIcons.flame), findsNothing);
      expect(find.text('No habits yet'), findsOneWidget);
    });

    testWidgets('the illustration fits a 4.7 inch screen', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const EmptyState(
          illustrated: true,
          title: 'No posts yet',
          subtitle: 'Be the first to share something!',
        ),
        surface: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('an action widget is placed under the text', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const EmptyState(title: 'Пока пусто', action: Text('Создать')),
      );

      expect(find.text('Создать'), findsOneWidget);
    });
  });

  group('banners', () {
    testWidgets('the error banner is red on a red tint', (tester) async {
      await pumpWidgetUnderTest(tester, const AppErrorBanner(message: 'Invalid credentials'));

      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
      expect(decoration.color, AppColors.danger10);
      expect(tester.widget<Text>(find.text('Invalid credentials')).style?.color, AppColors.danger);
    });

    testWidgets('the success banner is green', (tester) async {
      await pumpWidgetUnderTest(tester, const AppSuccessBanner(message: 'Письмо отправлено'));

      expect(
        tester.widget<Text>(find.text('Письмо отправлено')).style?.color,
        AppColors.success,
      );
    });
  });
}
