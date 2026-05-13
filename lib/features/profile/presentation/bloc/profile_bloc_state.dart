part of 'profile_bloc.dart';

enum ProfileBlocStatus { initial, loading, loaded, failure }

class ProfileBlocState extends Equatable {
  final ProfileBlocStatus status;
  final Profile? profile;
  final String? errorMessage;

  const ProfileBlocState({
    this.status = ProfileBlocStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileBlocState copyWith({
    ProfileBlocStatus? status,
    Profile? profile,
    Object? errorMessage = _unset,
  }) {
    return ProfileBlocState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
