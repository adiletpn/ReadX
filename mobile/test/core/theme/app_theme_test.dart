import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/theme/app_theme.dart';
import 'package:readx/core/theme/colors.dart';
import 'package:readx/core/theme/typography.dart';

void main() {
  late ThemeData theme;

  setUp(() => theme = AppTheme.build());

  test('the app is dark only, with no light palette to fall back to', () {
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.brightness, Brightness.dark);
  });

  test('both the scaffold and the canvas use the app background', () {
    expect(theme.scaffoldBackgroundColor, AppColors.bg);
    expect(theme.canvasColor, AppColors.bg);
  });

  test('the colour scheme carries the accent and the danger colour', () {
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.colorScheme.error, AppColors.danger);
  });

  test('Material ink effects are off so taps feel like the web', () {
    expect(theme.splashFactory, NoSplash.splashFactory);
    expect(theme.splashColor, Colors.transparent);
    expect(theme.highlightColor, Colors.transparent);
    expect(theme.hoverColor, Colors.transparent);
  });

  test('the caret and selection are blue', () {
    expect(theme.textSelectionTheme.cursorColor, AppColors.primary);
    expect(theme.textSelectionTheme.selectionColor, AppColors.primary30);
  });

  test('Cupertino widgets inherit the same dark palette', () {
    expect(theme.cupertinoOverrideTheme?.brightness, Brightness.dark);
    expect(theme.cupertinoOverrideTheme?.primaryColor, AppColors.primary);
  });

  test('the default text styles come from the app scale', () {
    expect(theme.textTheme.bodyLarge, AppText.body);
    expect(theme.textTheme.bodyMedium, AppText.field);
    expect(theme.textTheme.titleMedium, AppText.action);
  });

  test('icons default to white at 24 pt', () {
    expect(theme.iconTheme.color, AppColors.textPrimary);
    expect(theme.iconTheme.size, 24);
  });

  test('progress indicators are blue on the raised surface', () {
    expect(theme.progressIndicatorTheme.color, AppColors.primary);
    expect(theme.progressIndicatorTheme.linearTrackColor, AppColors.surfaceHi2);
  });

  test('building it twice gives the same theme', () {
    expect(AppTheme.build().scaffoldBackgroundColor, theme.scaffoldBackgroundColor);
    expect(AppTheme.build().colorScheme.primary, theme.colorScheme.primary);
  });
}
