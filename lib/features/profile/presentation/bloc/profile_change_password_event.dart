part of 'profile_change_password_bloc.dart';

sealed class ProfileChangePasswordEvent extends Equatable {
  const ProfileChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileChangePasswordFieldChanged extends ProfileChangePasswordEvent {
  final String field;
  final String value;

  const ProfileChangePasswordFieldChanged({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

final class ProfileChangePasswordSaveRequested extends ProfileChangePasswordEvent {
  const ProfileChangePasswordSaveRequested();
}
