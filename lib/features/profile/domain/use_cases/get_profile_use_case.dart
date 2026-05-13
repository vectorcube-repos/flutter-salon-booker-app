import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  ResultFuture<Profile> call() => repository.getProfile();
}
