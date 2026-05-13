import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/verify_otp/verify_otp_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/verify_otp/verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final VerifyOtpUseCase verifyOtpUseCase;
  final String phone;

  VerifyOtpBloc({
    required this.verifyOtpUseCase,
    required this.phone,
  }) : super(const VerifyOtpState()) {
    on<VerifyOtpChanged>(_onOtpChanged);
    on<VerifyOtpSubmitted>(_onSubmitted);
    on<VerifyOtpResendTapped>(_onResendTapped);
  }

  void _onOtpChanged(VerifyOtpChanged event, Emitter<VerifyOtpState> emit) {
    emit(state.copyWith(
      otp: event.otp,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerifyOtpState> emit,
  ) async {
    final otpDigits = state.otp.replaceAll(RegExp(r'\D'), '').trim();
    if (otpDigits.length != 4) {
      emit(state.copyWith(
        errorMessage: 'Please enter a valid 4-digit OTP.',
      ));
      return;
    }
    if (phone.isEmpty) return;
    if (state.status == VerifyOtpStatus.loading) return;

    emit(state.copyWith(
      status: VerifyOtpStatus.loading,
      errorMessage: null,
    ));

    final result = await verifyOtpUseCase.call(
      VerifyOtpParams(phone: phone, otp: otpDigits),
    );

    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            status: VerifyOtpStatus.failure,
            errorMessage: failure.message ?? 'Invalid or expired OTP. Please try again.',
          ));
        }
      },
      (User user) {
        if (!isClosed) {
          emit(state.copyWith(
            status: VerifyOtpStatus.success,
            user: user,
          ));
        }
      },
    );
  }

  void _onResendTapped(VerifyOtpResendTapped event, Emitter<VerifyOtpState> emit) {
    emit(state.copyWith(errorMessage: null));
  }
}
