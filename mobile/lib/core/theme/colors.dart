import 'package:flutter/painting.dart';

abstract class AppColors {
  static const bg = Color(0xFF15171C);
  static const surface = Color(0xFF1D2026);
  static const surfaceAlt = Color(0xFF22252C);
  static const surfaceHi = Color(0xFF2A2E37);
  static const surfaceHi2 = Color(0xFF353A45);
  static const border = Color(0xFF282C34);
  static const borderBright = Color(0xFF3A3F4A);

  static const primary = Color(0xFF0077FF);
  static const primaryBright = Color(0xFF3D9BFF);
  static const primaryDeep = Color(0xFF0057C2);
  static const cyan = Color(0xFF00D4FF);

  static const danger = Color(0xFFFF453A);
  static const success = Color(0xFF30D158);
  static const warning = Color(0xFFFF9F0A);
  static const ember = Color(0xFFFF6A3D);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textBody = Color(0xFFC7CAD1);
  static const textSecondary = Color(0xFF8E93A0);
  static const textMuted = Color(0xFF6C7280);
  static const textFaint = Color(0xFF5D6371);
  static const textDisabled = Color(0xFF474D5A);
  static const textGhost = Color(0xFF4E5561);

  static const primary10 = Color(0x1A0077FF);
  static const primary30 = Color(0x4D0077FF);
  static const success15 = Color(0x2630D158);
  static const danger10 = Color(0x1AFF453A);
  static const danger30 = Color(0x4DFF453A);
  static const habitDoneBg = Color(0xFF16301F);
  static const habitDoneBorder = Color(0xFF2E5C42);
  static const bookIconBg = Color(0xFF1F3150);

  static const brandGradient = [primary, cyan];
  static const streakGradient = [warning, ember];
  static const surfaceGradient = [Color(0xFF242832), Color(0xFF1B1E25)];

  static const glowPrimary = Color(0x3D0077FF);
  static const glowWarning = Color(0x3DFF9F0A);
}
