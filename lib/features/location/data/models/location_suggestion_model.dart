import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';

class LocationSuggestionModel extends LocationSuggestion {
  const LocationSuggestionModel({
    required super.id,
    required super.placeId,
    required super.name,
    required super.address,
    required super.mainText,
    required super.secondaryText,
    super.latitude,
    super.longitude,
    super.types = const [],
  });

  factory LocationSuggestionModel.fromJson(Map<String, dynamic> json) {
    return LocationSuggestionModel(
      id: json['id']?.toString() ?? '',
      placeId: json['place_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      mainText: json['main_text']?.toString() ?? '',
      secondaryText: json['secondary_text']?.toString() ?? '',
      latitude: _parseNullableDouble(json['latitude']),
      longitude: _parseNullableDouble(json['longitude']),
      types: (json['types'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
