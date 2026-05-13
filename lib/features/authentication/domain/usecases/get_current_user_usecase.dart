import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<User?> call() {
    return repository.getUser();
  }
}
