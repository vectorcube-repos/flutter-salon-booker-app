import 'package:equatable/equatable.dart';

class AppointmentBookingRequest extends Equatable {
  const AppointmentBookingRequest({
    required this.salonId,
    required this.serviceId,
    required this.staffId,
    required this.slotStart,
  });

  final int salonId;
  final int serviceId;
  final int staffId;
  final String slotStart;

  @override
  List<Object?> get props => [salonId, serviceId, staffId, slotStart];
}
