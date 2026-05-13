import 'package:equatable/equatable.dart';

class AppointmentBookingResult extends Equatable {
  const AppointmentBookingResult({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
