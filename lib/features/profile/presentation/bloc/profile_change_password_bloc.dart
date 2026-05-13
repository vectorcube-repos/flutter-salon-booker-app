import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_params.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_use_case.dart';

part 'profile_change_password_event.dart';
part 'profile_change_password_state.dart';

class ProfileChangePasswordBloc
    extends Bloc<ProfileChangePasswordEvent, ProfileChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ProfileChangePasswordBloc(this.changePasswordUseCase)
      : super(const ProfileChangePasswordState()) {
    on<ProfileChangePasswordFieldChanged>(_onFieldChanged);
    on<ProfileChangePasswordSaveRequested>(_onSaveRequested);
  }

  void _onFieldChanged(
    ProfileChangePasswordFieldChanged event,
    Emitter<ProfileChangePasswordState> emit,
  ) {
    final value = event.value.trim();
    var nextState = state;

    if (event.field == 'currentPassword') {
      nextState = state.copyWith(currentPassword: value);
    } else if (event.field == 'password') {
      nextState = state.copyWith(password: value);
    } else if (event.field == 'passwordConfirmation') {
      nextState = state.copyWith(passwordConfirmation: value);
    }

    emit(
      nextState.copyWith(
        serverError: null,
        errors: state.formSubmitted ? _validateForm(nextState) : nextState.errors,
      ),
    );
  }

  Future<void> _onSaveRequested(
    ProfileChangePasswordSaveRequested event,
    Emitter<ProfileChangePasswordState> emit,
  ) async {
    if (state.status == ProfileChangePasswordStatus.saving) return;

    final errors = _validateForm(state);
    emit(state.copyWith(
      formSubmitted: true,
      errors: errors,
      serverError: null,
    ));
    if (errors.hasErrors) return;

    emit(state.copyWith(status: ProfileChangePasswordStatus.saving));

    final result = await changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: state.currentPassword,
        password: state.password,
        passwordConfirmation: state.passwordConfirmation,
      ),
    );

    result.fold(
      (failure) {
        if (failure is ApiFailure) {
          final currentPasswordError = failure.getFieldError('current_password');
          final passwordError = failure.getFieldError('password');
          final passwordConfirmationError =
              failure.getFieldError('password_confirmation');

          if (currentPasswordError != null ||
              passwordError != null ||
              passwordConfirmationError != null) {
            emit(state.copyWith(
              status: ProfileChangePasswordStatus.initial,
              errors: state.errors.copyWith(
                currentPassword: currentPasswordError,
                password: passwordError,
                passwordConfirmation: passwordConfirmationError,
              ),
              serverError: null,
            ));
            return;
          }
        }

        emit(state.copyWith(
          status: ProfileChangePasswordStatus.initial,
          serverError: _mapFailureToMessage(failure),
        ));
      },
      (_) => emit(state.copyWith(
        status: ProfileChangePasswordStatus.success,
        errors: ProfileChangePasswordErrors.empty,
        serverError: null,
      )),
    );
  }

  ProfileChangePasswordErrors _validateForm(ProfileChangePasswordState state) {
    String? passwordConfirmationError;
    if (state.passwordConfirmation.isEmpty) {
      passwordConfirmationError = 'Confirm password is required';
    } else if (state.passwordConfirmation != state.password) {
      passwordConfirmationError = 'Passwords do not match';
    }

    return ProfileChangePasswordErrors(
      currentPassword:
          state.currentPassword.isEmpty ? 'Current password is required' : null,
      password: state.password.isEmpty ? 'New password is required' : null,
      passwordConfirmation: passwordConfirmationError,
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message ?? 'Network error. Unexpected error occurred.';
    }
    if (failure is ServerFailure) {
      return failure.message ?? 'Something went wrong. Please try again later.';
    }
    if (failure is ApiFailure) {
      if (failure.statusCode == 0) {
        return failure.message ?? 'Network error. Unexpected error occurred.';
      }
      return failure.message ?? 'Something went wrong. Please try again later.';
    }
    return failure.message ?? 'Unexpected error occurred.';
  }
}
