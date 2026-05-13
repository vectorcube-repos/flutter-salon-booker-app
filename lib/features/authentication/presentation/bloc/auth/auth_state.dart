import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, accountDisabled }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState({
    required this.status,
    this.user,
  });

  factory AuthState.unknown() =>
      const AuthState(status: AuthStatus.unknown);

  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.accountDisabled() =>
      const AuthState(status: AuthStatus.accountDisabled);

  @override
  List<Object?> get props => [status, user];
}
