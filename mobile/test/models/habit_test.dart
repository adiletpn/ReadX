import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/habit.dart';

void main() {
  group('Habit.fromJson', () {
    test('reads the 0/1 columns SQLite hands through unconverted', () {
      final habit = Habit.fromJson({
        'id': 7,
        'user_id': 3,
        'title': 'Read 20 pages',
        'description': '',
        'streak': 12,
        'completed_today': 1,
        'last_completed_date': '2026-09-20',
        'is_point_eligible': 0,
        'skips_used': 1,
        'skips_remaining': 2,
      });

      expect(habit.completedToday, isTrue);
      expect(habit.isPointEligible, isFalse);
      expect(habit.streak, 12);
      expect(habit.skipsRemaining, 2);
    });

    test('a habit with no group is not shared', () {
      final habit = Habit.fromJson({'id': 1, 'title': 'Solo'});

      expect(habit.isShared, isFalse);
      expect(habit.sharedHabit, isNull);
      expect(habit.lastCompletedDate, isNull);
      expect(habit.description, '');
    });

    test('a habit joined to a group carries the nested summary', () {
      final habit = Habit.fromJson({
        'id': 2,
        'title': 'Read together',
        'shared_habit_id': 12,
        'shared_habit': {
          'id': 12,
          'title': 'Read together',
          'member_count': 4,
          'current_streak': 3,
          'am_i_member': 1,
        },
      });

      expect(habit.isShared, isTrue);
      expect(habit.sharedHabit!.memberCount, 4);
      expect(habit.sharedHabit!.amIMember, isTrue);
    });
  });

  group('Habit.copyWith', () {
    test('keeps every field the optimistic toggle does not touch', () {
      final habit = Habit.fromJson({
        'id': 5,
        'user_id': 9,
        'title': 'Read',
        'description': 'daily',
        'streak': 4,
        'completed_today': 0,
        'skips_remaining': 3,
        'is_point_eligible': 1,
      });

      final toggled = habit.copyWith(completedToday: true, streak: 5, skipsRemaining: 2);

      expect(toggled.id, 5);
      expect(toggled.userId, 9);
      expect(toggled.title, 'Read');
      expect(toggled.description, 'daily');
      expect(toggled.isPointEligible, isTrue);
      expect(toggled.completedToday, isTrue);
      expect(toggled.streak, 5);
      expect(toggled.skipsRemaining, 2);
    });
  });
}
