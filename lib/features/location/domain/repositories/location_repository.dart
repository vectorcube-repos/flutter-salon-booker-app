import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';

abstract class LocationRepository {
  Future<UserLocation?> getSavedLocation();

  Future<void> saveLocation(UserLocation location);

  Future<void> clearLocation();

  Future<bool> hasSavedLocation();

  ResultFuture<List<LocationSuggestion>> searchLocations(String query);

  ResultFuture<UserLocation> getLocationDetails(String placeId);

  ResultFuture<UserLocation> reverseGeocodeLocation({
    required double latitude,
    required double longitude,
  });
}
