import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../core/theme/typography.dart';

/// The app's only text input: `bg-[#141414]`, a `#1F1F1F` hairline that turns
/// blue on focus, 14 pt text and a `#3C3C3C` placeholder.
///
/// The corner radius differs by screen in the web build — 16 on the auth
/// forms, 12 inside settings cards — so it is a parameter rather than a
/// constant.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.revealToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.radius = AppMetrics.radiusCard,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;

  /// Показывать «глаз» для пароля, как на экранах входа и сброса.
  final bool revealToggle;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  /// Hard cap on input length. The counter itself is drawn by the screen,
  /// because its colour changes per screen (grey → orange → red on the post
  /// composer, plain grey elsewhere).
  final int? maxLength;

  final double radius;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _focused = false;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obscured = widget.obscureText && !_revealed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: _focused ? AppColors.primary : AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              obscureText: obscured,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              autocorrect: widget.autocorrect,
              maxLines: obscured ? 1 : widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppColors.primary,
              style: AppText.field,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: widget.hintText,
                hintStyle: AppText.field.copyWith(color: AppColors.textGhost),
              ),
            ),
          ),
          if (widget.revealToggle)
            GestureDetector(
              onTap: () => setState(() => _revealed = !_revealed),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  _revealed ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ?widget.suffix,
        ],
      ),
    );
  }
}
