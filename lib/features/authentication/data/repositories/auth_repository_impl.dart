import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:salon_booker_app/features/authentication/data/models/user_model.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorageService;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorageService);

  @override
  ResultFuture<void> requestOtp(String phone) async {
    return remoteDataSource.requestOtp(phone);
  }

  @override
  ResultFuture<User> verifyOtp(String phone, String otp) async {
    final result = await remoteDataSource.verifyOtp(phone, otp);
    return result.fold(
      (failure) async => Left(_mapVerifyOtpFailure(failure)),
      (userModel) async {
        await secureStorageService.saveAuthSession(
          accessToken: userModel.token,
          refreshToken: userModel.token,
          userJson: jsonEncode(userModel.toLocalJson()),
          userId: userModel.id,
        );
        return Right(userModel.toEntity());
      },
    );
  }

  /// Logs out and clears local session. Clears local auth data first (optimistic)
  /// so the user is signed out even if the server request fails (e.g. network).
  @override
  ResultFuture<void> logout() async {
    final result = await remoteDataSource.logout();

    await secureStorageService.clearAuthData();

    return result.fold(
      (failure) async => Left(_mapSystemFailure(failure)),
      (_) async => const Right(null),
    );
  }

  @override
  Future<User?> getUser() async {
    final userJson = await secureStorageService.getUser();
    if (userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        final userModel = UserModel.fromLocalJson(decoded);
        return userModel.toEntity();
      }
    } catch (_) {
      // Corrupt or invalid stored user; clear and return null
    }

    await secureStorageService.deleteUser();
    return null;
  }

  @override
  Future<void> clearSession() async {
    await secureStorageService.clearAuthData();
  }

  Failure _mapVerifyOtpFailure(Failure failure) {
    if (failure is ApiFailure && (failure.statusCode ?? 0) == 401) {
      return ApiFailure(
        message: failure.message ?? 'Invalid or expired OTP.',
        statusCode: 401,
      );
    }
    return _mapSystemFailure(failure);
  }

  Failure _mapSystemFailure(Failure failure) {
    if (failure is ApiFailure) {
      final statusCode = failure.statusCode ?? 0;

      if (statusCode == 0) {
        return NetworkFailure(message: failure.message);
      }

      if (statusCode >= 500) {
        return ServerFailure(message: failure.message);
      }
    }

    return failure;
  }
}
