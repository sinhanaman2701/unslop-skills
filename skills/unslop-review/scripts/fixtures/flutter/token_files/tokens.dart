// Fixture: a token file legitimately holds raw colors. The rules must not flag it.
import 'package:flutter/cupertino.dart';

abstract final class AppColors {
  static const tint = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFC2410C),
    darkColor: Color(0xFFFF8A4C),
  );
  static const paper = Colors.white;
}
