import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/salon_booking_repository.dart';

class GetSalonBookingDetailsUseCase {
  const GetSalonBookingDetailsUseCase(this._repository);

  final SalonBookingRepository _repository;

  ResultFuture<SalonBookingDetails> call(int salonId) {
    return _repository.getSalonDetails(salonId);
  }
}
