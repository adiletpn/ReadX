abstract class AppMetrics {
  static const contentWidth = 420.0;
  static const hPadding = 18.0;

  static const headerHeight = 56.0;
  static const bottomNavHeight = 68.0;
  static const bottomContentPadding = 88.0;
  static const toastBottom = 100.0;

  static const radiusHero = 26.0;
  static const radiusCard = 20.0;
  static const radiusField = 14.0;
  static const radiusChip = 999.0;
}

abstract class AppDuration {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);
}
