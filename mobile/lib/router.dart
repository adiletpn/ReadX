import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/common/not_found_screen.dart';
import 'features/feed/feed_screen.dart';

/// Every path in the app, written once.
///
/// The paths mirror the web router (src/app/routes.tsx) so universal links
/// from readx.kz open the matching screen, and so a push payload's `url` can
/// be handed to `router.go()` unchanged.
abstract class AppRoutes {
  // Публичные
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // Основные
  static const feed = '/';
  static const search = '/search';
  static const habits = '/habits';
  static const habitNew = '/habits/new';
  static const points = '/points';
  static const pointsHowItWorks = '/points/how-it-works';
  static const postNew = '/post/new';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const admin = '/admin';

  static String sharedHabit(int id) => '/habits/shared/$id';
  static String post(int id) => '/post/$id';
  static String user(int id) => '/user/$id';
  static String userFollowers(int id) => '/user/$id/followers';
  static String userFollowing(int id) => '/user/$id/following';

  /// Экраны, которых нет в вебе: требования App Store Review
  /// (APPSTORE_RELEASE.md §3).
  static const deleteAccount = '/settings/delete-account';
  static const blockedUsers = '/settings/blocked';
  static const lotteryRules = '/lottery/rules';
  static const privacy = '/about/privacy';
  static const terms = '/about/terms';

  /// Вкладки нижней навигации — по ним BottomNav определяет активную иконку.
  static const bottomNavPaths = [feed, habits, points, profile];

  /// Экраны, доступные без токена.
  static const publicPaths = {login, register, forgotPassword, resetPassword};

  /// Из этих экранов залогиненного пользователя уводим на ленту. Сброс пароля
  /// сюда не входит: ссылку из письма можно открыть и не выходя из аккаунта.
  static const guestOnlyPaths = {login, register, forgotPassword};
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// The router instance. It is a provider so the auth layer can add its
/// redirect guard against the same object the app is already rendering.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.feed,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);

      // Cold start: the session is still being resolved. Nothing is moved
      // anywhere, so a deep link survives the wait — the app shows the splash
      // over the router until this settles (see app.dart).
      if (auth.isLoading && !auth.hasValue) return null;

      final signedIn = auth.value != null;
      final location = state.matchedLocation;

      if (!signedIn && !AppRoutes.publicPaths.contains(location)) {
        return AppRoutes.login;
      }
      if (signedIn && AppRoutes.guestOnlyPaths.contains(location)) {
        return AppRoutes.feed;
      }
      return null;
    },
    // Any unknown path — a stale universal link, a mistyped deep link —
    // lands on the 404 screen instead of go_router's debug page.
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.feed,
        builder: (context, state) => const FeedScreen(),
      ),
    ],
  );
});

/// Bridges the session into go_router: every change of the auth state makes
/// the router re-run its redirect, which is what moves the user to the feed
/// after a login and back to /login when the token expires.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}
