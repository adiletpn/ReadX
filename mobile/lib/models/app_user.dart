import '../core/utils/json.dart';
import 'badge.dart';

/// The signed-in user, as `GET /auth/me` builds it in server/routes/auth.js.
///
/// The field names are the backend's own mix of snake_case and camelCase and
/// are not tidied up here — `totalPoints` and `total_points` really are both
/// present and equal, and only `/auth/me` sends the second one.
///
/// `POST /auth/login` and `/auth/register` return a *shorter* version of this
/// object (no `is_admin`, no `badges`, and register omits the book pages, rank
/// and counters), which is why the app follows both with a call to
/// `/auth/me` instead of trusting their payload.
class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.surname,
    required this.bio,
    required this.avatarUrl,
    required this.instagram,
    required this.telegram,
    required this.bookName,
    required this.bookAuthor,
    required this.showBook,
    required this.bookCurrentPage,
    required this.bookTotalPages,
    required this.isAdmin,
    required this.totalPoints,
    required this.monthlyPoints,
    required this.monthlyRank,
    required this.postCount,
    required this.habitCount,
    required this.currentStreak,
    required this.skipsRemaining,
    required this.followersCount,
    required this.followingCount,
    required this.badges,
  });

  final int id;
  final String username;
  final String email;
  final String name;
  final String surname;
  final String bio;

  /// Относительный путь `/uploads/...` — перед показом через `mediaUrl()`.
  final String? avatarUrl;

  final String instagram;
  final String telegram;
  final String bookName;
  final String bookAuthor;
  final bool showBook;
  final int bookCurrentPage;
  final int bookTotalPages;
  final bool isAdmin;
  final int totalPoints;
  final int monthlyPoints;
  final int monthlyRank;
  final int postCount;
  final int habitCount;

  /// Месячный стрик **пользователя** (`users.monthly_streak`), а не стрик
  /// конкретной привычки — карточка привычки показывает именно его.
  final int currentStreak;

  /// Легаси-поле из `/auth/me`: сервер считает его как `2 - skips_used`,
  /// игнорируя настройку `skips_limit`. На экране привычек берётся
  /// `skips_remaining` из самой привычки.
  final int skipsRemaining;

  final int followersCount;
  final int followingCount;
  final List<Badge> badges;

  /// Имя для показа. Сервер уже подставляет username, если имя пустое, но у
  /// старых записей поле может прийти пустым.
  String get displayName {
    final full = '$name $surname'.trim();
    return full.isEmpty ? username : full;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: asInt(json['id']),
        username: asString(json['username']),
        email: asString(json['email']),
        name: asString(json['name']),
        surname: asString(json['surname']),
        bio: asString(json['bio']),
        avatarUrl: asStringOrNull(json['avatar_url']),
        instagram: asString(json['instagram']),
        telegram: asString(json['telegram']),
        bookName: asString(json['book_name']),
        bookAuthor: asString(json['book_author']),
        showBook: asBool(json['show_book']),
        bookCurrentPage: asInt(json['book_current_page']),
        bookTotalPages: asInt(json['book_total_pages']),
        isAdmin: asBool(json['is_admin']),
        totalPoints: asInt(json['totalPoints'] ?? json['total_points']),
        monthlyPoints: asInt(json['monthlyPoints']),
        monthlyRank: asInt(json['monthlyRank']),
        postCount: asInt(json['postCount']),
        habitCount: asInt(json['habitCount']),
        currentStreak: asInt(json['currentStreak']),
        skipsRemaining: asInt(json['skipsRemaining']),
        followersCount: asInt(json['followersCount']),
        followingCount: asInt(json['followingCount']),
        badges: mapList(json['badges'], Badge.fromJson),
      );
}
