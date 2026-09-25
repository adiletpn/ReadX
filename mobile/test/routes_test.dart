import 'package:flutter_test/flutter_test.dart';
import 'package:readx/router.dart';

void main() {
  group('paths', () {
    test('every static route is root-relative', () {
      final paths = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
        AppRoutes.feed,
        AppRoutes.search,
        AppRoutes.habits,
        AppRoutes.habitNew,
        AppRoutes.points,
        AppRoutes.pointsHowItWorks,
        AppRoutes.postNew,
        AppRoutes.profile,
        AppRoutes.settings,
        AppRoutes.notifications,
        AppRoutes.admin,
        AppRoutes.deleteAccount,
        AppRoutes.blockedUsers,
        AppRoutes.lotteryRules,
      ];

      for (final path in paths) {
        expect(path.startsWith('/'), isTrue, reason: path);
      }
    });

    test('ids are interpolated the same way the web router does', () {
      expect(AppRoutes.post(9), '/post/9');
      expect(AppRoutes.user(4), '/user/4');
      expect(AppRoutes.userFollowers(4), '/user/4/followers');
      expect(AppRoutes.userFollowing(4), '/user/4/following');
      expect(AppRoutes.sharedHabit(12), '/habits/shared/12');
    });

    test('the App Store screens live under the sections they belong to', () {
      expect(AppRoutes.deleteAccount.startsWith('${AppRoutes.settings}/'), isTrue);
      expect(AppRoutes.blockedUsers.startsWith('${AppRoutes.settings}/'), isTrue);
    });
  });

  group('the auth guard', () {
    test('only the four recovery and entry screens are public', () {
      expect(AppRoutes.publicPaths, {
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      });
    });

    test('a reset link still opens while signed in', () {
      expect(AppRoutes.guestOnlyPaths.contains(AppRoutes.resetPassword), isFalse);
      expect(AppRoutes.publicPaths.contains(AppRoutes.resetPassword), isTrue);
    });

    test('every guest-only path is also public', () {
      expect(AppRoutes.publicPaths.containsAll(AppRoutes.guestOnlyPaths), isTrue);
    });

    test('no signed-in screen is reachable without a token', () {
      for (final path in [
        AppRoutes.feed,
        AppRoutes.habits,
        AppRoutes.points,
        AppRoutes.profile,
        AppRoutes.settings,
        AppRoutes.notifications,
        AppRoutes.admin,
        AppRoutes.deleteAccount,
      ]) {
        expect(AppRoutes.publicPaths.contains(path), isFalse, reason: path);
      }
    });
  });

  group('the tab bar', () {
    test('has the four tabs in the web order', () {
      expect(AppRoutes.bottomNavPaths, [
        AppRoutes.feed,
        AppRoutes.habits,
        AppRoutes.points,
        AppRoutes.profile,
      ]);
    });

    test('none of the tabs is a public screen', () {
      for (final path in AppRoutes.bottomNavPaths) {
        expect(AppRoutes.publicPaths.contains(path), isFalse);
      }
    });
  });
}
