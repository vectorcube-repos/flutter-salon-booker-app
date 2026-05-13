import 'package:equatable/equatable.dart';

class LocationSuggestion extends Equatable {
  const LocationSuggestion({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    required this.mainText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
    this.types = const [],
  });

  final String id;
  final String placeId;
  final String name;
  final String address;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;
  final List<String> types;

  @override
  List<Object?> get props => [
    id,
    placeId,
    name,
    address,
    mainText,
    secondaryText,
    latitude,
    longitude,
    types,
  ];
}
