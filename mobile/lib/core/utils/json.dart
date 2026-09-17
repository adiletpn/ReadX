/// Tolerant readers for the API's JSON.
///
/// The backend is SQLite-backed and inconsistent on purpose-built types: some
/// endpoints convert 0/1 columns to real booleans, others hand the integer
/// straight through, and numeric columns can arrive as doubles. Parsing with
/// raw casts (`json['liked'] as bool`) crashes on the rows that were not
/// converted, so models read every field through the helpers below.
library;

/// `0 | 1 | "1" | true` → bool.
bool asBool(Object? value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
  }
  return fallback;
}

/// Any JSON number (including `10.0` and numeric strings) → int.
int asInt(Object? value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? num.tryParse(value)?.toInt() ?? fallback;
  if (value is bool) return value ? 1 : 0;
  return fallback;
}

/// Nullable variant of [asInt] — for optional ids like `post_id` and
/// `shared_habit_id`, where 0 and "absent" mean different things.
int? asIntOrNull(Object? value) {
  if (value == null) return null;
  return asInt(value);
}

/// Any scalar → String, with `null` collapsing to [fallback]. The API returns
/// `null` for `name`, `bio` and `avatar_url` on accounts that never filled
/// them in.
String asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

/// Same as [asString] but keeps `null` and empty strings distinguishable —
/// used for `avatar_url`, where absence means "draw the initials instead".
String? asStringOrNull(Object? value) {
  if (value == null) return null;
  final s = value is String ? value : value.toString();
  return s.isEmpty ? null : s;
}

/// SQLite hands out `"YYYY-MM-DD HH:MM:SS"` in UTC with no timezone suffix.
/// `DateTime.parse` would read that as local time and shift it by the offset,
/// so the `Z` is appended first — the same thing `timeAgo()` does in
/// server/routes/posts.js.
DateTime? parseServerDate(Object? value) {
  if (value is! String) return null;
  final raw = value.trim();
  if (raw.isEmpty) return null;
  final normalised = raw.endsWith('Z') || raw.contains('+') ? raw : '${raw.replaceFirst(' ', 'T')}Z';
  return DateTime.tryParse(normalised)?.toLocal();
}

/// Maps a JSON list into models, dropping the entries that fail to parse.
/// One malformed post must not blank out the whole feed.
List<T> mapList<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  final result = <T>[];
  for (final raw in value) {
    if (raw is! Map) continue;
    try {
      result.add(fromJson(Map<String, dynamic>.from(raw)));
    } on Object {
      // Skipped deliberately: a single bad row is not worth an empty screen.
      continue;
    }
  }
  return result;
}

/// Narrows a decoded JSON value to an object map. The API answers with a map
/// on every endpoint that is documented to, but a proxy error page or an empty
/// body would otherwise surface as a cast error deep inside a model.
Map<String, dynamic> asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
