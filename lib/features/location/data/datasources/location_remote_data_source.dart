import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/location/data/models/location_suggestion_model.dart';
import 'package:salon_booker_app/features/location/data/models/user_location_model.dart';

abstract class LocationRemoteDataSource {
  ResultFuture<List<LocationSuggestionModel>> searchLocations(String query);

  ResultFuture<UserLocationModel> getLocationDetails(String placeId);

  ResultFuture<UserLocationModel> reverseGeocodeLocation({
    required double latitude,
    required double longitude,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  const LocationRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  ResultFuture<List<LocationSuggestionModel>> searchLocations(String query) {
    return _dioClient.get<List<LocationSuggestionModel>>(
      '/locations/search',
      queryParameters: {'q': query},
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw const FormatException('Invalid location search response');
        }

        final items = data['data'] as List<dynamic>? ?? const [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(LocationSuggestionModel.fromJson)
            .where((item) => item.placeId.trim().isNotEmpty)
            .toList();
      },
    );
  }

  @override
  ResultFuture<UserLocationModel> getLocationDetails(String placeId) {
    return _dioClient.get<UserLocationModel>(
      '/locations/$placeId',
      parser: (data) {
        if (data is! Map<String, dynamic> || data['data'] is! Map<String, dynamic>) {
          throw const FormatException('Invalid location details response');
        }

        return UserLocationModel.fromLocationDetailsJson(
          data['data'] as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  ResultFuture<UserLocationModel> reverseGeocodeLocation({
    required double latitude,
    required double longitude,
  }) {
    return _dioClient.get<UserLocationModel>(
      '/locations/reverse',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
      parser: (data) {
        if (data is! Map<String, dynamic> || data['data'] is! Map<String, dynamic>) {
          throw const FormatException('Invalid reverse geocode response');
        }

        return UserLocationModel.fromReverseGeocodeJson(
          data['data'] as Map<String, dynamic>,
        );
      },
    );
  }
}
