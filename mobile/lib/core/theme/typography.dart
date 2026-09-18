import 'package:flutter/painting.dart';

import 'colors.dart';

abstract class AppText {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.6,
    fontFeatures: _tabular,
  );

  static const counter = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.4,
    fontFeatures: _tabular,
  );

  static const counterMd = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.2,
    fontFeatures: _tabular,
  );

  static const counterSm = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.0,
    fontFeatures: _tabular,
  );

  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
  );

  static const modalTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const action = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.45,
    letterSpacing: -0.1,
  );

  static const author = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const field = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static const caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
    letterSpacing: -0.05,
  );

  static const commentBody = TextStyle(
    fontSize: 14,
    color: AppColors.textBody,
    height: 1.45,
    letterSpacing: -0.1,
  );

  static const meta = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  static const metaSm = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
    fontFeatures: _tabular,
  );

  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.4,
  );
}
