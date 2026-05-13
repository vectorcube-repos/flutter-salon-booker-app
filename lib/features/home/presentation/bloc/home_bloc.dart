import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_dashboard_data.dart';
import 'package:salon_booker_app/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_saved_location_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDashboardUseCase getHomeDashboardUseCase;
  final GetSavedLocationUseCase getSavedLocationUseCase;

  HomeBloc(this.getHomeDashboardUseCase, this.getSavedLocationUseCase)
    : super(HomeInitial()) {
    on<GetHomeDashboardEvent>(_onGetHomeDashboard);
  }

  Future<void> _onGetHomeDashboard(
    GetHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final location = await getSavedLocationUseCase();
    if (location == null) {
      emit(
        const HomeLoadingFailure(
          message: 'Please select a location to continue.',
        ),
      );
      return;
    }

    final result = await getHomeDashboardUseCase(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    result.fold(
      (failure) => emit(
        HomeLoadingFailure(
          message: failure.message ?? 'Failed to load home data',
        ),
      ),
      (data) => emit(HomeLoaded(data: data)),
    );
  }
}
