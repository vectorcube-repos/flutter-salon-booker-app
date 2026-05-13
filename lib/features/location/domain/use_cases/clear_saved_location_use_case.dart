import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class ClearSavedLocationUseCase {
  const ClearSavedLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call() {
    return _repository.clearLocation();
  }
}
