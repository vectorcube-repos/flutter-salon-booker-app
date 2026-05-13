import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_state.dart';
import 'package:go_router/go_router.dart';

// Screen-specific palette
const _kSubtitleColor = Color(0xFF667084);
const _kHintColor = Color(0xFF7E8797);
const _kInputTextColor = Color(0xFF2C3037);
const _kButtonEnabled = Color(0xFF2F3440);
const _kButtonDisabled = Color(0xFFB6BBC7);
const _kScreenBackground = Color(0xFFE8EEF2);
const _kBrandCoral = Color(0xFFF26D5B);
const _kHeroOverlayDark = Color(0xB3151A23);
const _kCardOverlayLight = Color(0xEAF7F9FC);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RequestOtpBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestOtpBloc, RequestOtpState>(
      listenWhen: (previous, current) =>
          current.status == RequestOtpStatus.success,
      listener: (context, state) {
        if (state.status == RequestOtpStatus.success) {
          context.pushNamed('otp', extra: state.phone);
          context.read<RequestOtpBloc>().add(const RequestOtpReset());
        }
      },
      child: Scaffold(
        backgroundColor: _kScreenBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final topInset = MediaQuery.of(context).padding.top;
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroImage(height: 320.h + topInset),
                    Transform.translate(
                      offset: Offset(0, -32.h),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: topInset > 0 ? 4.h : 0),
                            _BrandWordmark(
                              fontSize: 40.sp,
                            ),
                            SizedBox(height: 18.h),
                            Text(
                              'Salon booking made easy',
                              style: context.typography.pageTitle.copyWith(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.08,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'Book appointments faster with your mobile number and step back into your favorite salon experience.',
                                style: context.typography.body.copyWith(
                                  color: _kSubtitleColor,
                                  fontSize: 15.sp,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 420.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28.r),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF101828).withValues(alpha: 0.08),
                                        blurRadius: 32,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/saloons/11.jpg',
                                          fit: BoxFit.cover,
                                          alignment: const Alignment(0, 0.2),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                _kCardOverlayLight,
                                                Colors.white.withValues(alpha: 0.96),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28.r),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Log in with your mobile number',
                                              style: context.typography.pageTitleSmall.copyWith(
                                                color: _kInputTextColor,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              'We\'ll send you a one-time verification code.',
                                              style: context.typography.body.copyWith(
                                                color: _kSubtitleColor,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 18.h),
                                            const _PhoneInput(),
                                            BlocBuilder<RequestOtpBloc, RequestOtpState>(
                                              buildWhen: (previous, current) =>
                                                  previous.errorMessage != current.errorMessage,
                                              builder: (context, state) {
                                                if (state.errorMessage == null) {
                                                  return const SizedBox.shrink();
                                                }
                                                return Padding(
                                                  padding: EdgeInsets.only(top: 10.h),
                                                  child: Text(
                                                    state.errorMessage!,
                                                    style: context.typography.body.copyWith(
                                                      color: Colors.red,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(height: 14.h),
                                            const _ContinueButton(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(34.r),
        bottomRight: Radius.circular(34.r),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/saloons/11.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.08),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kHeroOverlayDark,
                    Colors.transparent,
                    _kScreenBackground.withValues(alpha: 0.96),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.typography.pageTitle.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: -1.2,
      color: _kInputTextColor,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Salon', style: baseStyle),
          TextSpan(
            text: 'Booker',
            style: baseStyle.copyWith(color: _kBrandCoral),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PhoneInput extends StatefulWidget {
  const _PhoneInput();

  @override
  State<_PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<_PhoneInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<RequestOtpBloc>();
    _controller = TextEditingController(text: bloc.state.phone);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    context.read<RequestOtpBloc>().add(
          RequestOtpPhoneChanged(_controller.text),
        );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberStyle = context.typography.pageTitleSmall.copyWith(
      fontSize: 18.sp,
      height: 1.1,
      letterSpacing: 0.2,
      color: _kInputTextColor,
      fontWeight: FontWeight.w700,
    );

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '+91',
              style: numberStyle,
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 176.w,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                strutStyle: StrutStyle(
                  fontSize: 18.sp,
                  height: 1.1,
                  forceStrutHeight: true,
                ),
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  border: InputBorder.none,
                  counterText: '',
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                  hintText: 'Enter mobile number',
                  hintStyle: context.typography.body.copyWith(
                    color: _kHintColor,
                    fontSize: 16.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: numberStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestOtpBloc, RequestOtpState>(
      buildWhen: (previous, current) =>
          previous.phone != current.phone ||
          previous.status != current.status,
      builder: (context, state) {
        final phone = state.phone.trim();
        final enabled = phone.length >= 10 && state.status != RequestOtpStatus.loading;
        final isLoading = state.status == RequestOtpStatus.loading;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled && !isLoading
                ? () => context.read<RequestOtpBloc>().add(const RequestOtpSubmitted())
                : null,
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: double.infinity,
              height: 52.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled ? _kButtonEnabled : _kButtonDisabled,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: context.typography.pageTitleSmall.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
