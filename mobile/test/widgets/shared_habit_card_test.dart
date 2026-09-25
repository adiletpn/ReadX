import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/shared_habit.dart';
import 'package:readx/widgets/shared_habit_card.dart';
import 'package:readx/widgets/user_avatar.dart';

import '../helpers/harness.dart';

SharedHabitSummary _summary({
  int memberCount = 3,
  int members = 3,
  bool amIMember = false,
  bool amICreator = false,
  int streak = 4,
}) =>
    SharedHabitSummary.fromJson({
      'id': 12,
      'title': 'Читать 20 страниц',
      'is_point_eligible': 1,
      'member_count': memberCount,
      'current_streak': streak,
      'am_i_member': amIMember ? 1 : 0,
      'am_i_creator': amICreator ? 1 : 0,
      'members': [
        for (var i = 0; i < members; i++) {'user_id': i + 1, 'username': 'user$i'},
      ],
    });

Future<void> _pumpCard(WidgetTester tester, SharedHabitSummary summary) => pumpWidgetUnderTest(
      tester,
      SingleChildScrollView(
        child: SharedHabitCard(sharedHabit: summary, onChanged: (_) {}),
      ),
    );

void main() {
  testWidgets('shows the label, the title and the streak', (tester) async {
    await _pumpCard(tester, _summary());

    expect(find.text('SHARED HABIT'), findsOneWidget);
    expect(find.text('Читать 20 страниц'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('one member reads as person, several as people', (tester) async {
    await _pumpCard(tester, _summary(memberCount: 1, members: 1));
    expect(find.text('1 person doing this'), findsOneWidget);

    await _pumpCard(tester, _summary(memberCount: 7, members: 5));
    expect(find.text('7 people doing this'), findsOneWidget);
  });

  testWidgets('a non-member is offered Join', (tester) async {
    await _pumpCard(tester, _summary());

    expect(find.text('Join'), findsOneWidget);
    expect(find.text("✓ You're in"), findsNothing);
  });

  testWidgets('a member sees the confirmation instead of a button', (tester) async {
    await _pumpCard(tester, _summary(amIMember: true));

    expect(find.text("✓ You're in"), findsOneWidget);
    expect(find.text('Join'), findsNothing);
  });

  testWidgets('the creator is offered Manage', (tester) async {
    await _pumpCard(tester, _summary(amIMember: true, amICreator: true));

    expect(find.text('Manage'), findsOneWidget);
    expect(find.text("✓ You're in"), findsNothing);
  });

  testWidgets('the avatar stack caps at five and shows the remainder', (tester) async {
    await _pumpCard(tester, _summary(memberCount: 9, members: 5));

    expect(find.byType(UserAvatar), findsNWidgets(5));
    expect(find.text('+4'), findsOneWidget);
  });

  testWidgets('a group that fits shows no remainder bubble', (tester) async {
    await _pumpCard(tester, _summary(memberCount: 3, members: 3));

    expect(find.byType(UserAvatar), findsNWidgets(3));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('an empty roster still lays out', (tester) async {
    await _pumpCard(tester, _summary(memberCount: 0, members: 0));

    expect(tester.takeException(), isNull);
    expect(find.byType(UserAvatar), findsNothing);
  });

  testWidgets('a long title is clamped to two lines', (tester) async {
    await _pumpCard(
      tester,
      SharedHabitSummary.fromJson({
        'id': 12,
        'title': 'Очень длинное название совместной привычки ' * 4,
        'member_count': 2,
        'members': const [],
      }),
    );

    final title = tester.widget<Text>(find.textContaining('Очень длинное'));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}
