import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class ReverseGeocodeLocationUseCase {
  const ReverseGeocodeLocationUseCase(this._repository);

  final LocationRepository _repository;

  ResultFuture<UserLocation> call({
    required double latitude,
    required double longitude,
  }) {
    return _repository.reverseGeocodeLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
