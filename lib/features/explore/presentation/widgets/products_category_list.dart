import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category.dart';

class ProductsCategoryList extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<Category>? onCategorySelected;

  const ProductsCategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id.toString() == selectedCategoryId;

          return InkWell(
            onTap: () {
              onCategorySelected?.call(category);
            },
            borderRadius: BorderRadius.circular(10.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightText : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                category.name,
                style: context.typography.body.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.lightText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
