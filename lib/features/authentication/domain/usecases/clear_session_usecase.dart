import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class ClearSessionUseCase {
  final AuthRepository repository;

  const ClearSessionUseCase(this.repository);

  Future<void> call() {
    return repository.clearSession();
  }
}
