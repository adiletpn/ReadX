import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/public_profile.dart';

void main() {
  group('FollowUser.fromJson', () {
    test('reads the follow state the list endpoint returns', () {
      final user = FollowUser.fromJson({
        'id': 4,
        'username': 'reader',
        'name': 'Бекзат',
        'surname': 'Ким',
        'avatar_url': '/uploads/a.png',
        'isFollowing': 1,
      });

      expect(user.id, 4);
      expect(user.displayName, 'Бекзат Ким');
      expect(user.avatarUrl, '/uploads/a.png');
      expect(user.isFollowing, isTrue);
    });

    test('copyWith only flips the follow state', () {
      final user = FollowUser.fromJson({
        'id': 4,
        'username': 'reader',
        'isFollowing': 0,
      });

      final followed = user.copyWith(isFollowing: true);

      expect(followed.isFollowing, isTrue);
      expect(followed.id, 4);
      expect(followed.username, 'reader');
    });
  });

  group('SearchUser.fromJson', () {
    test('reads the total points the search row shows', () {
      final user = SearchUser.fromJson({
        'id': 6,
        'username': 'reader',
        'name': 'Бекзат',
        'surname': '',
        'total_points': 310,
      });

      expect(user.totalPoints, 310);
      expect(user.displayName, 'Бекзат');
    });

    test('an account with no name at all shows the username', () {
      final user = SearchUser.fromJson({'id': 6, 'username': 'reader'});

      expect(user.displayName, 'reader');
      expect(user.totalPoints, 0);
      expect(user.avatarUrl, isNull);
    });
  });
}
