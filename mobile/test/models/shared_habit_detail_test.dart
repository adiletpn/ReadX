import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/shared_habit.dart';

SharedHabitDetail _detail() => SharedHabitDetail.fromJson({
      'id': 12,
      'title': 'Read together',
      'is_point_eligible': 1,
      'created_by': 3,
      'member_count': 3,
      'current_streak': 5,
      'longest_streak': 9,
      'post_id': 44,
      'am_i_member': 1,
      'my_habit_id': 21,
      'members': [
        {'user_id': 3, 'username': 'creator', 'completed_today': 1},
        {'user_id': 4, 'username': 'joiner', 'completed_today': 0},
      ],
    });

void main() {
  group('SharedHabitDetail.fromJson', () {
    test('reads the full roster and the streaks', () {
      final detail = _detail();

      expect(detail.memberCount, 3);
      expect(detail.currentStreak, 5);
      expect(detail.longestStreak, 9);
      expect(detail.postId, 44);
      expect(detail.myHabitId, 21);
      expect(detail.members.length, 2);
    });

    test('a group whose announcement post was deleted has no post id', () {
      final detail = SharedHabitDetail.fromJson({'id': 12, 'post_id': null});

      expect(detail.postId, isNull);
      expect(detail.myHabitId, isNull);
      expect(detail.amIMember, isFalse);
    });
  });

  group('membership helpers', () {
    test('amICreator only matches the creator id', () {
      final detail = _detail();

      expect(detail.amICreator(3), isTrue);
      expect(detail.amICreator(4), isFalse);
      expect(detail.amICreator(null), isFalse);
    });

    test('completedTodayFor reads the flag off the matching member', () {
      final detail = _detail();

      expect(detail.completedTodayFor(3), isTrue);
      expect(detail.completedTodayFor(4), isFalse);
      expect(detail.completedTodayFor(99), isFalse);
      expect(detail.completedTodayFor(null), isFalse);
    });
  });
}
