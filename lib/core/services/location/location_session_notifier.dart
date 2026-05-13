import 'package:flutter/foundation.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';

class LocationSessionNotifier extends ChangeNotifier {
  UserLocation? _location;

  UserLocation? get location => _location;

  bool get hasSelectedLocation => _location?.isLocationSelected == true;

  Future<void> setLocation(UserLocation location) async {
    _location = location;
    notifyListeners();
  }

  Future<void> clear() async {
    _location = null;
    notifyListeners();
  }
}
