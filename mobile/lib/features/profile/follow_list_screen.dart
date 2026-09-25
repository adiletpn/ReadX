import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../models/public_profile.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'users_repository.dart';

enum FollowListKind { followers, following }

class FollowListArgs {
  const FollowListArgs(this.userId, this.kind);

  final int userId;
  final FollowListKind kind;

  @override
  bool operator ==(Object other) =>
      other is FollowListArgs && other.userId == userId && other.kind == kind;

  @override
  int get hashCode => Object.hash(userId, kind);
}

class FollowListController extends AsyncNotifier<List<FollowUser>> {
  FollowListController(this.args);

  final FollowListArgs args;

  @override
  Future<List<FollowUser>> build() {
    final repo = ref.read(usersRepositoryProvider);
    return args.kind == FollowListKind.followers
        ? repo.followers(args.userId)
        : repo.following(args.userId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<String?> toggleFollow(int targetId) async {
    final users = state.value;
    if (users == null) return null;

    final busy = ref.read(busySetProvider.notifier);
    final key = 'follow-$targetId';
    if (!busy.start(key)) return null;

    final index = users.indexWhere((u) => u.id == targetId);
    if (index == -1) {
      busy.finish(key);
      return null;
    }

    final previous = users[index];
    _replace(previous.copyWith(isFollowing: !previous.isFollowing));

    try {
      final result = await ref.read(usersRepositoryProvider).toggleFollow(targetId);
      _replace(previous.copyWith(isFollowing: result.following));
      await ref.read(authControllerProvider.notifier).refresh();
      return null;
    } on ApiException catch (e) {
      _replace(previous);
      return e.message;
    } finally {
      busy.finish(key);
    }
  }

  void _replace(FollowUser user) {
    final users = state.value;
    if (users == null) return;
    final index = users.indexWhere((u) => u.id == user.id);
    if (index == -1) return;
    final next = [...users];
    next[index] = user;
    state = AsyncData(next);
  }
}

final followListProvider = AsyncNotifierProvider.family<FollowListController,
    List<FollowUser>, FollowListArgs>(FollowListController.new);

class FollowListScreen extends ConsumerWidget {
  const FollowListScreen({super.key, required this.userId, required this.kind});

  final int userId;
  final FollowListKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = FollowListArgs(userId, kind);
    final list = ref.watch(followListProvider(args));
    final me = ref.watch(currentUserProvider);
    final busy = ref.watch(busySetProvider);
    final controller = ref.read(followListProvider(args).notifier);

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: kind == FollowListKind.followers ? 'Followers' : 'Following',
        trailing: const SizedBox(width: 36),
      ),
      body: switch (list) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
            icon: LucideIcons.users,
            title: kind == FollowListKind.followers ? 'No followers yet' : 'Not following anyone yet',
          ),
        AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: value.length,
            itemBuilder: (context, index) {
              final user = value[index];
              return _Row(
                user: user,
                isMe: user.id == me?.id,
                busy: busy.contains('follow-${user.id}'),
                onTap: () => context.push(
                  user.id == me?.id ? AppRoutes.profile : AppRoutes.user(user.id),
                ),
                onToggleFollow: () async {
                  final error = await controller.toggleFollow(user.id);
                  if (error != null && context.mounted) {
                    AppToast.show(context, error, isError: true);
                  }
                },
              );
            },
          ),
        AsyncError(:final error) => ErrorState(
            message: error is ApiException ? error.message : 'Не удалось загрузить список',
            onRetry: controller.reload,
          ),
        _ => const LoadingState(),
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.user,
    required this.isMe,
    required this.busy,
    required this.onTap,
    required this.onToggleFollow,
  });

  final FollowUser user;
  final bool isMe;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            UserAvatar(avatarUrl: user.avatarUrl, name: user.displayName, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (!isMe) ...[
              const SizedBox(width: 12),
              Pressable(
                onTap: busy ? null : onToggleFollow,
                pressedOpacity: 0.8,
                child: Opacity(
                  opacity: busy ? 0.5 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: user.isFollowing ? AppColors.surfaceHi : AppColors.primary,
                      border: Border.all(
                        color: user.isFollowing ? AppColors.surfaceHi2 : AppColors.primary,
                      ),
                      borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                    ),
                    child: Text(
                      user.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
