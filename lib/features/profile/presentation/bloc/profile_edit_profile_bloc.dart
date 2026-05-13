import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_params.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_use_case.dart';

part 'profile_edit_profile_event.dart';
part 'profile_edit_profile_state.dart';

class ProfileEditProfileBloc
    extends Bloc<ProfileEditProfileEvent, ProfileEditProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileEditProfileBloc(
    this.getProfileUseCase,
    this.updateProfileUseCase,
  ) : super(const ProfileEditProfileState()) {
    on<ProfileEditProfileLoadRequested>(_onLoadRequested);
    on<ProfileEditProfileInitialDataReceived>(_onInitialDataReceived);
    on<ProfileEditProfileFieldChanged>(_onFieldChanged);
    on<ProfileEditProfileSaveRequested>(_onSaveRequested);
  }

  void _onInitialDataReceived(
    ProfileEditProfileInitialDataReceived event,
    Emitter<ProfileEditProfileState> emit,
  ) {
    emit(state.copyWith(
      status: ProfileEditProfileStatus.ready,
      profileId: event.profile.id,
      name: event.profile.name,
      phone: event.profile.phone,
      errors: ProfileEditProfileErrors.empty,
      formSubmitted: false,
      serverError: null,
    ));
  }

  Future<void> _onLoadRequested(
    ProfileEditProfileLoadRequested event,
    Emitter<ProfileEditProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: ProfileEditProfileStatus.loading,
      serverError: null,
    ));

    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileEditProfileStatus.failure,
          serverError: _mapFailureToMessage(failure),
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: ProfileEditProfileStatus.ready,
          profileId: profile.id,
          name: profile.name,
          phone: profile.phone,
          errors: ProfileEditProfileErrors.empty,
          formSubmitted: false,
          serverError: null,
        ),
      ),
    );
  }

  void _onFieldChanged(
    ProfileEditProfileFieldChanged event,
    Emitter<ProfileEditProfileState> emit,
  ) {
    final trimmed = event.value.trim();
    ProfileEditProfileState nextState = state;

    if (event.field == 'name') {
      nextState = state.copyWith(name: trimmed);
    } else if (event.field == 'phone') {
      nextState = state.copyWith(phone: trimmed);
    }

    emit(
      nextState.copyWith(
        serverError: null,
        errors: state.formSubmitted
            ? _validateForm(nextState)
            : nextState.errors.copyWith(
                phone: event.field == 'phone' ? null : nextState.errors.phone,
              ),
      ),
    );
  }

  Future<void> _onSaveRequested(
    ProfileEditProfileSaveRequested event,
    Emitter<ProfileEditProfileState> emit,
  ) async {
    if (state.status == ProfileEditProfileStatus.saving) return;

    final errors = _validateForm(state);
    emit(state.copyWith(
      formSubmitted: true,
      errors: errors,
      serverError: null,
    ));
    if (errors.hasErrors) return;

    emit(state.copyWith(status: ProfileEditProfileStatus.saving));

    final result = await updateProfileUseCase(
      UpdateProfileParams(name: state.name, phone: state.phone),
    );

    result.fold(
      (failure) {
        if (failure is ApiFailure) {
          final phoneFieldError = failure.getFieldError('phone');
          final message = failure.message ?? '';
          final phoneTakenFromMessage = message.toLowerCase().contains('phone') &&
              (message.toLowerCase().contains('exist') ||
                  message.toLowerCase().contains('taken') ||
                  message.toLowerCase().contains('already'));

          if (phoneFieldError != null || phoneTakenFromMessage) {
            emit(state.copyWith(
              status: ProfileEditProfileStatus.ready,
              errors: state.errors.copyWith(
                phone: phoneFieldError ?? message,
              ),
              serverError: null,
            ));
            return;
          }
        }

        emit(state.copyWith(
          status: ProfileEditProfileStatus.ready,
          serverError: _mapFailureToMessage(failure),
        ));
      },
      (profile) => emit(state.copyWith(
        status: ProfileEditProfileStatus.success,
        profileId: profile.id,
        name: profile.name,
        phone: profile.phone,
        errors: ProfileEditProfileErrors.empty,
        serverError: null,
      )),
    );
  }

  ProfileEditProfileErrors _validateForm(ProfileEditProfileState state) {
    return ProfileEditProfileErrors(
      name: state.name.isEmpty ? 'Name is required' : null,
      phone: _validatePhone(state.phone),
    );
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) return 'Phone is required';
    final normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!regex.hasMatch(normalized)) return 'Please enter a valid phone number';
    return null;
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
