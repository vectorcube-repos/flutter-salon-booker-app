import 'package:salon_booker_app/core/usecases/usecase.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  
  LogoutUseCase(this.repository);
  
  @override
  ResultFuture<void> call(NoParams params) async {
    return repository.logout();
  }
}

class NoParams {
  const NoParams();
}

