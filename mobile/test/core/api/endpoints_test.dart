import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';

void main() {
  group('shape', () {
    test('every path is root-relative, so kApiBase is never doubled', () {
      final paths = [
        Endpoints.login,
        Endpoints.register,
        Endpoints.me,
        Endpoints.posts,
        Endpoints.habits,
        Endpoints.sharedHabits,
        Endpoints.userSearch,
        Endpoints.reports,
        Endpoints.leaderboard,
        Endpoints.notifications,
        Endpoints.post(1),
        Endpoints.habit(1),
        Endpoints.user(1),
        Endpoints.userBlock(1),
      ];

      for (final path in paths) {
        expect(path.startsWith('/'), isTrue, reason: path);
        expect(path.contains('http'), isFalse, reason: path);
        expect(path.endsWith('/'), isFalse, reason: path);
      }
    });
  });

  group('ids', () {
    test('are interpolated into the path, never appended as a query', () {
      expect(Endpoints.post(42), '/posts/42');
      expect(Endpoints.postLike(42), '/posts/42/like');
      expect(Endpoints.postComments(42), '/posts/42/comments');
      expect(Endpoints.habit(7), '/habits/7');
      expect(Endpoints.habitComplete(7), '/habits/7/complete');
      expect(Endpoints.user(4), '/users/4');
      expect(Endpoints.userFollow(4), '/users/4/follow');
    });

    test('shared-habit paths all hang off the same prefix', () {
      expect(Endpoints.sharedHabit(12), '/habits/shared/12');
      expect(Endpoints.sharedHabitJoin(12), '/habits/shared/12/join');
      expect(Endpoints.sharedHabitLeave(12), '/habits/shared/12/leave');
      expect(Endpoints.sharedHabits, '/habits/shared');
    });

    test('comment paths are their own resource, not nested under posts', () {
      expect(Endpoints.comment(3), '/comments/3');
      expect(Endpoints.commentLike(3), '/comments/3/like');
      expect(Endpoints.userComments(4), '/comments/user/4');
      expect(Endpoints.myLikedComments(4), '/comments/user/4/liked');
    });
  });

  group('collisions', () {
    test('the fixed user paths cannot be mistaken for an id', () {
      expect(Endpoints.blockedUsers, isNot(Endpoints.user(0)));
      expect(Endpoints.userSearch, '/users/search');
      expect(Endpoints.userProfile, '/users/profile');
      expect(Endpoints.deleteAccount, '/users/me');
    });

    test('the feed tabs are three distinct paths', () {
      final tabs = {Endpoints.posts, Endpoints.postsFollowing, Endpoints.postsLiked};
      expect(tabs.length, 3);
    });
  });

  group('uploads', () {
    test('the multipart field names are the ones the server accepts', () {
      expect(Endpoints.uploadFieldImage, 'image');
      expect(Endpoints.uploadFieldAvatar, 'avatar');
    });

    test('each upload has its own endpoint', () {
      expect(Endpoints.postsUpload, '/posts/upload');
      expect(Endpoints.userAvatar, '/users/avatar');
    });
  });
}
