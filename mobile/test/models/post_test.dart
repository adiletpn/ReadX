import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/habit.dart';
import 'package:readx/models/post.dart';
import 'package:readx/models/public_profile.dart';

void main() {
  group('Post.fromJson', () {
    test('keeps the server-rendered time string as-is', () {
      final post = Post.fromJson({
        'id': 1,
        'user_id': 2,
        'username': 'reader',
        'content': 'hello',
        'time': '5m ago',
        'created_at': '2026-09-17 12:00:00',
        'likes': 3,
        'commentsCount': 1,
        'liked': 1,
      });

      expect(post.time, '5m ago');
      expect(post.liked, isTrue);
      expect(post.sharedHabit, isNull);
    });

    test('parses the nested shared habit announcement', () {
      final post = Post.fromJson({
        'id': 9,
        'user_id': 4,
        'username': 'reader',
        'content': 'join in',
        'shared_habit_id': 12,
        'shared_habit': {
          'id': 12,
          'title': 'Read 20 pages',
          'is_point_eligible': 1,
          'member_count': 3,
          'current_streak': 4,
          'members': [
            {'user_id': 4, 'username': 'reader', 'avatar_url': null},
          ],
          'am_i_member': 1,
          'am_i_creator': 0,
        },
      });

      expect(post.sharedHabitId, 12);
      expect(post.sharedHabit?.memberCount, 3);
      expect(post.sharedHabit?.amIMember, isTrue);
      expect(post.sharedHabit?.amICreator, isFalse);
      expect(post.sharedHabit?.members.single.username, 'reader');
    });
  });

  group('CompleteResult.fromJson', () {
    test('reads the completed response', () {
      final result = CompleteResult.fromJson({
        'completed_today': true,
        'monthly_streak': 7,
        'monthly_points': 128,
        'points_awarded': 7,
        'skips_remaining': 2,
      });

      expect(result.deleted, isFalse);
      expect(result.completedToday, isTrue);
      expect(result.pointsAwarded, 7);
    });

    test('reads the undo response, which carries no points_awarded', () {
      final result = CompleteResult.fromJson({
        'completed_today': false,
        'monthly_streak': 6,
        'monthly_points': 121,
        'skips_remaining': 2,
      });

      expect(result.deleted, isFalse);
      expect(result.completedToday, isFalse);
      expect(result.pointsAwarded, isNull);
    });

    test('reads the auto-delete response', () {
      final result = CompleteResult.fromJson({
        'deleted': true,
        'habit_id': 42,
        'monthly_streak': 1,
        'monthly_points': 1,
        'skips_remaining': 0,
      });

      expect(result.deleted, isTrue);
      expect(result.habitId, 42);
      expect(result.completedToday, isFalse);
    });
  });

  group('PublicProfile.fromJson', () {
    test('fills the author fields the nested posts are missing', () {
      final profile = PublicProfile.fromJson({
        'id': 8,
        'username': 'aigerim',
        'name': 'Айгерім',
        'surname': 'Нұрлан',
        'avatar_url': '/uploads/a.png',
        'posts': [
          {'id': 1, 'content': 'first', 'likes': 2, 'created_at': '2026-09-17 10:00:00', 'commentsCount': 0},
        ],
        'badges': [],
      });

      expect(profile.posts.single.userId, 8);
      expect(profile.posts.single.username, 'aigerim');
      expect(profile.posts.single.avatarUrl, '/uploads/a.png');
      expect(profile.posts.single.time, '');
      expect(profile.displayName, 'Айгерім Нұрлан');
    });
  });
}
