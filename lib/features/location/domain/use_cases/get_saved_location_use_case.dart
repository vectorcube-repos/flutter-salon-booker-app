import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class GetSavedLocationUseCase {
  const GetSavedLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<UserLocation?> call() {
    return _repository.getSavedLocation();
  }
}
