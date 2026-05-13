part of 'profile_favorites_bloc.dart';

enum ProfileFavoritesStatus { initial, loading, success, failure }

class ProfileFavoritesState extends Equatable {
  final ProfileFavoritesStatus status;
  final List<FavoriteSalon> salons;
  final String? message;

  const ProfileFavoritesState({
    this.status = ProfileFavoritesStatus.initial,
    this.salons = const [],
    this.message,
  });

  ProfileFavoritesState copyWith({
    ProfileFavoritesStatus? status,
    List<FavoriteSalon>? salons,
    Object? message = _unset,
  }) {
    return ProfileFavoritesState(
      status: status ?? this.status,
      salons: salons ?? this.salons,
      message: message == _unset ? this.message : message as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [status, salons, message];
}
