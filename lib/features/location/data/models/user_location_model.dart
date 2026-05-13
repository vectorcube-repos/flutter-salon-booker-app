import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';

class UserLocationModel extends UserLocation {
  const UserLocationModel({
    required super.source,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.placeId,
    super.isLocationSelected = true,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    final sourceValue = json['source']?.toString() ?? 'current';
    return UserLocationModel(
      source: sourceValue == 'search'
          ? UserLocationSource.search
          : UserLocationSource.current,
      placeId: json['place_id']?.toString(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      isLocationSelected: json['is_location_selected'] == true,
    );
  }

  factory UserLocationModel.fromEntity(UserLocation location) {
    return UserLocationModel(
      source: location.source,
      placeId: location.placeId,
      name: location.name,
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      isLocationSelected: location.isLocationSelected,
    );
  }

  factory UserLocationModel.fromLocationDetailsJson(
    Map<String, dynamic> json,
  ) {
    return _fromApiJson(
      json,
      source: UserLocationSource.search,
    );
  }

  factory UserLocationModel.fromReverseGeocodeJson(
    Map<String, dynamic> json,
  ) {
    return _fromApiJson(
      json,
      source: UserLocationSource.current,
    );
  }

  static UserLocationModel _fromApiJson(
    Map<String, dynamic> json, {
    required UserLocationSource source,
  }) {
    final latitude = _parseNullableDouble(json['latitude']);
    final longitude = _parseNullableDouble(json['longitude']);
    if (latitude == null || longitude == null) {
      throw const FormatException('Location details missing coordinates');
    }

    final rawName = json['name']?.toString().trim() ?? '';
    final secondaryText = json['secondary_text']?.toString().trim() ?? '';
    final address = json['address']?.toString().trim() ?? '';
    final normalizedName = _normalizeDisplayName(
      rawName: rawName,
      secondaryText: secondaryText,
      address: address,
    );

    return UserLocationModel(
      source: source,
      placeId: json['place_id']?.toString(),
      name: normalizedName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isLocationSelected: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'place_id': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_location_selected': isLocationSelected,
    };
  }

  static double _parseDouble(dynamic value) {
    return _parseNullableDouble(value) ?? 0;
  }

  static String _normalizeDisplayName({
    required String rawName,
    required String secondaryText,
    required String address,
  }) {
    if (_isFriendlyName(rawName)) {
      return rawName;
    }

    if (secondaryText.isNotEmpty) {
      return secondaryText;
    }

    if (address.isNotEmpty) {
      return address;
    }

    return rawName;
  }

  static bool _isFriendlyName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (RegExp(r'^[23456789CFGHJMPQRVWX]{4,}\+[23456789CFGHJMPQRVWX]{2,}$')
        .hasMatch(trimmed.toUpperCase())) {
      return false;
    }
    if (RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(trimmed.toUpperCase())) {
      return false;
    }
    return true;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
