import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElevatedButtonIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressEvent;
  const ElevatedButtonIcon({
    super.key,
    required this.icon,
    required this.onPressEvent,
  });

  @override
  Widget build(BuildContext context) {    
    return ElevatedButton(
      onPressed: onPressEvent,
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }
}
