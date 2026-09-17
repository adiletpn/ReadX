import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/common/not_found_screen.dart';
import 'features/common/splash_screen.dart';

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
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// The router instance. It is a provider so the auth layer can add its
/// redirect guard against the same object the app is already rendering.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.feed,
    // Any unknown path — a stale universal link, a mistyped deep link —
    // lands on the 404 screen instead of go_router's debug page.
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.feed,
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
});
