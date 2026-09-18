import 'package:flutter/services.dart';

abstract class Haptics {
  static void tap() => HapticFeedback.selectionClick();

  static void light() => HapticFeedback.lightImpact();

  static void success() => HapticFeedback.mediumImpact();

  static void warn() => HapticFeedback.heavyImpact();
}
