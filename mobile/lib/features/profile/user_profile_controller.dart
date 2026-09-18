import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../models/public_profile.dart';
import '../auth/auth_controller.dart';
import 'users_repository.dart';

class UserProfileController extends AsyncNotifier<PublicProfile> {
  UserProfileController(this.userId);

  final int userId;

  @override
  Future<PublicProfile> build() {
    return ref.read(usersRepositoryProvider).profile(userId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<String?> toggleFollow() async {
    final profile = state.value;
    if (profile == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'follow-$userId';
    if (!busy.start(key)) return null;

    state = AsyncData(profile.copyWith(
      isFollowing: !profile.isFollowing,
      followersCount: profile.isFollowing
          ? profile.followersCount - 1
          : profile.followersCount + 1,
    ));

    try {
      final result = await ref.read(usersRepositoryProvider).toggleFollow(userId);
      state = AsyncData(profile.copyWith(
        isFollowing: result.following,
        followersCount: result.followersCount,
      ));
      await ref.read(authControllerProvider.notifier).refresh();
      return null;
    } on ApiException catch (e) {
      state = AsyncData(profile);
      return e.message;
    } finally {
      busy.finish(key);
    }
  }
}

final userProfileProvider =
    AsyncNotifierProvider.family<UserProfileController, PublicProfile, int>(
  UserProfileController.new,
);
