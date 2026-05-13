part of 'profile_change_password_bloc.dart';

enum ProfileChangePasswordStatus { initial, saving, success }

class ProfileChangePasswordState extends Equatable {
  final ProfileChangePasswordStatus status;
  final String currentPassword;
  final String password;
  final String passwordConfirmation;
  final bool formSubmitted;
  final ProfileChangePasswordErrors errors;
  final String? serverError;

  const ProfileChangePasswordState({
    this.status = ProfileChangePasswordStatus.initial,
    this.currentPassword = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.formSubmitted = false,
    this.errors = ProfileChangePasswordErrors.empty,
    this.serverError,
  });

  ProfileChangePasswordState copyWith({
    ProfileChangePasswordStatus? status,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
    bool? formSubmitted,
    ProfileChangePasswordErrors? errors,
    Object? serverError = _unset,
  }) {
    return ProfileChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      formSubmitted: formSubmitted ?? this.formSubmitted,
      errors: errors ?? this.errors,
      serverError: serverError == _unset ? this.serverError : serverError as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [
        status,
        currentPassword,
        password,
        passwordConfirmation,
        formSubmitted,
        errors,
        serverError,
      ];
}

class ProfileChangePasswordErrors extends Equatable {
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  const ProfileChangePasswordErrors({
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  static const empty = ProfileChangePasswordErrors();

  bool get hasErrors =>
      currentPassword != null || password != null || passwordConfirmation != null;

  ProfileChangePasswordErrors copyWith({
    Object? currentPassword = _unset,
    Object? password = _unset,
    Object? passwordConfirmation = _unset,
  }) {
    return ProfileChangePasswordErrors(
      currentPassword: currentPassword == _unset
          ? this.currentPassword
          : currentPassword as String?,
      password: password == _unset ? this.password : password as String?,
      passwordConfirmation: passwordConfirmation == _unset
          ? this.passwordConfirmation
          : passwordConfirmation as String?,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];
}
