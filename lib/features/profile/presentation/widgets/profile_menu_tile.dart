import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';

class ProfileMenuTile extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68.h,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.pageTitleMedium.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 26.sp,
              color: AppColors.lightText,
            ),
          ],
        ),
      ),
    );
  }
}
