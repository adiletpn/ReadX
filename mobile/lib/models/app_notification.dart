import '../core/utils/json.dart';

enum NotificationType { like, comment, follow, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.postId,
    required this.actorId,
    required this.actorUsername,
    required this.actorAvatar,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String message;
  final int? postId;
  final int? actorId;
  final String? actorUsername;
  final String? actorAvatar;
  final bool isRead;
  final String createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: asInt(json['id']),
        type: switch (asString(json['type'])) {
          'like' => NotificationType.like,
          'comment' => NotificationType.comment,
          'follow' => NotificationType.follow,
          _ => NotificationType.system,
        },
        message: asString(json['message']),
        postId: asIntOrNull(json['post_id']),
        actorId: asIntOrNull(json['actor_id']),
        actorUsername: asStringOrNull(json['actor_username']),
        actorAvatar: asStringOrNull(json['actor_avatar']),
        isRead: asBool(json['is_read']),
        createdAt: asString(json['created_at']),
      );
}
