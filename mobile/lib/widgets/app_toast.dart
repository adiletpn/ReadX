import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';

/// The bottom toast the web slides up with `motion.div`: 96 pt from the
/// bottom, 16 pt side margins, 13 pt semibold white text on blue — or on red
/// when something failed.
///
/// It lives in the overlay so it survives navigation the way a page-level
/// fixed element does, and only one is on screen at a time.
abstract class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || message.isEmpty) return;

    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        isError: isError,
        duration: duration,
        onFinished: () {
          if (_current == entry) dismiss();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  /// Убрать тост досрочно — например, при уходе с экрана.
  static void dismiss() {
    _current?.remove();
    _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.isError,
    required this.duration,
    required this.onFinished,
  });

  final String message;
  final bool isError;
  final Duration duration;
  final VoidCallback onFinished;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: AppMetrics.toastBottom + bottomInset,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 358),
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.6),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppMetrics.hPadding),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isError ? AppColors.danger : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppMetrics.radiusField),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
