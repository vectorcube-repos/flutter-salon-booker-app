import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/models/appointment_booking_request_model.dart';
import 'package:salon_booker_app/features/explore/data/models/appointment_booking_result_model.dart';
import 'package:salon_booker_app/features/explore/data/models/salon_booking_details_model.dart';

abstract class SalonBookingRemoteDataSource {
  ResultFuture<SalonBookingDetailsModel> getSalonDetails(int salonId);
  ResultFuture<AppointmentBookingResultModel> bookAppointment(
    AppointmentBookingRequestModel request,
  );
}

class SalonBookingRemoteDataSourceImpl implements SalonBookingRemoteDataSource {
  SalonBookingRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  ResultFuture<SalonBookingDetailsModel> getSalonDetails(int salonId) {
    return _dioClient.get<SalonBookingDetailsModel>(
      '/salons/$salonId',
      parser: (data) {
        if (data is! Map) {
          throw FormatException(
            'Expected object response, got: ${data.runtimeType}',
          );
        }
        return SalonBookingDetailsModel.fromApiJson(
          Map<String, dynamic>.from(data),
        );
      },
    );
  }

  @override
  ResultFuture<AppointmentBookingResultModel> bookAppointment(
    AppointmentBookingRequestModel request,
  ) {
    return _dioClient.post<AppointmentBookingResultModel>(
      '/appointments',
      data: request.toApiJson(),
      parser: (data) {
        if (data is! Map) {
          throw FormatException(
            'Expected object response, got: ${data.runtimeType}',
          );
        }
        return AppointmentBookingResultModel.fromApiJson(
          Map<String, dynamic>.from(data),
        );
      },
    );
  }
}
