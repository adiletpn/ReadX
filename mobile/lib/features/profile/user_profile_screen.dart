import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/time_ago.dart';
import '../../models/post.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../moderation/moderation_menu.dart';
import 'users_repository.dart';
import 'profile_widgets.dart';
import 'user_profile_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    if (me != null && me.id == userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pushReplacement(AppRoutes.profile);
      });
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: LoadingState(),
      );
    }

    final profile = ref.watch(userProfileProvider(userId));
    final busy = ref.watch(busySetProvider);
    final controller = ref.read(userProfileProvider(userId).notifier);

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Profile',
        trailing: profile.hasValue
            ? HeaderIconButton(
                icon: LucideIcons.ellipsis,
                semanticLabel: 'More',
                onTap: () => showModerationMenu(
                  context,
                  ref,
                  target: ReportTarget.user,
                  targetId: userId,
                  authorId: userId,
                  username: profile.value!.username,
                  onBlocked: () {
                    if (context.mounted) context.pop();
                  },
                ),
              )
            : const SizedBox(width: 36),
      ),
      body: switch (profile) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 22, AppMetrics.hPadding, 36),
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: AppColors.brandGradient),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowPrimary,
                          blurRadius: 28,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      avatarUrl: value.avatarUrl,
                      name: value.displayName,
                      size: 84,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(value.displayName, style: AppText.h1),
                  const SizedBox(height: 2),
                  Text(
                    '@${value.username}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  ProfileBadges(badges: value.badges),
                  SocialLinks(instagram: value.instagram, telegram: value.telegram),
                  if (value.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      value.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  FollowCounters(
                    followers: value.followersCount,
                    following: value.followingCount,
                    onFollowers: () => context.push(AppRoutes.userFollowers(userId)),
                    onFollowing: () => context.push(AppRoutes.userFollowing(userId)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FollowButton(
                isFollowing: value.isFollowing,
                busy: busy.contains('follow-$userId'),
                onTap: () async {
                  final error = await controller.toggleFollow();
                  if (error != null && context.mounted) {
                    AppToast.show(context, error, isError: true);
                  }
                },
              ),
              if (value.showBook && value.bookName.isNotEmpty)
                CurrentlyReadingCard(
                  bookName: value.bookName,
                  bookAuthor: value.bookAuthor,
                  currentPage: value.bookCurrentPage,
                  totalPages: value.bookTotalPages,
                ),
              const SizedBox(height: 20),
              StatGrid(
                tiles: [
                  StatTile(
                    label: 'Total Points',
                    value: '${value.totalPoints}',
                    icon: LucideIcons.sparkles,
                    gradient: AppColors.brandGradient,
                  ),
                  StatTile(
                    label: 'Monthly Points',
                    value: '${value.monthlyPoints}',
                    icon: LucideIcons.calendar,
                    color: AppColors.primaryBright,
                  ),
                  StatTile(
                    label: 'Posts',
                    value: '${value.postsCount}',
                    icon: LucideIcons.penLine,
                  ),
                  StatTile(
                    label: 'Habits',
                    value: '${value.habitCount}',
                    icon: LucideIcons.target,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('POSTS', style: AppText.overline),
              const SizedBox(height: 12),
              if (value.posts.isEmpty)
                const Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                )
              else
                for (final post in value.posts) _ProfilePostRow(post: post),
            ],
          ),
        AsyncError(:final error) => ErrorState(
            message: error is ApiException ? error.message : 'Не удалось загрузить профиль',
            onRetry: controller.reload,
          ),
        _ => const LoadingState(),
      },
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.busy,
    required this.onTap,
  });

  final bool isFollowing;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: busy ? null : onTap,
      pressedOpacity: 0.8,
      child: Opacity(
        opacity: busy ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? AppColors.surfaceHi : AppColors.primary,
            border: Border.all(
              color: isFollowing ? AppColors.surfaceHi2 : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePostRow extends StatelessWidget {
  const _ProfilePostRow({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push(AppRoutes.post(post.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(timeAgo(post.createdAt), style: AppText.metaSm),
                const Spacer(),
                const Icon(LucideIcons.heart, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.likes}', style: AppText.metaSm),
                const SizedBox(width: 16),
                const Icon(LucideIcons.messageCircle, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.commentsCount}', style: AppText.metaSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
