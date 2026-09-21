import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('keeps the server-rendered time string untouched', () {
      final comment = Comment.fromJson({
        'id': 3,
        'post_id': 8,
        'user_id': 2,
        'username': 'reader',
        'content': 'nice',
        'likes': 2,
        'liked': 1,
        'time': '12m ago',
        'created_at': '2026-09-20 09:00:00',
      });

      expect(comment.time, '12m ago');
      expect(comment.liked, isTrue);
      expect(comment.parentId, isNull);
      expect(comment.replyToUsername, isNull);
    });

    test('a reply carries the parent id and the mentioned username', () {
      final comment = Comment.fromJson({
        'id': 4,
        'post_id': 8,
        'user_id': 5,
        'username': 'other',
        'content': 'agreed',
        'parent_id': 3,
        'reply_to_username': 'reader',
        'time': '1m ago',
        'created_at': '2026-09-20 09:11:00',
      });

      expect(comment.parentId, 3);
      expect(comment.replyToUsername, 'reader');
    });

    test('an empty avatar url reads as absent so the initials are drawn', () {
      final comment = Comment.fromJson({'id': 1, 'avatar_url': ''});

      expect(comment.avatarUrl, isNull);
    });
  });

  group('Comment.copyWith', () {
    test('changes only the like counters', () {
      final comment = Comment.fromJson({
        'id': 3,
        'post_id': 8,
        'user_id': 2,
        'username': 'reader',
        'content': 'nice',
        'likes': 2,
        'liked': 0,
        'time': '12m ago',
      });

      final liked = comment.copyWith(likes: 3, liked: true);

      expect(liked.likes, 3);
      expect(liked.liked, isTrue);
      expect(liked.id, 3);
      expect(liked.content, 'nice');
      expect(liked.time, '12m ago');
    });
  });
}
