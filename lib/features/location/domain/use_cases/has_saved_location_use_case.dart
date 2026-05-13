import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class HasSavedLocationUseCase {
  const HasSavedLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<bool> call() {
    return _repository.hasSavedLocation();
  }
}
