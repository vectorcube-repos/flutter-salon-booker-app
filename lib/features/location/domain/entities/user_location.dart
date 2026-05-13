import 'package:equatable/equatable.dart';

enum UserLocationSource { current, search }

class UserLocation extends Equatable {
  const UserLocation({
    required this.source,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.isLocationSelected = true,
  });

  final UserLocationSource source;
  final String? placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isLocationSelected;

  String get displayLabel {
    final trimmedAddress = address.trim();
    if (trimmedAddress.isNotEmpty) {
      return trimmedAddress;
    }
    return name.trim().isNotEmpty ? name.trim() : 'Current location';
  }

  @override
  List<Object?> get props => [
    source,
    placeId,
    name,
    address,
    latitude,
    longitude,
    isLocationSelected,
  ];
}
