import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';
import 'package:salon_booker_app/features/location/domain/entities/user_location.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_location_details_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/reverse_geocode_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/save_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/search_locations_use_case.dart';

part 'location_setup_state.dart';

class LocationSetupCubit extends Cubit<LocationSetupState> {
  LocationSetupCubit({
    required SearchLocationsUseCase searchLocationsUseCase,
    required GetLocationDetailsUseCase getLocationDetailsUseCase,
    required ReverseGeocodeLocationUseCase reverseGeocodeLocationUseCase,
    required SaveLocationUseCase saveLocationUseCase,
    required LocationSessionNotifier locationSessionNotifier,
  }) : _searchLocationsUseCase = searchLocationsUseCase,
       _getLocationDetailsUseCase = getLocationDetailsUseCase,
       _reverseGeocodeLocationUseCase = reverseGeocodeLocationUseCase,
       _saveLocationUseCase = saveLocationUseCase,
       _locationSessionNotifier = locationSessionNotifier,
       super(const LocationSetupState());

  final SearchLocationsUseCase _searchLocationsUseCase;
  final GetLocationDetailsUseCase _getLocationDetailsUseCase;
  final ReverseGeocodeLocationUseCase _reverseGeocodeLocationUseCase;
  final SaveLocationUseCase _saveLocationUseCase;
  final LocationSessionNotifier _locationSessionNotifier;

  int _searchRequestId = 0;

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < 3) {
      emit(
        state.copyWith(
          status: LocationSetupStatus.initial,
          query: query,
          suggestions: const [],
          clearMessage: true,
          clearSelectedLocation: true,
          permissionDenied: false,
          permissionDeniedForever: false,
          locationServicesDisabled: false,
        ),
      );
      return;
    }

    final requestId = ++_searchRequestId;
    emit(
      state.copyWith(
        status: LocationSetupStatus.searching,
        query: query,
        clearMessage: true,
        clearSelectedLocation: true,
        permissionDenied: false,
        permissionDeniedForever: false,
        locationServicesDisabled: false,
      ),
    );

    final result = await _searchLocationsUseCase(query);
    if (requestId != _searchRequestId || isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LocationSetupStatus.searchFailure,
          suggestions: const [],
          message: failure.message ?? 'Failed to search locations',
        ),
      ),
      (suggestions) => emit(
        state.copyWith(
          status: LocationSetupStatus.searchSuccess,
          suggestions: suggestions,
          message: suggestions.isEmpty ? 'No locations found' : null,
        ),
      ),
    );
  }

  Future<void> selectSuggestion(LocationSuggestion suggestion) async {
    emit(
      state.copyWith(
        status: LocationSetupStatus.resolvingSelection,
        clearMessage: true,
        permissionDenied: false,
        permissionDeniedForever: false,
        locationServicesDisabled: false,
      ),
    );

    final result = await _getLocationDetailsUseCase(suggestion.placeId);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: LocationSetupStatus.failure,
            message: failure.message ?? 'Failed to load selected location',
          ),
        );
      },
      (location) async {
        await _persistLocation(location);
      },
    );
  }

  Future<void> useCurrentLocation() async {
    emit(
      state.copyWith(
        status: LocationSetupStatus.savingCurrentLocation,
        clearMessage: true,
        permissionDenied: false,
        permissionDeniedForever: false,
        locationServicesDisabled: false,
      ),
    );

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      emit(
        state.copyWith(
          status: LocationSetupStatus.failure,
          locationServicesDisabled: true,
          message: 'Turn on device location services to continue.',
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      emit(
        state.copyWith(
          status: LocationSetupStatus.failure,
          permissionDenied: true,
          message: 'Location permission was denied. You can still search manually.',
        ),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          status: LocationSetupStatus.failure,
          permissionDeniedForever: true,
          message:
              'Location permission is permanently denied. Open settings or search manually.',
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final result = await _reverseGeocodeLocationUseCase(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await result.fold(
        (failure) async {
          emit(
            state.copyWith(
              status: LocationSetupStatus.failure,
              message:
                  failure.message ??
                  'Unable to name your current location right now.',
            ),
          );
        },
        (location) async {
          await _persistLocation(location);
        },
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LocationSetupStatus.failure,
          message: 'Unable to get your current location right now.',
        ),
      );
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _persistLocation(UserLocation location) async {
    await _saveLocationUseCase(location);
    await _locationSessionNotifier.setLocation(location);
    emit(
      state.copyWith(
        status: LocationSetupStatus.success,
        selectedLocation: location,
        suggestions: const [],
        message: null,
      ),
    );
  }
}
