import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/verify_otp/verify_otp_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/verify_otp/verify_otp_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/verify_otp/verify_otp_state.dart';
import 'package:go_router/go_router.dart';

// Screen-specific palette
const _kSubtitleColor = Color(0xFF667084);
const _kErrorColor = Color(0xFFD64545);
const _kHintColor = Color(0xFF7E8797);
const _kInputTextColor = Color(0xFF2C3037);
const _kButtonEnabled = Color(0xFF2F3440);
const _kButtonDisabled = Color(0xFFB6BBC7);
const _kScreenBackground = Color(0xFFE8EEF2);
const _kBrandCoral = Color(0xFFF26D5B);

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyOtpBloc(
        verifyOtpUseCase: sl(),
        phone: phone,
      ),
      child: _OtpView(phone: phone),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView({required this.phone});

  final String phone;

  String _formatPhoneForDisplay(String phone) {
    if (phone.isEmpty) return '+91';
    if (phone.length <= 5) return '+91 $phone';
    if (phone.length <= 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return '+91 ${phone.substring(0, 5)} ${phone.substring(5, 10)}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhone = _formatPhoneForDisplay(phone);

    return BlocListener<VerifyOtpBloc, VerifyOtpState>(
      listenWhen: (previous, current) =>
          current.status == VerifyOtpStatus.success,
      listener: (context, state) {
        if (state.status == VerifyOtpStatus.success && state.user != null) {
          context.read<AuthBloc>().add(LoggedIn(state.user!));
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _kScreenBackground,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                style: IconButton.styleFrom(
                                  foregroundColor: _kInputTextColor,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Center(
                          child: _BrandWordmark(
                            fontSize: 32.sp,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 420.w),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 22.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(28.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF101828).withValues(alpha: 0.08),
                                    blurRadius: 32,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Verify your number',
                                    style: context.typography.pageTitle.copyWith(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                      height: 1.12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: Text(
                                      'Enter the 4-digit code sent to $formattedPhone and continue your booking journey.',
                                      style: context.typography.body.copyWith(
                                        color: _kSubtitleColor,
                                        fontSize: 16.sp,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 22.h),
                                  BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
                                    buildWhen: (previous, current) =>
                                        previous.otp != current.otp,
                                    builder: (context, state) {
                                      return _OtpInput(
                                        otp: state.otp,
                                        onChanged: (otp) => context
                                            .read<VerifyOtpBloc>()
                                            .add(VerifyOtpChanged(otp)),
                                      );
                                    },
                                  ),
                                  BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
                                    buildWhen: (previous, current) =>
                                        previous.errorMessage != current.errorMessage,
                                    builder: (context, state) {
                                      if (state.errorMessage == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: Text(
                                          state.errorMessage!,
                                          style: context.typography.body.copyWith(
                                            color: _kErrorColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  const _VerifyButton(),
                                  SizedBox(height: 16.h),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context
                                          .read<VerifyOtpBloc>()
                                          .add(const VerifyOtpResendTapped()),
                                      child: Text(
                                        "Didn't receive code? Resend OTP",
                                        style: context.typography.body.copyWith(
                                          color: AppColors.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
      letterSpacing: -1.0,
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

const _kOtpLength = 4;

class _OtpInput extends StatefulWidget {
  const _OtpInput({
    required this.otp,
    required this.onChanged,
  });

  final String otp;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _kOtpLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(_kOtpLength, (_) => FocusNode());
    _syncFromOtp(widget.otp);
  }

  @override
  void didUpdateWidget(_OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.otp != widget.otp) {
      _syncFromOtp(widget.otp);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncFromOtp(String otp) {
    final digits = otp.replaceAll(RegExp(r'\D'), '');
    final text = digits.length <= _kOtpLength ? digits : digits.substring(0, _kOtpLength);
    for (var i = 0; i < _kOtpLength; i++) {
      final digit = i < text.length ? text[i] : '';
      if (_controllers[i].text != digit) {
        _controllers[i].text = digit;
      }
    }
  }

  void _notifyChanged() {
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged(otp);
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < _kOtpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      _notifyChanged();
      if (digits.length >= _kOtpLength) {
        _focusNodes[_kOtpLength - 1].requestFocus();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    _notifyChanged();

    if (value.isNotEmpty) {
      if (index < _kOtpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_kOtpLength, (index) {
        return SizedBox(
          width: 64.w,
          child: _OtpDigitBox(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autofocus: index == 0,
            onChanged: (value) => _onDigitChanged(index, value),
          ),
        );
      }),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14.r);
    const double boxHeight = 72;
    final double verticalPadding = (boxHeight - 32) / 2;
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox.expand(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: verticalPadding.h),
              filled: true,
              fillColor: Colors.transparent,
              hintText: '•',
              hintStyle: context.typography.pageTitleSmall.copyWith(
                color: _kHintColor.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
                fontSize: 28.sp,
                height: 1.0,
              ),
            ),
            style: context.typography.pageTitleSmall.copyWith(
              color: _kInputTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 28.sp,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
      buildWhen: (previous, current) =>
          previous.otp != current.otp || previous.status != current.status,
      builder: (context, state) {
        final otp = state.otp.trim();
        final enabled =
            otp.length == 4 && state.status != VerifyOtpStatus.loading;
        final isLoading = state.status == VerifyOtpStatus.loading;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled && !isLoading
                ? () => context
                    .read<VerifyOtpBloc>()
                    .add(const VerifyOtpSubmitted())
                : null,
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: double.infinity,
              height: 62.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled ? _kButtonEnabled : _kButtonDisabled,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 26.w,
                      height: 26.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Verify & Continue',
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
