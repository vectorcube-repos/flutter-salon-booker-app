import 'package:flutter/material.dart';
import 'app_typography.dart';

extension ThemeX on BuildContext {
  AppTypography get typography {
    return Theme.of(this).extension<AppTypography>() ?? AppTypography.scaled();
  }
}
