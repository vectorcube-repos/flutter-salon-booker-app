part of 'location_setup_cubit.dart';

enum LocationSetupStatus {
  initial,
  searching,
  searchSuccess,
  searchFailure,
  resolvingSelection,
  savingCurrentLocation,
  success,
  failure,
}

class LocationSetupState extends Equatable {
  const LocationSetupState({
    this.status = LocationSetupStatus.initial,
    this.query = '',
    this.suggestions = const [],
    this.message,
    this.permissionDeniedForever = false,
    this.permissionDenied = false,
    this.locationServicesDisabled = false,
    this.selectedLocation,
  });

  final LocationSetupStatus status;
  final String query;
  final List<LocationSuggestion> suggestions;
  final String? message;
  final bool permissionDeniedForever;
  final bool permissionDenied;
  final bool locationServicesDisabled;
  final UserLocation? selectedLocation;

  bool get isBusy =>
      status == LocationSetupStatus.searching ||
      status == LocationSetupStatus.resolvingSelection ||
      status == LocationSetupStatus.savingCurrentLocation;

  LocationSetupState copyWith({
    LocationSetupStatus? status,
    String? query,
    List<LocationSuggestion>? suggestions,
    String? message,
    bool clearMessage = false,
    bool? permissionDeniedForever,
    bool? permissionDenied,
    bool? locationServicesDisabled,
    UserLocation? selectedLocation,
    bool clearSelectedLocation = false,
  }) {
    return LocationSetupState(
      status: status ?? this.status,
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      message: clearMessage ? null : (message ?? this.message),
      permissionDeniedForever:
          permissionDeniedForever ?? this.permissionDeniedForever,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      locationServicesDisabled:
          locationServicesDisabled ?? this.locationServicesDisabled,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    suggestions,
    message,
    permissionDeniedForever,
    permissionDenied,
    locationServicesDisabled,
    selectedLocation,
  ];
}
