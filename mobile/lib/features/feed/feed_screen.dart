import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/busy_set.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/surfaces.dart';
import '../../core/theme/typography.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/confirm_sheet.dart';
import '../../widgets/entrance.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/post_card.dart';
import '../../widgets/pressable.dart';
import '../../widgets/readx_logo.dart';
import '../../widgets/shared_habit_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import '../moderation/moderation_menu.dart';
import '../notifications/notifications_repository.dart';
import '../profile/users_repository.dart';
import 'feed_controller.dart';
import 'posts_repository.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _like(int postId) async {
    final error = await ref.read(feedProvider.notifier).toggleLike(postId);
    if (error != null && mounted) {
      AppToast.show(context, 'Не удалось поставить лайк', isError: true);
    }
  }

  Future<void> _delete(int postId) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete post?',
      message: 'Are you sure you want to delete this post?',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(feedProvider.notifier).deletePost(postId);
      await ref.read(authControllerProvider.notifier).refresh();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final tab = ref.watch(feedTabProvider);
    final user = ref.watch(currentUserProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final busy = ref.watch(busySetProvider);

    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: _FeedFilterDrawer(
        selected: tab,
        onSelect: (next) {
          Navigator.of(context).pop();
          ref.read(feedTabProvider.notifier).select(next);
        },
      ),
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.menu,
          semanticLabel: 'Menu',
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        middle: const ReadXLogo(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NotificationsButton(unread: unread),
            HeaderIconButton(
              icon: LucideIcons.search,
              semanticLabel: 'Search',
              size: 21,
              onTap: () => context.push(AppRoutes.search),
            ),
          ],
        ),
      ),
      bottomNav: const BottomNav(),
      floatingActionButton: Pressable(
        onTap: () => context.push(AppRoutes.postNew),
        scale: 0.9,
        pressedOpacity: 0.85,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.brandGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x660077FF),
                blurRadius: 26,
                spreadRadius: -4,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(LucideIcons.plus, size: 26, color: AppColors.textPrimary),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          key: const PageStorageKey('feed'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ComposeRow(avatarUrl: user?.avatarUrl, name: user?.username ?? '')),
            SliverToBoxAdapter(child: _HintBar(tab: tab)),
            switch (feed) {
              AsyncData(:final value) when value.isEmpty => SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No posts yet',
                    subtitle: tab == FeedTab.following
                        ? 'Follow people to see their posts here!'
                        : 'Be the first to share something!',
                  ),
                ),
              AsyncData(:final value) => SliverList.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final post = value[index];
                    return Entrance(
                      index: index,
                      child: PostCard(
                      post: post,
                      currentUserId: user?.id,
                      likeBusy: busy.contains('like-post-${post.id}'),
                      onLike: () => _like(post.id),
                      onComment: () => context.push(AppRoutes.post(post.id)),
                      onOpenUser: () => context.push(
                        post.userId == user?.id ? AppRoutes.profile : AppRoutes.user(post.userId),
                      ),
                      onDelete: () => _delete(post.id),
                      onMore: () => showModerationMenu(
                        context,
                        ref,
                        target: ReportTarget.post,
                        targetId: post.id,
                        authorId: post.userId,
                        username: post.username,
                        onBlocked: () => ref.read(feedProvider.notifier).refresh(),
                      ),
                      sharedHabitCard: post.sharedHabit == null
                          ? null
                          : SharedHabitCard(
                              sharedHabit: post.sharedHabit!,
                              onChanged: (updated) => ref
                                  .read(feedProvider.notifier)
                                  .upsert(post.copyWith(sharedHabit: updated)),
                            ),
                      ),
                    );
                  },
                ),
              AsyncError(:final error) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    message: error is ApiException ? error.message : 'Не удалось загрузить ленту',
                    onRetry: () => ref.read(feedProvider.notifier).reload(),
                  ),
                ),
              _ => const SliverToBoxAdapter(child: FeedSkeleton()),
            },
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        HeaderIconButton(
          icon: LucideIcons.bell,
          semanticLabel: 'Notifications',
          size: 21,
          onTap: () => context.push(AppRoutes.notifications),
        ),
        if (unread > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16),
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ComposeRow extends StatelessWidget {
  const _ComposeRow({required this.avatarUrl, required this.name});

  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 16, AppMetrics.hPadding, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.brandGradient),
            ),
            child: UserAvatar(avatarUrl: avatarUrl, name: name, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Pressable(
              onTap: () => context.push(AppRoutes.postNew),
              scale: 0.98,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: AppSurfaces.flat(radius: AppMetrics.radiusChip),
                child: const Text(
                  "What's on your mind?",
                  style: TextStyle(fontSize: 15, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBar extends StatelessWidget {
  const _HintBar({required this.tab});

  final FeedTab tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 0, AppMetrics.hPadding, 16),
      child: Row(
        children: [
          const Icon(LucideIcons.flame, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tab.hint,
              style: AppText.metaSm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Pressable(
            onTap: () => context.push(AppRoutes.points),
            child: const Text(
              'View Ranking',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedFilterDrawer extends StatelessWidget {
  const _FeedFilterDrawer({required this.selected, required this.onSelect});

  final FeedTab selected;
  final ValueChanged<FeedTab> onSelect;

  static const _icons = {
    FeedTab.following: LucideIcons.users,
    FeedTab.global: LucideIcons.globe,
    FeedTab.liked: LucideIcons.heart,
  };

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Drawer(
      width: 280,
      backgroundColor: AppColors.surface,
      shape: const Border(right: BorderSide(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 64 + topInset,
            padding: EdgeInsets.only(top: topInset, left: 16, right: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Feed Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                HeaderIconButton(
                  icon: LucideIcons.x,
                  size: 20,
                  semanticLabel: 'Close',
                  color: AppColors.textSecondary,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                for (final tab in [FeedTab.following, FeedTab.global, FeedTab.liked])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Pressable(
                      onTap: () => onSelect(tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: tab == selected ? AppColors.primary10 : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _icons[tab],
                              size: 20,
                              color: tab == selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: tab == selected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
