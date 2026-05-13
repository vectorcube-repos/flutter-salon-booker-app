import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_params.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  ResultFuture<void> call(ChangePasswordParams params) {
    return repository.changePassword(params);
  }
}
