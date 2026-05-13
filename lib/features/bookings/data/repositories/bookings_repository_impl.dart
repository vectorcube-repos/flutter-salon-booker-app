import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/bookings/data/datasources/bookings_remote_data_source.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';
import 'package:salon_booker_app/features/bookings/domain/repositories/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource bookingsRemoteDataSource;

  BookingsRepositoryImpl(this.bookingsRemoteDataSource);

  @override
  ResultFuture<BookingsData> getBookings() async {
    final result = await bookingsRemoteDataSource.getBookings();
    return result.map((data) => data);
  }
}
