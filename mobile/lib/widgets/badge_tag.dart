import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/badge.dart' as models;

/// Badge chip. The tint is the badge's own `bg_color`: text at full strength,
/// fill at 10 % and border at 30 % — the alpha suffixes BadgeTag.tsx appends
/// to the hex.
///
/// The icon is picked from keywords in the badge name, exactly as the web
/// does, so an admin renaming a badge changes its icon in both clients.
class BadgeTag extends StatelessWidget {
  const BadgeTag({super.key, required this.badge, this.small = false});

  final models.Badge badge;

  /// `size="xs"` в вебе — 9 pt вместо 11.
  final bool small;

  static const _fallbackTint = Color(0xFF0077FF);

  static Color _parseHex(String value) {
    final hex = value.trim().replaceFirst('#', '');
    if (hex.length != 6) return _fallbackTint;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? _fallbackTint : Color(0xFF000000 | parsed);
  }

  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('fire') || n.contains('hot') || n.contains('streak')) return LucideIcons.flame;
    if (n.contains('star') || n.contains('top')) return LucideIcons.star;
    if (n.contains('pro') || n.contains('elite') || n.contains('expert')) return LucideIcons.zap;
    if (n.contains('admin') || n.contains('mod') || n.contains('guard')) return LucideIcons.shield;
    if (n.contains('king') || n.contains('queen') || n.contains('royal') || n.contains('founder')) {
      return LucideIcons.crown;
    }
    if (n.contains('diamond') || n.contains('gem') || n.contains('vip')) return LucideIcons.gem;
    if (n.contains('active') || n.contains('live')) return LucideIcons.activity;
    if (n.contains('award') || n.contains('winner') || n.contains('first')) return LucideIcons.award;
    return LucideIcons.sparkles;
  }

  @override
  Widget build(BuildContext context) {
    final tint = _parseHex(badge.bgColor);
    final fontSize = small ? 9.0 : 11.0;
    final iconSize = small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(badge.name), size: iconSize, color: tint),
          const SizedBox(width: 4),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
