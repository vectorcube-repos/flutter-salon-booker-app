part of 'salon_booking_bloc.dart';

sealed class SalonBookingEvent extends Equatable {
  const SalonBookingEvent();

  @override
  List<Object?> get props => const [];
}

final class SalonBookingDetailsRequested extends SalonBookingEvent {
  const SalonBookingDetailsRequested(this.salonId);

  final int salonId;

  @override
  List<Object?> get props => [salonId];
}

final class SalonAppointmentRequested extends SalonBookingEvent {
  const SalonAppointmentRequested(this.request);

  final AppointmentBookingRequest request;

  @override
  List<Object?> get props => [request];
}
