import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/surfaces.dart';
import '../../models/badge.dart' as models;
import '../../widgets/badge_tag.dart';
import '../../widgets/pressable.dart';

class ProfileBadges extends StatelessWidget {
  const ProfileBadges({super.key, required this.badges});

  final List<models.Badge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [for (final badge in badges) BadgeTag(badge: badge)],
      ),
    );
  }
}

class SocialLinks extends StatelessWidget {
  const SocialLinks({super.key, required this.instagram, required this.telegram});

  final String instagram;
  final String telegram;

  static const _instagramSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">'
      '<rect x="2" y="2" width="20" height="20" rx="5" stroke="#A0A0A0" stroke-width="2"/>'
      '<circle cx="12" cy="12" r="5" stroke="#A0A0A0" stroke-width="2"/>'
      '<circle cx="17.5" cy="6.5" r="1.5" fill="#A0A0A0"/></svg>';

  static const _telegramSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#A0A0A0">'
      '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8'
      'c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58'
      '-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69a.2.2 0 00-.05'
      '-.18c-.06-.05-.14-.03-.21-.02-.09.02-1.49.95-4.22 2.79-.4.27-.76.41-1.08.4-.36-.01'
      '-1.04-.2-1.55-.37-.63-.2-1.12-.31-1.08-.66.02-.18.27-.36.74-.55 2.92-1.27 4.86-2.11'
      ' 5.83-2.51 2.78-1.16 3.35-1.36 3.73-1.36.08 0 .27.02.39.12.1.08.13.19.14.27-.01.06'
      '.01.24 0 .38z"/></svg>';

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _handle(String raw) => raw.trim().replaceFirst(RegExp(r'^@'), '');

  @override
  Widget build(BuildContext context) {
    final links = <(String, String)>[
      if (instagram.trim().isNotEmpty)
        (_instagramSvg, 'https://instagram.com/${_handle(instagram)}'),
      if (telegram.trim().isNotEmpty)
        (_telegramSvg, 'https://t.me/${_handle(telegram)}'),
    ];
    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (svg, url) in links)
            Pressable(
              onTap: () => _open(url),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SvgPicture.string(svg, width: 16, height: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class FollowCounters extends StatelessWidget {
  const FollowCounters({
    super.key,
    required this.followers,
    required this.following,
    required this.onFollowers,
    required this.onFollowing,
  });

  final int followers;
  final int following;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _counter('$followers', 'Followers', onFollowers),
          const SizedBox(width: 32),
          _counter('$following', 'Following', onFollowing),
        ],
      ),
    );
  }

  Widget _counter(String value, String label, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class CurrentlyReadingCard extends StatelessWidget {
  const CurrentlyReadingCard({
    super.key,
    required this.bookName,
    required this.bookAuthor,
    required this.currentPage,
    required this.totalPages,
  });

  final String bookName;
  final String bookAuthor;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final done = totalPages > 0 && currentPage >= totalPages;
    final progress = totalPages == 0 ? 0.0 : (currentPage / totalPages).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bookIconBg,
              borderRadius: BorderRadius.circular(AppMetrics.radiusField),
              border: Border.all(color: AppColors.primary30),
            ),
            child: const Icon(LucideIcons.bookOpen, size: 22, color: AppColors.primaryBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (bookAuthor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    bookAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
                if (totalPages > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        done ? 'Дочитано' : '$currentPage / $totalPages стр.',
                        style: TextStyle(
                          fontSize: 12,
                          color: done ? AppColors.success : AppColors.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (done)
                        const Text(
                          '✓ 100%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
                    child: Stack(
                      children: [
                        Container(height: 8, color: AppColors.surfaceHi),
                        LayoutBuilder(
                          builder: (context, box) => AnimatedContainer(
                            duration: AppDuration.slow,
                            curve: Curves.easeOutCubic,
                            height: 8,
                            width: box.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: done
                                    ? const [AppColors.success, Color(0xFF7BE495)]
                                    : AppColors.brandGradient,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatTile {
  const StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Красит цифру. Без него цифра белая.
  final Color? color;

  /// Заливает карточку — для двух главных показателей, очков и ранга.
  final List<Color>? gradient;

  bool get isHero => gradient != null;
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles, this.columns = 2});

  final List<StatTile> tiles;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.75,
      children: [
        for (final tile in tiles) _StatCard(tile: tile),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.tile});

  final StatTile tile;

  @override
  Widget build(BuildContext context) {
    final accent = tile.gradient?.first ?? tile.color ?? AppColors.primaryBright;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: tile.isHero
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tile.gradient!,
              ),
              borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.32),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : AppSurfaces.card(radius: AppMetrics.radiusCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tile.isHero
                      ? AppColors.textPrimary.withValues(alpha: 0.22)
                      : accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tile.icon,
                  size: 13,
                  color: tile.isHero ? AppColors.textPrimary : accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tile.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: tile.isHero
                        ? AppColors.textPrimary.withValues(alpha: 0.85)
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          Text(
            tile.value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1,
              color: tile.isHero ? AppColors.textPrimary : (tile.color ?? AppColors.textPrimary),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
