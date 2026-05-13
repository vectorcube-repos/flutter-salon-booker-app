import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';

class LabeledInputFieldWidget extends StatelessWidget {
  const LabeledInputFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.keyboardType,
    required this.onChanged,
    this.maxLines = 1,
    this.errorMessage,
    this.obscureText = false,
  });

  final String label;
  final String value;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? errorMessage;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          style: textTheme.bodyLarge?.copyWith(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            errorText: errorMessage,
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.only(bottom: 10.h),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.4),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.4),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
