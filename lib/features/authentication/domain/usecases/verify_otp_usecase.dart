import 'package:salon_booker_app/core/usecases/usecase.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<User, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  ResultFuture<User> call(VerifyOtpParams params) {
    return repository.verifyOtp(params.phone, params.otp);
  }
}

class VerifyOtpParams {
  final String phone;
  final String otp;

  const VerifyOtpParams({required this.phone, required this.otp});
}
