import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/color.dart';
import 'package:salon_booker_app/features/explore/domain/entities/material.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/products_bloc.dart';

class ProductFilterSheet extends StatelessWidget {
  const ProductFilterSheet({super.key});

  static const _sortOptions = [
    ('Price: Low to High', 'price_asc'),
    ('Price: High to Low', 'price_desc'),
    ('Newest', 'newest'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        final loadedState = state is ProductsLoaded ? state : null;
        final loadingState = state is ProductsLoading ? state : null;

        final rawCategories =
            loadedState?.categories ?? loadingState?.categories ?? const <Category>[];
        final categories = rawCategories.isEmpty
            ? const [Category(id: 0, name: 'All')]
            : [const Category(id: 0, name: 'All'), ...rawCategories];
        final colors = loadedState?.colors ?? loadingState?.colors ?? const <ProductColor>[];
        final rawMaterials =
            loadedState?.materials ?? loadingState?.materials ?? const <ProductMaterial>[];
        final materials = rawMaterials.isEmpty
            ? const [ProductMaterial(id: 0, name: 'All')]
            : [const ProductMaterial(id: 0, name: 'All'), ...rawMaterials];

        final selectedCategoryIdRaw =
            loadedState?.selectedCategoryId ?? loadingState?.selectedCategoryId ?? '';
        final selectedCategoryId =
            selectedCategoryIdRaw.isEmpty ? '0' : selectedCategoryIdRaw;

        final selectedMaterialIdRaw =
            loadedState?.selectedMaterialId ?? loadingState?.selectedMaterialId ?? '';
        final selectedMaterialId =
            selectedMaterialIdRaw.isEmpty ? '0' : selectedMaterialIdRaw;

        final selectedColorId =
            loadedState?.selectedColorId ?? loadingState?.selectedColorId ?? '';

        final selectedSortBy =
            loadedState?.selectedSortBy ?? loadingState?.selectedSortBy ?? 'newest';
            
        final minPrice = loadedState?.minPrice ?? loadingState?.minPrice ?? 0;
        final maxPrice = loadedState?.maxPrice ?? loadingState?.maxPrice ?? 400;

        final selectedSortLabel = _sortOptions
            .firstWhere((option) => option.$2 == selectedSortBy, orElse: () => _sortOptions.first)
            .$1;

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter',
                      style: context.typography.pageTitleMedium.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(text: 'Sort By'),
                      SizedBox(height: 8.h),
                      PopupMenuButton<String>(
                        onSelected: (value) => context.read<ProductsBloc>().add(
                          ProductFiltersUpdated(sortBy: value),
                        ),
                        itemBuilder: (context) => _sortOptions
                            .map(
                              (option) => PopupMenuItem<String>(
                                value: option.$2,
                                child: Text(option.$1),
                              ),
                            )
                            .toList(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: AppColors.border),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedSortLabel,
                                  style: context.typography.body.copyWith(
                                    fontSize: 15.sp,
                                    color: AppColors.lightText,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 22.sp),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _SectionLabel(text: 'Material'),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: materials.map((material) {
                          final materialId = material.id.toString();
                          final isSelected = selectedMaterialId == materialId;
                          return _FilterChip(
                            label: material.name,
                            isSelected: isSelected,
                            onTap: () => context.read<ProductsBloc>().add(
                              ProductFiltersUpdated(
                                materialId: material.id == 0 ? '' : materialId,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20.h),
                      _SectionLabel(text: 'Categories'),
                      SizedBox(height: 10.h),
                      if (categories.isEmpty)
                        Text(
                          'No categories available',
                          style: context.typography.body.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.lightText.withValues(alpha: 0.7),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: categories.map((category) {
                            final categoryId = category.id.toString();
                            final isSelected = selectedCategoryId == categoryId;
                            return _FilterChip(
                              label: category.name,
                              isSelected: isSelected,
                              onTap: () => context.read<ProductsBloc>().add(
                                ProductFiltersUpdated(
                                  categoryId: category.id == 0 ? '' : categoryId,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 20.h),
                      _SectionLabel(text: 'Colors'),
                      SizedBox(height: 10.h),
                      if (colors.isEmpty)
                        Text(
                          'No colors available',
                          style: context.typography.body.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.lightText.withValues(alpha: 0.7),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 14.w,
                          runSpacing: 10.h,
                          children: colors.map((productColor) {
                            final colorId = productColor.id.toString();
                            final isSelected = selectedColorId == colorId;
                            final parsedColor = _parseHexColor(productColor.colorCode);
                            return InkWell(
                              onTap: () {
                                final nextColorId = isSelected ? '' : colorId;
                                context.read<ProductsBloc>().add(
                                  ProductFiltersUpdated(colorId: nextColorId),
                                );
                              },
                              borderRadius: BorderRadius.circular(999.r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 30.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: parsedColor,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : AppColors.border,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 6.r,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 14.sp,
                                          color: _isDarkColor(parsedColor)
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 20.h),
                      _SectionLabel(text: 'Price'),
                      SizedBox(height: 8.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.h,
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: AppColors.border.withValues(alpha: 0.7),
                          thumbColor: Colors.black,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: RangeSlider(
                          values: RangeValues(minPrice, maxPrice),
                          min: 0,
                          max: 400,
                          divisions: 40,
                          onChanged: (value) => context.read<ProductsBloc>().add(
                            ProductFiltersUpdated(
                              minPrice: value.start,
                              maxPrice: value.end,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '\$${minPrice.round()}',
                                style: context.typography.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            Text(
                              '\$${maxPrice.round()}',
                              style: context.typography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ProductsBloc>().add(const ProductFiltersApplied());
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: context.typography.button.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _parseHexColor(String hexCode) {
  final sanitized = hexCode.replaceFirst('#', '').trim();
  if (sanitized.isEmpty) return Colors.transparent;
  try {
    if (sanitized.length == 6) {
      return Color(int.parse('FF$sanitized', radix: 16));
    }
    if (sanitized.length == 8) {
      return Color(int.parse(sanitized, radix: 16));
    }
  } on FormatException {
    return Colors.transparent;
  }
  return Colors.transparent;
}

bool _isDarkColor(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.pageTitleMedium.copyWith(
        color: AppColors.lightText,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.black : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            color: isSelected ? Colors.white : AppColors.lightText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
