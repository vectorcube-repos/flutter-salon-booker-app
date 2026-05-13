import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';

class ProductsTopBar extends StatelessWidget {
  final VoidCallback? onFilterTap;

  const ProductsTopBar({
    super.key,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Products',
              style: context.typography.pageTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onFilterTap,
              splashRadius: 20.r,
              icon: Icon(
                Icons.tune_rounded,
                size: 24.sp,
                color: AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
