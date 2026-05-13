import 'package:salon_booker_app/core/usecases/usecase.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class RequestOtpUseCase implements UseCase<void, RequestOtpParams> {
  final AuthRepository repository;

  RequestOtpUseCase(this.repository);

  @override
  ResultFuture<void> call(RequestOtpParams params) {
    return repository.requestOtp(params.phone);
  }
}

class RequestOtpParams {
  final String phone;

  const RequestOtpParams({required this.phone});
}
