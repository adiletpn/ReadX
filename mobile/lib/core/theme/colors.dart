import 'package:flutter/painting.dart';

/// Every colour the web app uses, taken from the hex literals written straight
/// into its Tailwind classes (the project has no design tokens to import).
abstract class AppColors {
  static const bg = Color(0xFF0F0F10); // фон всего приложения
  static const surface = Color(0xFF141414); // карточки, инпуты
  static const surfaceAlt = Color(0xFF1A1A1A); // модалки, disabled-кнопки
  static const surfaceHi = Color(0xFF1F1F1F); // границы, аватар-плейсхолдер, меню
  static const surfaceHi2 = Color(0xFF2A2A2A); // вторичные кнопки, трек прогресса
  static const border = Color(0xFF1F1F1F); // все разделители и рамки

  static const primary = Color(0xFF0077FF); // акцент: кнопки, активные табы, ссылки
  static const danger = Color(0xFFFF3B30); // удаление, ошибки, бейдж, лайк
  static const success = Color(0xFF22C55E); // выполнено, прогресс книги 100%
  static const warning = Color(0xFFFF9500); // иконка огня (стрик), предупреждения

  static const textPrimary = Color(0xFFFFFFFF);
  static const textBody = Color(0xFFD0D0D0); // текст комментария
  static const textSecondary = Color(0xFFA0A0A0); // подписи, плейсхолдеры, неактивный таб
  static const textMuted = Color(0xFF808080); // мелкие подписи в карточках статистики
  static const textFaint = Color(0xFF606060); // «Reply», «group streak»
  static const textDisabled = Color(0xFF3A3A3A); // счётчики символов, неактивная кнопка
  static const textGhost = Color(0xFF3C3C3C); // плейсхолдер в полях логина

  // Заливки с прозрачностью
  static const primary10 = Color(0x1A0077FF); // активный пункт меню, бейдж «You»
  static const primary30 = Color(0x4D0077FF); // рамка карточки shared habit
  static const success15 = Color(0x2622C55E); // кнопка «Completed Today»
  static const danger10 = Color(0x1AFF3B30); // фон блока ошибки
  static const danger30 = Color(0x4DFF3B30); // рамка блока ошибки
  static const habitDoneBg = Color(0xFF0A1F0F); // карточка выполненной привычки
  static const habitDoneBorder = Color(0xFF1A3D22);
  static const bookIconBg = Color(0xFF1A2332); // иконка книги / непрочитанная нотификация
}
