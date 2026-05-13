import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';
import 'package:salon_booker_app/features/bookings/domain/repositories/bookings_repository.dart';

class GetBookingsUseCase {
  final BookingsRepository bookingsRepository;

  GetBookingsUseCase(this.bookingsRepository);

  ResultFuture<BookingsData> call() {
    return bookingsRepository.getBookings();
  }
}
