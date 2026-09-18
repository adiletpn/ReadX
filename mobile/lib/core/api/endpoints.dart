/// Every API path the app calls, in one place — so no request builds its URL
/// from a literal scattered through a screen.
abstract class Endpoints {
  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const me = '/auth/me';

  // Posts
  static const posts = '/posts';
  static const postsFollowing = '/posts/following';
  static const postsLiked = '/posts/liked';
  static const postsUpload = '/posts/upload';
  static String post(int id) => '/posts/$id';
  static String postLike(int id) => '/posts/$id/like';
  static String postComments(int id) => '/posts/$id/comments';

  // Comments
  static String commentLike(int id) => '/comments/$id/like';
  static String comment(int id) => '/comments/$id';
  static String userComments(int userId) => '/comments/user/$userId';

  /// Комментарии, залайканные **вызывающим**: сервер игнорирует `:userId`,
  /// поэтому эндпоинт годится только для своего профиля.
  static String myLikedComments(int userId) => '/comments/user/$userId/liked';

  // Habits
  static const habits = '/habits';
  static String habit(int id) => '/habits/$id';
  static String habitComplete(int id) => '/habits/$id/complete';

  // Shared habits
  static const sharedHabits = '/habits/shared';
  static String sharedHabit(int id) => '/habits/shared/$id';
  static String sharedHabitJoin(int id) => '/habits/shared/$id/join';
  static String sharedHabitLeave(int id) => '/habits/shared/$id/leave';

  // Users
  static const userSearch = '/users/search';
  static const userProfile = '/users/profile';
  static const userAvatar = '/users/avatar';
  static String user(int id) => '/users/$id';
  static String userFollow(int id) => '/users/$id/follow';
  static String userFollowers(int id) => '/users/$id/followers';
  static String userFollowing(int id) => '/users/$id/following';

  // Moderation and account
  static const reports = '/reports';
  static const deleteAccount = '/users/me';
  static const blockedUsers = '/users/blocked';
  static String userBlock(int id) => '/users/$id/block';

  // Points, settings, notifications
  static const leaderboard = '/points/leaderboard';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const notificationsUnread = '/notifications/unread';
  static const notificationsRead = '/notifications/read';

  /// Имена multipart-полей: сервер ждёт `image` для постов и `avatar` для
  /// аватара, и отвечает 400 «No file uploaded» на любое другое имя.
  static const uploadFieldImage = 'image';
  static const uploadFieldAvatar = 'avatar';
}
