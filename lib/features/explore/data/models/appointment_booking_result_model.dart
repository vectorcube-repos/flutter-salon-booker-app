import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_result.dart';

class AppointmentBookingResultModel extends AppointmentBookingResult {
  const AppointmentBookingResultModel({required super.message});

  factory AppointmentBookingResultModel.fromApiJson(Map<String, dynamic> json) {
    return AppointmentBookingResultModel(
      message: json['message']?.toString() ?? 'Appointment booked successfully',
    );
  }
}
