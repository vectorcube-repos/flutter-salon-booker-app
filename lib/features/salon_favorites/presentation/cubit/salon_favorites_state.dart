part of 'salon_favorites_cubit.dart';

class SalonFavoritesState extends Equatable {
  final Map<int, bool> favoriteStatuses;
  final Set<int> loadingSalonIds;
  final String? errorMessage;

  const SalonFavoritesState({
    this.favoriteStatuses = const {},
    this.loadingSalonIds = const {},
    this.errorMessage,
  });

  SalonFavoritesState copyWith({
    Map<int, bool>? favoriteStatuses,
    Set<int>? loadingSalonIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SalonFavoritesState(
      favoriteStatuses: favoriteStatuses ?? this.favoriteStatuses,
      loadingSalonIds: loadingSalonIds ?? this.loadingSalonIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [favoriteStatuses, loadingSalonIds, errorMessage];
}
