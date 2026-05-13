import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_params.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  ResultFuture<Profile> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
