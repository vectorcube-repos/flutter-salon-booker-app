import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle pageTitle;
  final TextStyle pageTitleMedium;
  final TextStyle pageTitleSmall;
  final TextStyle display;
  final TextStyle screenTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle caption;
  final TextStyle button;

  const AppTypography({
    required this.pageTitle,
    required this.pageTitleMedium,
    required this.pageTitleSmall,
    required this.display,
    required this.screenTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.body,
    required this.bodySmall,
    required this.caption,
    required this.button,
  });

  static AppTypography scaled() {
    return AppTypography(
      pageTitle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      pageTitleMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      pageTitleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      display: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      screenTitle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      sectionTitle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      cardTitle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      body: TextStyle(fontSize: 16.sp, color: AppColors.lightText),
      bodySmall: TextStyle(
        fontSize: 14.sp,
        color: AppColors.lightTextSecondary,
      ),
      caption: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
      button: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? pageTitle,
    TextStyle? pageTitleMedium,
    TextStyle? pageTitleSmall,
    TextStyle? display,
    TextStyle? screenTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? caption,
    TextStyle? button,
  }) {
    return AppTypography(
      pageTitle: pageTitle ?? this.pageTitle,
      pageTitleMedium: pageTitleMedium ?? this.pageTitleMedium,
      pageTitleSmall: pageTitleSmall ?? this.pageTitleSmall,
      display: display ?? this.display,
      screenTitle: screenTitle ?? this.screenTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardTitle: cardTitle ?? this.cardTitle,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      caption: caption ?? this.caption,
      button: button ?? this.button,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      pageTitleMedium: TextStyle.lerp(pageTitleMedium, other.pageTitleMedium, t)!,
      pageTitleSmall: TextStyle.lerp(pageTitleSmall, other.pageTitleSmall, t)!,
      display: TextStyle.lerp(display, other.display, t)!,
      screenTitle: TextStyle.lerp(screenTitle, other.screenTitle, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
    );
  }
}
