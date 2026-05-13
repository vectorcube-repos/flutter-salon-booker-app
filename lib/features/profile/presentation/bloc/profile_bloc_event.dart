part of 'profile_bloc.dart';

sealed class ProfileBlocEvent extends Equatable {
  const ProfileBlocEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileBlocEvent {
  const ProfileLoadRequested();
}

final class ProfileUpdated extends ProfileBlocEvent {
  final Profile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}
