import 'package:equatable/equatable.dart';

sealed class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object?> get props => [];
}

final class VerifyOtpChanged extends VerifyOtpEvent {
  final String otp;
  const VerifyOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

final class VerifyOtpSubmitted extends VerifyOtpEvent {
  const VerifyOtpSubmitted();
}

final class VerifyOtpResendTapped extends VerifyOtpEvent {
  const VerifyOtpResendTapped();
}
