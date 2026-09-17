import '../core/utils/json.dart';
import 'badge.dart';
import 'shared_habit.dart';

/// A feed post, as the SELECT in server/routes/posts.js builds it.
///
/// [time] is a finished string from the server (`"just now"`, `"5m ago"`) — it
/// is never parsed as a date. [createdAt] is the raw UTC timestamp, kept for
/// the screens that receive posts without a `time` field (the ones nested in
/// `GET /users/:id`).
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.commentsCount,
    required this.liked,
    required this.time,
    required this.createdAt,
    required this.sharedHabitId,
    required this.sharedHabit,
    required this.badges,
  });

  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final String? imageUrl;
  final int likes;
  final int commentsCount;
  final bool liked;

  /// Готовая строка с сервера. НЕ парсить как дату.
  final String time;

  final String createdAt;

  /// Заполнено только у постов-анонсов совместной привычки.
  final int? sharedHabitId;
  final SharedHabitSummary? sharedHabit;

  final List<Badge> badges;

  factory Post.fromJson(Map<String, dynamic> json) {
    final shared = json['shared_habit'];
    return Post(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      username: asString(json['username']),
      avatarUrl: asStringOrNull(json['avatar_url']),
      content: asString(json['content']),
      imageUrl: asStringOrNull(json['image_url']),
      likes: asInt(json['likes']),
      commentsCount: asInt(json['commentsCount']),
      liked: asBool(json['liked']),
      time: asString(json['time']),
      createdAt: asString(json['created_at']),
      sharedHabitId: asIntOrNull(json['shared_habit_id']),
      sharedHabit: shared is Map ? SharedHabitSummary.fromJson(asMap(shared)) : null,
      badges: mapList(json['badges'], Badge.fromJson),
    );
  }

  Post copyWith({
    int? likes,
    bool? liked,
    int? commentsCount,
    SharedHabitSummary? sharedHabit,
  }) =>
      Post(
        id: id,
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        content: content,
        imageUrl: imageUrl,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
        liked: liked ?? this.liked,
        time: time,
        createdAt: createdAt,
        sharedHabitId: sharedHabitId,
        sharedHabit: sharedHabit ?? this.sharedHabit,
        badges: badges,
      );
}
