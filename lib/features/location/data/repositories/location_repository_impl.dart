import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/data/datasources/location_local_data_source.dart';
import 'package:salon_booker_app/features/location/data/datasources/location_remote_data_source.dart';
import 'package:salon_booker_app/features/location/data/models/user_location_model.dart';
import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._remote, this._local);

  final LocationRemoteDataSource _remote;
  final LocationLocalDataSource _local;

  @override
  Future<UserLocation?> getSavedLocation() {
    return _local.getSavedLocation();
  }

  @override
  Future<void> saveLocation(UserLocation location) {
    return _local.saveLocation(UserLocationModel.fromEntity(location));
  }

  @override
  Future<void> clearLocation() {
    return _local.clearLocation();
  }

  @override
  Future<bool> hasSavedLocation() {
    return _local.hasSavedLocation();
  }

  @override
  ResultFuture<List<LocationSuggestion>> searchLocations(String query) async {
    final result = await _remote.searchLocations(query);
    return result.map((items) => items.cast<LocationSuggestion>());
  }

  @override
  ResultFuture<UserLocation> getLocationDetails(String placeId) async {
    final result = await _remote.getLocationDetails(placeId);
    return result.map((item) => item as UserLocation);
  }

  @override
  ResultFuture<UserLocation> reverseGeocodeLocation({
    required double latitude,
    required double longitude,
  }) async {
    final result = await _remote.reverseGeocodeLocation(
      latitude: latitude,
      longitude: longitude,
    );
    return result.map((item) => item as UserLocation);
  }
}
