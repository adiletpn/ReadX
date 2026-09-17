import '../core/utils/json.dart';

/// A comment. The API returns them as a flat list ordered by `created_at ASC`;
/// replies are not nested, they just carry [parentId] and [replyToUsername],
/// which the UI renders as a blue `@username` prefix — the same way the web
/// does. No tree is built.
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.parentId,
    required this.replyToUsername,
    required this.likes,
    required this.liked,
    required this.time,
    required this.createdAt,
  });

  final int id;
  final int postId;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final int? parentId;
  final String? replyToUsername;
  final int likes;
  final bool liked;

  /// Готовая строка с сервера.
  final String time;

  final String createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: asInt(json['id']),
        postId: asInt(json['post_id']),
        userId: asInt(json['user_id']),
        username: asString(json['username']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        content: asString(json['content']),
        parentId: asIntOrNull(json['parent_id']),
        replyToUsername: asStringOrNull(json['reply_to_username']),
        likes: asInt(json['likes']),
        liked: asBool(json['liked']),
        time: asString(json['time']),
        createdAt: asString(json['created_at']),
      );

  Comment copyWith({int? likes, bool? liked}) => Comment(
        id: id,
        postId: postId,
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        content: content,
        parentId: parentId,
        replyToUsername: replyToUsername,
        likes: likes ?? this.likes,
        liked: liked ?? this.liked,
        time: time,
        createdAt: createdAt,
      );
}
