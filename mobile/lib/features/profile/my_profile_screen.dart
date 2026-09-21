import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/time_ago.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/readx_logo.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'my_profile_controller.dart';
import 'profile_widgets.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileMenu(),
    );
    if (action == null || !context.mounted) return;

    if (action == 'settings') {
      unawaited(context.push(AppRoutes.settings));
      return;
    }

    final confirmed = await showConfirmSheet(
      context,
      title: 'Log Out?',
      message: "You'll need to log back in.",
      confirmLabel: 'Log Out',
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tab = ref.watch(profileTabProvider);

    if (user == null) {
      return const AppScaffold(body: LoadingState(), bottomNav: BottomNav());
    }

    return AppScaffold(
      header: AppHeader(
        middle: const ReadXLogo(),
        trailing: HeaderIconButton(
          icon: LucideIcons.ellipsis,
          semanticLabel: 'Menu',
          onTap: () => _menu(context, ref),
        ),
      ),
      bottomNav: const BottomNav(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(authControllerProvider.notifier).refresh();
          ref
            ..invalidate(myPostsProvider)
            ..invalidate(myLikedPostsProvider)
            ..invalidate(myCommentsProvider)
            ..invalidate(myLikedCommentsProvider);
        },
        child: ListView(
          key: const PageStorageKey('profile'),
          physics: const AlwaysScrollableScrollPhysics(),
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
                    avatarUrl: user.avatarUrl,
                    name: user.displayName,
                    size: 84,
                  ),
                ),
                const SizedBox(height: 14),
                Text(user.displayName, style: AppText.h1),
                const SizedBox(height: 2),
                Text(
                  '@${user.username}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                ProfileBadges(badges: user.badges),
                SocialLinks(instagram: user.instagram, telegram: user.telegram),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                FollowCounters(
                  followers: user.followersCount,
                  following: user.followingCount,
                  onFollowers: () => context.push(AppRoutes.userFollowers(user.id)),
                  onFollowing: () => context.push(AppRoutes.userFollowing(user.id)),
                ),
              ],
            ),
            if (user.showBook && user.bookName.isNotEmpty)
              CurrentlyReadingCard(
                bookName: user.bookName,
                bookAuthor: user.bookAuthor,
                currentPage: user.bookCurrentPage,
                totalPages: user.bookTotalPages,
              ),
            const SizedBox(height: 20),
            StatGrid(
              tiles: [
                StatTile(label: 'Total Points', value: '${user.totalPoints}'),
                StatTile(label: 'Monthly Points', value: '${user.monthlyPoints}'),
                StatTile(label: 'Posts', value: '${user.postCount}'),
                StatTile(label: 'Habits', value: '${user.habitCount}'),
                StatTile(label: 'Current Streak', value: '${user.currentStreak}'),
                StatTile(
                  label: 'Monthly Rank',
                  value: '#${user.monthlyRank}',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Tabs(
              tab: tab,
              onChanged: ref.read(profileTabProvider.notifier).select,
            ),
            const SizedBox(height: 16),
            ..._buildTabContent(context, ref, tab),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabContent(BuildContext context, WidgetRef ref, ProfileTab tab) {
    switch (tab) {
      case ProfileTab.posts:
        return [_PostList(async: ref.watch(myPostsProvider), onRetry: () => ref.invalidate(myPostsProvider))];
      case ProfileTab.comments:
        return [
          _CommentList(
            async: ref.watch(myCommentsProvider),
            onRetry: () => ref.invalidate(myCommentsProvider),
          ),
        ];
      case ProfileTab.likes:
        final sub = ref.watch(likesSubTabProvider);
        return [
          _SubTabs(
            sub: sub,
            onChanged: ref.read(likesSubTabProvider.notifier).select,
          ),
          const SizedBox(height: 12),
          if (sub == LikesSubTab.posts)
            _PostList(
              async: ref.watch(myLikedPostsProvider),
              onRetry: () => ref.invalidate(myLikedPostsProvider),
            )
          else
            _CommentList(
              async: ref.watch(myLikedCommentsProvider),
              onRetry: () => ref.invalidate(myLikedCommentsProvider),
            ),
        ];
    }
  }
}

class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
          border: Border.all(color: AppColors.surfaceHi2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, 'Settings', LucideIcons.settings, AppColors.textPrimary, 'settings'),
            const Divider(height: 1, thickness: 1, color: AppColors.surfaceHi2),
            _item(context, 'Logout', LucideIcons.logOut, AppColors.danger, 'logout'),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String value,
  ) {
    return Pressable(
      onTap: () => Navigator.of(context).pop(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onChanged});

  final ProfileTab tab;
  final ValueChanged<ProfileTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final item in ProfileTab.values)
          Expanded(
            child: Pressable(
              onTap: () => onChanged(item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: item == tab ? AppColors.primary : AppColors.border,
                    ),
                  ),
                ),
                child: Text(
                  switch (item) {
                    ProfileTab.posts => 'Posts',
                    ProfileTab.likes => 'Likes',
                    ProfileTab.comments => 'Comments',
                  },
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item == tab ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SubTabs extends StatelessWidget {
  const _SubTabs({required this.sub, required this.onChanged});

  final LikesSubTab sub;
  final ValueChanged<LikesSubTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.radiusField),
      ),
      child: Row(
        children: [
          for (final item in LikesSubTab.values)
            Expanded(
              child: Pressable(
                onTap: () => onChanged(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item == sub ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item == LikesSubTab.posts ? 'Posts' : 'Comments',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: item == sub ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.async, required this.onRetry});

  final AsyncValue<List<Post>> async;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (async) {
      AsyncData(:final value) when value.isEmpty => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Пока пусто',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      AsyncData(:final value) => Column(
          children: [
            for (final post in value)
              Pressable(
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
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            post.time.isEmpty ? timeAgo(post.createdAt) : post.time,
                            style: AppText.metaSm,
                          ),
                          const Spacer(),
                          const Icon(LucideIcons.heart, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${post.likes}', style: AppText.metaSm),
                          const SizedBox(width: 16),
                          const Icon(
                            LucideIcons.messageCircle,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.commentsCount}', style: AppText.metaSm),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      AsyncError(:final error) => ErrorState(
          message: error is ApiException ? error.message : 'Не удалось загрузить',
          onRetry: onRetry,
        ),
      _ => const LoadingState(padding: EdgeInsets.symmetric(vertical: 40)),
    };
  }
}

class _CommentList extends StatelessWidget {
  const _CommentList({required this.async, required this.onRetry});

  final AsyncValue<List<Comment>> async;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (async) {
      AsyncData(:final value) when value.isEmpty => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Пока пусто',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      AsyncData(:final value) => Column(
          children: [
            for (final comment in value)
              Pressable(
                onTap: () => context.push(AppRoutes.post(comment.postId)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textBody,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            comment.time.isEmpty ? timeAgo(comment.createdAt) : comment.time,
                            style: AppText.metaSm,
                          ),
                          const Spacer(),
                          const Icon(LucideIcons.heart, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${comment.likes}', style: AppText.metaSm),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      AsyncError(:final error) => ErrorState(
          message: error is ApiException ? error.message : 'Не удалось загрузить',
          onRetry: onRetry,
        ),
      _ => const LoadingState(padding: EdgeInsets.symmetric(vertical: 40)),
    };
  }
}
