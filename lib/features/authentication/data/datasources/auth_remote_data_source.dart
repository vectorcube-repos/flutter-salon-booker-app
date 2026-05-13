import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/data/models/user_model.dart';

/// Remote data source for authentication operations.
///
/// Returns [UserModel] (data layer) which will be converted to [User] entity
/// by the repository (domain layer).
///
abstract class AuthRemoteDataSource {
  /// Requests OTP to be sent to the given phone number.
  ResultFuture<void> requestOtp(String phone);

  /// Verifies OTP for the given phone; returns [UserModel] with user and token on success.
  ResultFuture<UserModel> verifyOtp(String phone, String otp);

  /// Log out the current user.
  /// Invalidates the auth token on the server.
  ResultFuture<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<void> requestOtp(String phone) {
    return _dioClient.post(
      '/auth/otp/request',
      data: {'phone': phone.trim()},
      parser: (data) {
        if (data is Map<String, dynamic> &&
            data['status'] == true &&
            data['message'] != null) {
          return;
        }
        throw FormatException(
          'Invalid OTP request response: ${data?.toString() ?? 'null'}',
        );
      },
    );
  }

  @override
  ResultFuture<UserModel> verifyOtp(String phone, String otp) {
    return _dioClient.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'otp': otp},
      parser: (data) => UserModel.fromVerifyOtpJson(data as Map<String, dynamic>),
    );
  }

  @override
  ResultFuture<void> logout() {
    return _dioClient.post<void>('/auth/logout', parser: (_) {});
  }
}
