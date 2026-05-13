import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/clear_session_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final ClearSessionUseCase clearSessionUseCase;
  final AuthSessionNotifier _sessionNotifier;
  late final StreamSubscription<AuthSessionEvent> _sessionSubscription;

  AuthBloc(
    this.getCurrentUserUseCase,
    this.logoutUseCase,
    this.clearSessionUseCase,
    this._sessionNotifier, {
    AuthState? initialState,
  }) : super(initialState ?? AuthState.unknown()) {
    if (kDebugMode) debugPrint('AuthBloc constructed');
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<SessionExpired>(_onSessionExpired);
    on<AccountDisabledDetected>(_onAccountDisabledDetected);

    _sessionSubscription = _sessionNotifier.stream.listen((event) {
      if (event == AuthSessionEvent.unauthorized) {
        add(const SessionExpired());
      } else if (event == AuthSessionEvent.accountDisabled) {
        add(const AccountDisabledDetected());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    if (kDebugMode) debugPrint('onAppStarted');

    final user = await getCurrentUserUseCase();

    if (kDebugMode) debugPrint('user: $user');

    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(AuthState.unauthenticated());
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await logoutUseCase(const NoParams());
    emit(AuthState.unauthenticated());
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await clearSessionUseCase();
    emit(AuthState.unauthenticated());
  }

  Future<void> _onAccountDisabledDetected(
    AccountDisabledDetected event,
    Emitter<AuthState> emit,
  ) async {
    await clearSessionUseCase();
    emit(AuthState.accountDisabled());
  }

  @override
  Future<void> close() {
    _sessionSubscription.cancel();
    return super.close();
  }
}
