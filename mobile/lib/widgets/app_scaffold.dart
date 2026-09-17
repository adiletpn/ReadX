import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';

/// The frame every screen sits in: dark background, the content column capped
/// at 390 pt and centred (the web's `max-w-[390px] mx-auto`), and safe areas
/// handled once instead of on each page.
///
/// The web pins its header and bottom nav with `position: fixed` and pads the
/// scroll area to clear them. Here they are real rows in a column instead:
/// both bars are opaque, so the result looks the same and no screen can get
/// its content stuck underneath the nav.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.header,
    this.bottomNav,
    this.bottomBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  /// Шапка высотой 56 + safe area сверху.
  final Widget? header;

  final Widget body;

  /// Нижняя навигация. Её safe area она добавляет себе сама.
  final Widget? bottomNav;

  /// Закреплённая снизу панель действия (Save, Mark as Done, поле
  /// комментария). Она идёт над навигацией и поднимается над клавиатурой.
  final Widget? bottomBar;

  /// Синяя круглая кнопка в правом нижнем углу контента.
  final Widget? floatingActionButton;

  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget content = body;
    if (floatingActionButton != null) {
      content = Stack(
        children: [
          Positioned.fill(child: content),
          Positioned(right: 20, bottom: 16, child: floatingActionButton!),
        ],
      );
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?header,
        Expanded(child: content),
        if (bottomBar != null)
          Padding(
            // Lift the pinned bar above the keyboard, the way a fixed element
            // behaves in mobile Safari once the viewport shrinks.
            padding: EdgeInsets.only(
              bottom: resizeToAvoidBottomInset ? 0 : mediaQuery.viewInsets.bottom,
            ),
            child: bottomBar!,
          ),
        ?bottomNav,
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppMetrics.contentWidth),
          child: column,
        ),
      ),
    );
  }
}
