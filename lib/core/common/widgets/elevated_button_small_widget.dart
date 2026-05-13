  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';

  class ElevatedButtonSmallWidget extends StatelessWidget {
    final String buttonLabel;
    final VoidCallback onPressEvent;
    final bool isLoading;
    const ElevatedButtonSmallWidget({
      super.key,
      required this.buttonLabel,
      required this.onPressEvent,
      this.isLoading = false,
    });

    @override
    Widget build(BuildContext context) {    
      return SizedBox(
        height: 28.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressEvent,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0, 60.h),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.r),
            ),
            elevation: 0,
          ),
          child: Text(
            buttonLabel,
            style: context.typography.button.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
}