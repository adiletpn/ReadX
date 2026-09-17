
import 'package:flutter/painting.dart';

import 'colors.dart';

/// Text styles mapped one-to-one from the web's Tailwind sizes (§4.2 of the
/// spec). The font family is left unset on purpose: Flutter falls back to the
/// Cupertino default, which is the same SF Pro the web gets from
/// `-apple-system`.
abstract class AppText {
  /// Numbers are rendered with tabular figures everywhere, the way the web
  /// uses `tabular-nums`, so counters do not jitter while they animate.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Крупные счётчики: очки, ранг.
  static const counter = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
    fontFeatures: _tabular,
  );

  /// Счётчик группового стрика на экране совместной привычки.
  static const counterMd = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
    fontFeatures: _tabular,
  );

  /// Счётчик стрика на карточке привычки.
  static const counterSm = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
    fontFeatures: _tabular,
  );

  /// Заголовок H1 профиля и карточки совместной привычки.
  static const h1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Заголовок модалки.
  static const modalTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Название привычки, заголовок карточки.
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Заголовок в шапке и подписи кнопок Save / Post.
  static const action = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Текст поста.
  static const body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Имя автора поста.
  static const author = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Поля ввода и тело карточек.
  static const field = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  /// Комментарии и подписи под полями.
  static const caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  /// Текст комментария — светлее обычных подписей.
  static const commentBody = TextStyle(
    fontSize: 13,
    color: AppColors.textBody,
    height: 1.4,
  );

  /// Время под именем автора, мелкие подписи.
  static const meta = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  /// Самые мелкие подписи: время в карточке, счётчики символов.
  static const metaSm = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  /// Микрозаголовки секций: MY HABITS, COMMENTS, ACCOUNT.
  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );
}
