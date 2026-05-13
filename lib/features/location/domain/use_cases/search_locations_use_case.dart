import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class SearchLocationsUseCase {
  const SearchLocationsUseCase(this._repository);

  final LocationRepository _repository;

  ResultFuture<List<LocationSuggestion>> call(String query) {
    return _repository.searchLocations(query);
  }
}
