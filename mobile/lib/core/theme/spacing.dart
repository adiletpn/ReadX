/// Layout constants shared by every screen (§4.3 of the spec). The web centres
/// its whole app in a `max-w-[390px]` column; the numbers below are that same
/// column expressed in logical pixels.
abstract class AppMetrics {
  /// Ширина контента. На iPad и широких iPhone колонка центрируется.
  static const contentWidth = 390.0;

  /// Горизонтальные поля контента.
  static const hPadding = 16.0;

  /// Высота шапки без учёта safe area сверху.
  static const headerHeight = 56.0;

  /// Высота нижней навигации без учёта safe area снизу.
  static const bottomNavHeight = 64.0;

  /// Нижний отступ прокручиваемого контента, чтобы он не уезжал под BottomNav.
  static const bottomContentPadding = 80.0;

  /// Отступ тоста от низа экрана — `bottom-24` в вебе.
  static const toastBottom = 96.0;

  /// Радиусы.
  static const radiusCard = 16.0; // rounded-2xl: карточки, модалки, кнопки логина
  static const radiusField = 12.0; // rounded-xl: инпуты и кнопки внутри карточек
}
