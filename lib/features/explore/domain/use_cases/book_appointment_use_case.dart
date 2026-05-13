import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_result.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/salon_booking_repository.dart';

class BookAppointmentUseCase {
  const BookAppointmentUseCase(this._repository);

  final SalonBookingRepository _repository;

  ResultFuture<AppointmentBookingResult> call(
    AppointmentBookingRequest request,
  ) {
    return _repository.bookAppointment(request);
  }
}
