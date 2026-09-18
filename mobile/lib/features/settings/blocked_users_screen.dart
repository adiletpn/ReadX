import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../models/public_profile.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../feed/feed_controller.dart';
import '../profile/users_repository.dart';

final blockedUsersProvider = FutureProvider<List<FollowUser>>((ref) async {
  return ref.read(usersRepositoryProvider).blockedUsers();
});

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedUsersProvider);

    Future<void> unblock(int id) async {
      try {
        await ref.read(usersRepositoryProvider).unblock(id);
        ref.invalidate(blockedUsersProvider);
        ref.read(feedProvider.notifier).invalidateCache();
      } on ApiException catch (e) {
        if (context.mounted) AppToast.show(context, e.message, isError: true);
      }
    }

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Blocked Users',
        trailing: const SizedBox(width: 36),
      ),
      body: switch (blocked) {
        AsyncData(:final value) when value.isEmpty => const EmptyState(
            icon: LucideIcons.userX,
            title: 'Никто не заблокирован',
            subtitle: 'Заблокированные пользователи появятся здесь.',
          ),
        AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: value.length,
            itemBuilder: (context, index) {
              final user = value[index];
              return Padding(
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
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Pressable(
                      onTap: () => unblock(user.id),
                      pressedOpacity: 0.8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHi,
                          border: Border.all(color: const Color(0xFF333333)),
                          borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                        ),
                        child: const Text(
                          'Unblock',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        AsyncError(:final error) => ErrorState(
            message: error is ApiException ? error.message : 'Не удалось загрузить список',
            onRetry: () => ref.invalidate(blockedUsersProvider),
          ),
        _ => const LoadingState(),
      },
    );
  }
}
