import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:salon_booker_app/features/location/data/models/user_location_model.dart';

abstract class LocationLocalDataSource {
  Future<UserLocationModel?> getSavedLocation();

  Future<void> saveLocation(UserLocationModel location);

  Future<void> clearLocation();

  Future<bool> hasSavedLocation();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  const LocationLocalDataSourceImpl(this._preferences);

  static const _kUserLocationKey = 'user_location';

  final SharedPreferences _preferences;

  @override
  Future<UserLocationModel?> getSavedLocation() async {
    final raw = _preferences.getString(_kUserLocationKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final location = UserLocationModel.fromJson(decoded);
      if (!location.isLocationSelected) return null;
      return location;
    } catch (_) {
      await clearLocation();
      return null;
    }
  }

  @override
  Future<void> saveLocation(UserLocationModel location) async {
    await _preferences.setString(
      _kUserLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  @override
  Future<void> clearLocation() async {
    await _preferences.remove(_kUserLocationKey);
  }

  @override
  Future<bool> hasSavedLocation() async {
    return (await getSavedLocation()) != null;
  }
}
