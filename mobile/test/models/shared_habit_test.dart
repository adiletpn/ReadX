import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/shared_habit.dart';

void main() {
  group('SharedHabitSummary.fromJson', () {
    test('parses the capped member list the summary endpoint returns', () {
      final summary = SharedHabitSummary.fromJson({
        'id': 12,
        'title': 'Read together',
        'is_point_eligible': 1,
        'member_count': 9,
        'current_streak': 4,
        'am_i_member': 1,
        'am_i_creator': 0,
        'members': [
          {'user_id': 1, 'username': 'a'},
          {'user_id': 2, 'username': 'b', 'avatar_url': '/uploads/b.png'},
        ],
      });

      expect(summary.memberCount, 9);
      expect(summary.members.length, 2);
      expect(summary.members.first.completedToday, isFalse);
      expect(summary.members[1].avatarUrl, '/uploads/b.png');
      expect(summary.amIMember, isTrue);
      expect(summary.amICreator, isFalse);
    });

    test('drops a malformed member instead of losing the whole group', () {
      final summary = SharedHabitSummary.fromJson({
        'id': 12,
        'members': [
          {'user_id': 1, 'username': 'a'},
          'nonsense',
        ],
      });

      expect(summary.members.length, 1);
    });

    test('copyWith keeps the fields the join toggle does not own', () {
      final summary = SharedHabitSummary.fromJson({
        'id': 12,
        'title': 'Read together',
        'current_streak': 4,
        'member_count': 3,
        'am_i_creator': 1,
      });

      final joined = summary.copyWith(memberCount: 4, amIMember: true);

      expect(joined.memberCount, 4);
      expect(joined.amIMember, isTrue);
      expect(joined.title, 'Read together');
      expect(joined.currentStreak, 4);
      expect(joined.amICreator, isTrue);
    });
  });
}
