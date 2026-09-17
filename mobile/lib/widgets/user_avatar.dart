import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/utils/media_url.dart';

/// Round avatar with the web's fallback: a `#1F1F1F` circle holding the first
/// letter of the name. Paths from the API are relative, so they always go
/// through `mediaUrl()`.
///
/// A 404 (a file deleted on the server) falls back to the initials too rather
/// than showing a broken image.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 40,
  });

  final String? avatarUrl;

  /// Имя или username — из него берётся буква для плейсхолдера.
  final String name;

  final double size;

  @override
  Widget build(BuildContext context) {
    final url = mediaUrl(avatarUrl);

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? _Initials(name: name, size: size)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                placeholder: (_, _) => _Initials(name: name, size: size),
                errorWidget: (_, _, _) => _Initials(name: name, size: size),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceHi,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
