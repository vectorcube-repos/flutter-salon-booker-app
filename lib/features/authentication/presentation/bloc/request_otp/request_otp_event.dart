import 'package:equatable/equatable.dart';

sealed class RequestOtpEvent extends Equatable {
  const RequestOtpEvent();

  @override
  List<Object?> get props => [];
}

final class RequestOtpPhoneChanged extends RequestOtpEvent {
  final String phone;
  const RequestOtpPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

final class RequestOtpSubmitted extends RequestOtpEvent {
  const RequestOtpSubmitted();
}

final class RequestOtpReset extends RequestOtpEvent {
  const RequestOtpReset();
}
