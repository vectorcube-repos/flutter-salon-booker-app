import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/bookings/data/models/bookings_data_model.dart';

abstract class BookingsRemoteDataSource {
  ResultFuture<BookingsDataModel> getBookings();
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final DioClient _dioClient;

  BookingsRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<BookingsDataModel> getBookings() {
    return _dioClient.get<BookingsDataModel>(
      '/bookings',
      parser: _parseBookingsDataResponse,
    );
  }

  BookingsDataModel _parseBookingsDataResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return const BookingsDataModel();
    return BookingsDataModel.fromApiJson(data);
  }
}
