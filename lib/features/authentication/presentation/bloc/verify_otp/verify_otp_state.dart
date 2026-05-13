import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

enum VerifyOtpStatus { initial, loading, success, failure }

class VerifyOtpState extends Equatable {
  final String otp;
  final VerifyOtpStatus status;
  final String? errorMessage;
  final User? user;

  const VerifyOtpState({
    this.otp = '',
    this.status = VerifyOtpStatus.initial,
    this.errorMessage,
    this.user,
  });

  VerifyOtpState copyWith({
    String? otp,
    VerifyOtpStatus? status,
    Object? errorMessage = _unset,
    User? user,
  }) {
    return VerifyOtpState(
      otp: otp ?? this.otp,
      status: status ?? this.status,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      user: user ?? this.user,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [otp, status, errorMessage, user];
}
