import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/habit.dart';

void main() {
  group('CompleteResult.fromJson', () {
    test('reads a normal completion with points awarded', () {
      final result = CompleteResult.fromJson({
        'habit_id': 4,
        'completed_today': true,
        'monthly_streak': 6,
        'monthly_points': 42,
        'points_awarded': 2,
        'skips_remaining': 3,
      });

      expect(result.deleted, isFalse);
      expect(result.habitId, 4);
      expect(result.completedToday, isTrue);
      expect(result.monthlyStreak, 6);
      expect(result.monthlyPoints, 42);
      expect(result.pointsAwarded, 2);
    });

    test('an uncompletion awards nothing rather than zero', () {
      final result = CompleteResult.fromJson({
        'habit_id': 4,
        'completed_today': 0,
        'monthly_points': 40,
        'skips_remaining': 3,
      });

      expect(result.completedToday, isFalse);
      expect(result.pointsAwarded, isNull);
    });

    test('a deleted habit comes back flagged and without an id', () {
      final result = CompleteResult.fromJson({'deleted': true});

      expect(result.deleted, isTrue);
      expect(result.habitId, isNull);
      expect(result.completedToday, isFalse);
    });
  });

  group('CreateHabitResult.fromJson', () {
    test('parses the habit and the limit flag from the same object', () {
      final result = CreateHabitResult.fromJson({
        'id': 11,
        'title': 'Read 20 pages',
        'is_point_eligible': 0,
        'eligible_limit_reached': 1,
      });

      expect(result.habit.id, 11);
      expect(result.habit.title, 'Read 20 pages');
      expect(result.habit.isPointEligible, isFalse);
      expect(result.eligibleLimitReached, isTrue);
    });

    test('a habit created under the limit carries no warning', () {
      final result = CreateHabitResult.fromJson({
        'id': 12,
        'title': 'Read',
        'is_point_eligible': 1,
      });

      expect(result.habit.isPointEligible, isTrue);
      expect(result.eligibleLimitReached, isFalse);
    });
  });
}
