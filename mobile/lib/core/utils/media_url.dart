import '../../config.dart';

/// The API returns every uploaded file as a root-relative path
/// (`/uploads/1771563007880.png`). On the web that resolved against the page
/// origin for free because the frontend and the API share one host; a native
/// client has to prefix it itself, so every avatar and post image goes through
/// this function rather than through hand-built strings.
String? mediaUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  // Absolute URLs are passed through untouched — the admin panel can store a
  // full URL in avatar_url, and re-prefixing it would break the image.
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return trimmed.startsWith('/') ? '$kMediaBase$trimmed' : '$kMediaBase/$trimmed';
}
