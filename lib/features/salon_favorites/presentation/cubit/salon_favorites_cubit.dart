import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/add_salon_to_favorites_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/remove_salon_from_favorites_use_case.dart';

part 'salon_favorites_state.dart';

class SalonFavoritesCubit extends Cubit<SalonFavoritesState> {
  final AddSalonToFavoritesUseCase addSalonToFavoritesUseCase;
  final RemoveSalonFromFavoritesUseCase removeSalonFromFavoritesUseCase;

  SalonFavoritesCubit(
    this.addSalonToFavoritesUseCase,
    this.removeSalonFromFavoritesUseCase,
  ) : super(const SalonFavoritesState());

  void syncFavoriteStatuses(Map<int, bool> favoriteStatuses) {
    if (favoriteStatuses.isEmpty) return;

    final mergedStatuses = Map<int, bool>.from(state.favoriteStatuses)
      ..addAll(favoriteStatuses);

    emit(state.copyWith(favoriteStatuses: mergedStatuses, clearError: true));
  }

  Future<void> toggleFavorite({
    required int salonId,
    required bool isFavorite,
  }) async {
    if (state.loadingSalonIds.contains(salonId)) return;

    final nextFavorite = !isFavorite;
    final updatedStatuses = Map<int, bool>.from(state.favoriteStatuses)
      ..[salonId] = nextFavorite;
    final updatedLoadingIds = Set<int>.from(state.loadingSalonIds)
      ..add(salonId);

    emit(
      state.copyWith(
        favoriteStatuses: updatedStatuses,
        loadingSalonIds: updatedLoadingIds,
        clearError: true,
      ),
    );

    final result = nextFavorite
        ? await addSalonToFavoritesUseCase(salonId)
        : await removeSalonFromFavoritesUseCase(salonId);

    result.fold(
      (failure) {
        final revertedStatuses = Map<int, bool>.from(state.favoriteStatuses)
          ..[salonId] = isFavorite;
        final revertedLoadingIds = Set<int>.from(state.loadingSalonIds)
          ..remove(salonId);

        emit(
          state.copyWith(
            favoriteStatuses: revertedStatuses,
            loadingSalonIds: revertedLoadingIds,
            errorMessage: failure.message ?? 'Failed to update salon favorite',
          ),
        );
      },
      (_) {
        final settledLoadingIds = Set<int>.from(state.loadingSalonIds)
          ..remove(salonId);

        emit(
          state.copyWith(loadingSalonIds: settledLoadingIds, clearError: true),
        );
      },
    );
  }
}
