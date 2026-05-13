import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class GetLocationDetailsUseCase {
  const GetLocationDetailsUseCase(this._repository);

  final LocationRepository _repository;

  ResultFuture<UserLocation> call(String placeId) {
    return _repository.getLocationDetails(placeId);
  }
}
