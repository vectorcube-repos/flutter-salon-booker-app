import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';

class SearchInputFieldWidget extends StatefulWidget {
  const SearchInputFieldWidget({
    super.key,
    required this.query,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search',
    this.autofocus = true,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  @override
  State<SearchInputFieldWidget> createState() => _SearchInputFieldWidgetState();
}

class _SearchInputFieldWidgetState extends State<SearchInputFieldWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _focusNode = FocusNode();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchInputFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query == widget.query) return;
    if (_controller.text == widget.query) return;

    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF57606A),
            size: 24.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: context.typography.body.copyWith(
                  color: const Color(0xFF7B8492),
                ),
                border: InputBorder.none,
              ),
              style: context.typography.body.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.onClear != null)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear?.call();
                _focusNode.requestFocus();
              },
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F4F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: const Color(0xFF6B7280),
                  size: 16.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
