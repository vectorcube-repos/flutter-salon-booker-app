import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';

class AppointmentBookingRequestModel extends AppointmentBookingRequest {
  const AppointmentBookingRequestModel({
    required super.salonId,
    required super.serviceId,
    required super.staffId,
    required super.slotStart,
  });

  Map<String, dynamic> toApiJson() {
    return {
      'salon_id': salonId,
      'service_id': serviceId,
      'staff_id': staffId,
      'slot_start': slotStart,
    };
  }
}
