import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/common/widgets/elevated_button_widget.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class AppointmentConfirmedScreen extends StatelessWidget {
  const AppointmentConfirmedScreen({
    super.key,
    this.salonName,
    this.serviceName,
    this.staffName,
    this.slotLabel,
  });

  final String? salonName;
  final String? serviceName;
  final String? staffName;
  final String? slotLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _CompletedMark(),
              SizedBox(height: 20.h),
              Text(
                'Appointment Confirmed',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 310.w),
                child: Text(
                  _buildSummary(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButtonWidget(
                  buttonLabel: 'Explore More Salons',
                  onPressEvent: () {
                    context.goNamed('products');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSummary() {
    final service = serviceName?.trim();
    final staff = staffName?.trim();
    final salon = salonName?.trim();
    final slot = slotLabel?.trim();

    final lineOneParts = [
      if (service != null && service.isNotEmpty) service,
      if (staff != null && staff.isNotEmpty) 'with $staff',
    ];
    final lineTwoParts = [
      if (salon != null && salon.isNotEmpty) salon,
      if (slot != null && slot.isNotEmpty) slot,
    ];

    final lines = [
      if (lineOneParts.isNotEmpty) lineOneParts.join(' '),
      if (lineTwoParts.isNotEmpty) lineTwoParts.join('  |  '),
    ];

    if (lines.isEmpty) {
      return 'Your appointment has been booked successfully.';
    }

    return 'Your appointment has been booked successfully.\n${lines.join('\n')}';
  }
}

class _CompletedMark extends StatelessWidget {
  const _CompletedMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132.w,
      height: 132.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _OpenCirclePainter(
                strokeColor: Colors.black,
                strokeWidth: 6.w,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.check_rounded,
              size: 62.w,
              color: Colors.black,
              weight: 900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenCirclePainter extends CustomPainter {
  const _OpenCirclePainter({
    required this.strokeColor,
    required this.strokeWidth,
  });

  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = 0.2;
    const sweepAngle = 5.7;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OpenCirclePainter oldDelegate) {
    return strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
