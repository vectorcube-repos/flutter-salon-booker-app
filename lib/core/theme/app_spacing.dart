import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  // Base spacing tokens from the design system.
  static const double _xs = 4;
  static const double _sm = 8;
  static const double _md = 16;
  static const double _lg = 24;
  static const double _xl = 32;
  static const double _xxl = 48;

  static double get xs => _xs.r;
  static double get sm => _sm.r;
  static double get md => _md.r;
  static double get lg => _lg.r;
  static double get xl => _xl.r;
  static double get xxl => _xxl.r;

  static EdgeInsets get screenPadding => EdgeInsets.all(md);

  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value.w);

  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value.h);
}
