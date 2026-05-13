part of 'profile_edit_profile_bloc.dart';

enum ProfileEditProfileStatus { initial, loading, ready, saving, success, failure }

class ProfileEditProfileState extends Equatable {
  final ProfileEditProfileStatus status;
  final int? profileId;
  final String name;
  final String phone;
  final bool formSubmitted;
  final ProfileEditProfileErrors errors;
  final String? serverError;

  const ProfileEditProfileState({
    this.status = ProfileEditProfileStatus.initial,
    this.profileId,
    this.name = '',
    this.phone = '',
    this.formSubmitted = false,
    this.errors = ProfileEditProfileErrors.empty,
    this.serverError,
  });

  ProfileEditProfileState copyWith({
    ProfileEditProfileStatus? status,
    Object? profileId = _unset,
    String? name,
    String? phone,
    bool? formSubmitted,
    ProfileEditProfileErrors? errors,
    Object? serverError = _unset,
  }) {
    return ProfileEditProfileState(
      status: status ?? this.status,
      profileId: profileId == _unset ? this.profileId : profileId as int?,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      formSubmitted: formSubmitted ?? this.formSubmitted,
      errors: errors ?? this.errors,
      serverError: serverError == _unset ? this.serverError : serverError as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [
        status,
        profileId,
        name,
        phone,
        formSubmitted,
        errors,
        serverError,
      ];
}

class ProfileEditProfileErrors extends Equatable {
  final String? name;
  final String? phone;

  const ProfileEditProfileErrors({
    this.name,
    this.phone,
  });

  static const empty = ProfileEditProfileErrors();

  bool get hasErrors => name != null || phone != null;

  ProfileEditProfileErrors copyWith({
    Object? name = _unset,
    Object? phone = _unset,
  }) {
    return ProfileEditProfileErrors(
      name: name == _unset ? this.name : name as String?,
      phone: phone == _unset ? this.phone : phone as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [name, phone];
}
