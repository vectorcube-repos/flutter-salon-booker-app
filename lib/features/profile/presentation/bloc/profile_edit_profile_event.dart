part of 'profile_edit_profile_bloc.dart';

sealed class ProfileEditProfileEvent extends Equatable {
  const ProfileEditProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileEditProfileLoadRequested extends ProfileEditProfileEvent {
  const ProfileEditProfileLoadRequested();
}

final class ProfileEditProfileInitialDataReceived extends ProfileEditProfileEvent {
  final Profile profile;

  const ProfileEditProfileInitialDataReceived({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final class ProfileEditProfileFieldChanged extends ProfileEditProfileEvent {
  final String field;
  final String value;

  const ProfileEditProfileFieldChanged({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

final class ProfileEditProfileSaveRequested extends ProfileEditProfileEvent {
  const ProfileEditProfileSaveRequested();
}
