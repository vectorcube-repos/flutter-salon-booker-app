import 'package:equatable/equatable.dart';

enum RequestOtpStatus { initial, loading, success, failure }

class RequestOtpState extends Equatable {
  final String phone;
  final RequestOtpStatus status;
  final String? errorMessage;

  const RequestOtpState({
    this.phone = '',
    this.status = RequestOtpStatus.initial,
    this.errorMessage,
  });

  RequestOtpState copyWith({
    String? phone,
    RequestOtpStatus? status,
    Object? errorMessage = _unset,
  }) {
    return RequestOtpState(
      phone: phone ?? this.phone,
      status: status ?? this.status,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [phone, status, errorMessage];
}
