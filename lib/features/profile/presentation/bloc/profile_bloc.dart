import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/get_profile_use_case.dart';

part 'profile_bloc_event.dart';
part 'profile_bloc_state.dart';

class ProfileBloc extends Bloc<ProfileBlocEvent, ProfileBlocState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileBloc(this.getProfileUseCase) : super(const ProfileBlocState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileBlocState> emit,
  ) async {
    emit(state.copyWith(status: ProfileBlocStatus.loading));

    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileBlocStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: ProfileBlocStatus.loaded,
          profile: profile,
          errorMessage: null,
        ),
      ),
    );
  }

  void _onProfileUpdated(
    ProfileUpdated event,
    Emitter<ProfileBlocState> emit,
  ) {
    emit(state.copyWith(
      status: ProfileBlocStatus.loaded,
      profile: event.profile,
      errorMessage: null,
    ));
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
