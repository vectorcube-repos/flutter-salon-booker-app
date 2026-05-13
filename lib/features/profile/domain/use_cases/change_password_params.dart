import 'package:equatable/equatable.dart';

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];
}
