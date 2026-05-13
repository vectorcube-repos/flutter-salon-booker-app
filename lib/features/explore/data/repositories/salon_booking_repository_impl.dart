import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/datasources/salon_booking_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/data/models/appointment_booking_request_model.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_result.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/salon_booking_repository.dart';

class SalonBookingRepositoryImpl implements SalonBookingRepository {
  SalonBookingRepositoryImpl(this._remoteDataSource);

  final SalonBookingRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<SalonBookingDetails> getSalonDetails(int salonId) {
    return _remoteDataSource.getSalonDetails(salonId);
  }

  @override
  ResultFuture<AppointmentBookingResult> bookAppointment(
    AppointmentBookingRequest request,
  ) {
    return _remoteDataSource.bookAppointment(
      AppointmentBookingRequestModel(
        salonId: request.salonId,
        serviceId: request.serviceId,
        staffId: request.staffId,
        slotStart: request.slotStart,
      ),
    );
  }
}
