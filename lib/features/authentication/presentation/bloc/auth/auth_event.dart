import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoggedIn extends AuthEvent {
  final User user;
  const LoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}

class SessionExpired extends AuthEvent {
  const SessionExpired();
}

class AccountDisabledDetected extends AuthEvent {
  const AccountDisabledDetected();
}
