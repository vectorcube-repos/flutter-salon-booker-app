import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/get_favorite_salons_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/remove_salon_from_favorites_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/presentation/cubit/salon_favorites_cubit.dart';

part 'profile_favorites_event.dart';
part 'profile_favorites_state.dart';

class ProfileFavoritesBloc
    extends Bloc<ProfileFavoritesEvent, ProfileFavoritesState> {
  final GetFavoriteSalonsUseCase getFavoriteSalonsUseCase;
  final RemoveSalonFromFavoritesUseCase removeSalonFromFavoritesUseCase;
  final SalonFavoritesCubit salonFavoritesCubit;

  ProfileFavoritesBloc(
    this.getFavoriteSalonsUseCase,
    this.removeSalonFromFavoritesUseCase,
    this.salonFavoritesCubit,
  ) : super(const ProfileFavoritesState()) {
    on<ProfileFavoritesRequested>(_onProfileFavoritesRequested);
    on<ProfileFavoriteRemoveRequested>(_onProfileFavoriteRemoveRequested);
  }

  Future<void> _onProfileFavoritesRequested(
    ProfileFavoritesRequested event,
    Emitter<ProfileFavoritesState> emit,
  ) async {
    if (event.showLoading) {
      emit(
        state.copyWith(status: ProfileFavoritesStatus.loading, message: null),
      );
    }

    final result = await getFavoriteSalonsUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileFavoritesStatus.failure,
          message: failure.message ?? 'Failed to load favorites',
        ),
      ),
      (salons) {
        salonFavoritesCubit.syncFavoriteStatuses({
          for (final salon in salons) salon.id: true,
        });
        emit(
          state.copyWith(
            status: ProfileFavoritesStatus.success,
            salons: salons,
            message: null,
          ),
        );
      },
    );
  }

  Future<void> _onProfileFavoriteRemoveRequested(
    ProfileFavoriteRemoveRequested event,
    Emitter<ProfileFavoritesState> emit,
  ) async {
    if (state.status != ProfileFavoritesStatus.success) return;

    final salons = state.salons;
    final index = salons.indexWhere((s) => s.id == event.salonId);
    if (index < 0) return;

    final updatedSalons = [
      ...salons.sublist(0, index),
      ...salons.sublist(index + 1),
    ];
    emit(state.copyWith(salons: updatedSalons, message: null));

    final result = await removeSalonFromFavoritesUseCase(event.salonId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          salons: salons,
          message: failure.message ?? 'Failed to remove favorite',
        ),
      ),
      (_) {
        salonFavoritesCubit.syncFavoriteStatuses({event.salonId: false});
      },
    );
  }
}
