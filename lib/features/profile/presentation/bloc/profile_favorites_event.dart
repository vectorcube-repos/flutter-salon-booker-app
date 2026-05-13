part of 'profile_favorites_bloc.dart';

sealed class ProfileFavoritesEvent extends Equatable {
  const ProfileFavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileFavoritesRequested extends ProfileFavoritesEvent {
  final bool showLoading;

  const ProfileFavoritesRequested({this.showLoading = true});

  @override
  List<Object?> get props => [showLoading];
}

final class ProfileFavoriteRemoveRequested extends ProfileFavoritesEvent {
  final int salonId;

  const ProfileFavoriteRemoveRequested({required this.salonId});

  @override
  List<Object?> get props => [salonId];
}
