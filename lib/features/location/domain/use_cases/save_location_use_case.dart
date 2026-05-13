import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class SaveLocationUseCase {
  const SaveLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call(UserLocation location) {
    return _repository.saveLocation(location);
  }
}
