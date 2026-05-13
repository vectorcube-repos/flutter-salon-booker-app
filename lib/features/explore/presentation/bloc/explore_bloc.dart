import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_dashboard_data.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_explore_dashboard_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_saved_location_use_case.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetExploreDashboardUseCase getExploreDashboardUseCase;
  final GetSavedLocationUseCase getSavedLocationUseCase;

  ExploreBloc(this.getExploreDashboardUseCase, this.getSavedLocationUseCase)
    : super(const ExploreState()) {
    on<ExploreRequested>(_onExploreRequested);
    on<ExploreServiceSelected>(_onExploreServiceSelected);
    on<ExploreNextPageRequested>(_onExploreNextPageRequested);
  }

  Future<void> _onExploreRequested(
    ExploreRequested event,
    Emitter<ExploreState> emit,
  ) async {
    final isLoadMore = event.page > 1;
    if (isLoadMore) {
      if (state.isLoadingMore || !state.data.pagination.hasMore) return;
      emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    } else {
      emit(
        state.copyWith(
          status: ExploreStatus.loading,
          selectedServiceId: event.serviceId ?? state.selectedServiceId,
          isLoadingMore: false,
          clearMessage: true,
        ),
      );
    }

    final location = await getSavedLocationUseCase();
    if (location == null) {
      emit(
        state.copyWith(
          status: ExploreStatus.failure,
          isLoadingMore: false,
          message: 'Please select a location to continue.',
        ),
      );
      return;
    }

    final result = await getExploreDashboardUseCase(
      categoryId: event.serviceId ?? state.selectedServiceId,
      latitude: location.latitude,
      longitude: location.longitude,
      page: event.page,
      isInitialLoad: event.isInitialLoad,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ExploreStatus.failure,
          isLoadingMore: false,
          message: failure.message ?? 'Failed to load explore data',
        ),
      ),
      (data) {
        final nextData = isLoadMore
            ? ExploreDashboardData(
                salons: [...state.data.salons, ...data.salons],
                services: state.data.services.isNotEmpty
                    ? state.data.services
                    : data.services,
                pagination: data.pagination,
              )
            : ExploreDashboardData(
                salons: data.salons,
                services: data.services.isNotEmpty
                    ? data.services
                    : state.data.services,
                pagination: data.pagination,
              );

        emit(
          state.copyWith(
            status: ExploreStatus.success,
            data: nextData,
            selectedServiceId: event.serviceId ?? state.selectedServiceId,
            isLoadingMore: false,
            clearMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onExploreServiceSelected(
    ExploreServiceSelected event,
    Emitter<ExploreState> emit,
  ) async {
    add(ExploreRequested(serviceId: event.serviceId));
  }

  Future<void> _onExploreNextPageRequested(
    ExploreNextPageRequested event,
    Emitter<ExploreState> emit,
  ) async {
    if (state.status != ExploreStatus.success ||
        state.isLoadingMore ||
        !state.data.pagination.hasMore) {
      return;
    }

    add(
      ExploreRequested(
        serviceId: state.selectedServiceId,
        page: state.data.pagination.currentPage + 1,
      ),
    );
  }
}
