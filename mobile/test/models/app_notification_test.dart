import 'package:flutter_test/flutter_test.dart';
import 'package:readx/models/app_notification.dart';

void main() {
  group('AppNotification.fromJson', () {
    test('maps the four types the server sends', () {
      NotificationType typeOf(String raw) =>
          AppNotification.fromJson({'id': 1, 'type': raw}).type;

      expect(typeOf('like'), NotificationType.like);
      expect(typeOf('comment'), NotificationType.comment);
      expect(typeOf('follow'), NotificationType.follow);
      expect(typeOf('system'), NotificationType.system);
    });

    test('an unknown type degrades to system instead of throwing', () {
      expect(AppNotification.fromJson({'id': 1, 'type': 'badge'}).type, NotificationType.system);
      expect(AppNotification.fromJson({'id': 1}).type, NotificationType.system);
    });

    test('reads the actor and the unread flag', () {
      final notification = AppNotification.fromJson({
        'id': 9,
        'type': 'like',
        'message': 'liked your post',
        'post_id': 4,
        'actor_id': 2,
        'actor_username': 'reader',
        'actor_avatar': '/uploads/a.png',
        'is_read': 0,
        'created_at': '2026-09-20 08:00:00',
      });

      expect(notification.actorUsername, 'reader');
      expect(notification.actorAvatar, '/uploads/a.png');
      expect(notification.postId, 4);
      expect(notification.isRead, isFalse);
    });

    test('a follow notification has no post to open', () {
      final notification = AppNotification.fromJson({
        'id': 10,
        'type': 'follow',
        'post_id': null,
        'is_read': 1,
      });

      expect(notification.postId, isNull);
      expect(notification.isRead, isTrue);
    });
  });
}
