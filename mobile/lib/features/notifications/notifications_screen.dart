import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/utils/time_ago.dart';
import '../../models/app_notification.dart';
import '../../router.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/pressable.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'notifications_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final me = ref.watch(currentUserProvider);
    final controller = ref.read(notificationsProvider.notifier);

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Notifications',
        trailing: const SizedBox(width: 36),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.refresh,
        child: switch (notifications) {
          AsyncData(:final value) when value.isEmpty => const EmptyState(
              icon: LucideIcons.bell,
              title: 'No notifications yet',
            ),
          AsyncData(:final value) => ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: value.length,
              itemBuilder: (context, index) => _NotificationTile(
                notification: value[index],
                onTap: () => _open(context, value[index], me?.id),
              ),
            ),
          AsyncError(:final error) => ErrorState(
              message: error is ApiException
                  ? error.message
                  : 'Не удалось загрузить уведомления',
              onRetry: controller.reload,
            ),
          _ => const LoadingState(),
        },
      ),
    );
  }

  void _open(BuildContext context, AppNotification notification, int? myId) {
    if (notification.postId != null) {
      context.push(AppRoutes.post(notification.postId!));
      return;
    }
    final actorId = notification.actorId;
    if (actorId != null) {
      context.push(actorId == myId ? AppRoutes.profile : AppRoutes.user(actorId));
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  (IconData, Color) get _badge => switch (notification.type) {
        NotificationType.like => (LucideIcons.heart, AppColors.danger),
        NotificationType.comment => (LucideIcons.messageCircle, AppColors.primary),
        NotificationType.follow => (LucideIcons.userPlus, AppColors.success),
        NotificationType.system => (LucideIcons.bell, AppColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _badge;
    final unread = !notification.isRead;

    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unread ? AppColors.bookIconBg : Colors.transparent,
          border: Border.all(
            color: unread ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(AppMetrics.radiusField),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  avatarUrl: notification.actorAvatar,
                  name: notification.actorUsername ?? 'ReadX',
                  size: 40,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 2),
                    ),
                    child: Icon(icon, size: 12, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(notification.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
