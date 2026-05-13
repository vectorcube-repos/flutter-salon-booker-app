import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  /// Requests an OTP to be sent to the given [phone] number.
  ResultFuture<void> requestOtp(String phone);

  /// Verifies OTP for the given [phone] and returns the authenticated [User] on success.
  ResultFuture<User> verifyOtp(String phone, String otp);

  ResultFuture<void> logout();

  Future<User?> getUser();

  Future<void> clearSession();
}
