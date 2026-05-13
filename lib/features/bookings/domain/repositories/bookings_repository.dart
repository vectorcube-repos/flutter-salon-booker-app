import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';

abstract class BookingsRepository {
  ResultFuture<BookingsData> getBookings();
}
