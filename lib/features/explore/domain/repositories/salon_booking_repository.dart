import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_result.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';

abstract class SalonBookingRepository {
  ResultFuture<SalonBookingDetails> getSalonDetails(int salonId);
  ResultFuture<AppointmentBookingResult> bookAppointment(
    AppointmentBookingRequest request,
  );
}
