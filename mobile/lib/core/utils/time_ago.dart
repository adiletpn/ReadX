import 'json.dart';

/// Formats a raw `created_at` the way the server's own `timeAgo()` does
/// (server/routes/posts.js), for the few places that receive a timestamp
/// instead of the pre-rendered `time` string — posts nested inside
/// `GET /users/:id`, and notifications.
///
/// Posts and comments from the feed endpoints already carry a finished `time`
/// string; those must never be passed through here.
String timeAgo(Object? createdAt) {
  final date = parseServerDate(createdAt);
  if (date == null) return '';

  final seconds = DateTime.now().difference(date).inSeconds;
  if (seconds < 60) return 'just now';
  if (seconds < 3600) return '${seconds ~/ 60}m ago';
  if (seconds < 86400) return '${seconds ~/ 3600}h ago';
  return '${seconds ~/ 86400}d ago';
}
