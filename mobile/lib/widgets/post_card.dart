import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/haptics.dart';
import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../core/theme/surfaces.dart';
import '../core/utils/media_url.dart';
import '../models/post.dart';
import 'animated_like_button.dart';
import 'pressable.dart';
import 'user_avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onOpenUser,
    this.onDelete,
    this.onMore,
    this.likeBusy = false,
    this.sharedHabitCard,
  });

  final Post post;
  final int? currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onOpenUser;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;
  final bool likeBusy;
  final Widget? sharedHabitCard;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _expanded = false;

  bool get _isLong => widget.post.content.length > 180;

  bool get _isMine =>
      widget.currentUserId != null && widget.currentUserId == widget.post.userId;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final imageUrl = mediaUrl(post.imageUrl);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppMetrics.hPadding, 0, AppMetrics.hPadding, 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: AppSurfaces.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onTap: widget.onOpenUser,
            pressedOpacity: 0.8,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderBright),
              ),
              child: UserAvatar(
                avatarUrl: post.avatarUrl,
                name: post.username,
                size: 42,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Pressable(
                        onTap: widget.onOpenUser,
                        pressedOpacity: 0.8,
                        child: Text(
                          post.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.time,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  maxLines: _expanded ? null : 4,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    letterSpacing: -0.1,
                    color: AppColors.textBody,
                  ),
                ),
                if (_isLong && !_expanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Pressable(
                      onTap: () => setState(() => _expanded = true),
                      child: const Text(
                        'Read more',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                if (imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 350),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const _ImagePlaceholder(),
                        errorWidget: (_, _, _) => const _ImagePlaceholder(),
                      ),
                    ),
                  ),
                ],
                if (widget.sharedHabitCard != null) ...[
                  const SizedBox(height: 8),
                  widget.sharedHabitCard!,
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Flexible, not a bare Row: the counters are the only part
                    // of the card whose width the server decides, and a reader
                    // running iOS at a large text size scales them further. A
                    // fixed row turns that into a striped overflow box.
                    Flexible(
                      child: AnimatedLikeButton(
                        liked: post.liked,
                        likes: post.likes,
                        onTap: () {
                          Haptics.light();
                          widget.onLike();
                        },
                        busy: widget.likeBusy,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Pressable(
                        onTap: widget.onComment,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.messageCircle,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${post.commentsCount}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_isMine && widget.onDelete != null)
                      Pressable(
                        onTap: widget.onDelete,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                        ),
                      )
                    else if (!_isMine && widget.onMore != null)
                      Pressable(
                        onTap: widget.onMore,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            LucideIcons.ellipsis,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(height: 200, color: AppColors.surface);
  }
}
