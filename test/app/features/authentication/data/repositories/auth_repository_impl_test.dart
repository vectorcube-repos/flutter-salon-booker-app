import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';
import 'package:salon_booker_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:salon_booker_app/features/authentication/data/models/user_model.dart';
import 'package:salon_booker_app/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late AuthRepositoryImpl authRepositoryImpl;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockSecureStorageService mockSecureStorageService;

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorageService = MockSecureStorageService();
    authRepositoryImpl = AuthRepositoryImpl(
      mockAuthRemoteDataSource,
      mockSecureStorageService,
    );
  });

  final tUserModel = UserModel(
    id: 1,
    name: 'Test User',
    phone: '1234567890',
    token: 'test-token',
  );

  group('requestOtp', () {
    test('should forward to remote data source', () async {
      when(() => mockAuthRemoteDataSource.requestOtp(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await authRepositoryImpl.requestOtp('1234567890');

      verify(() => mockAuthRemoteDataSource.requestOtp('1234567890')).called(1);
      expect(result.isRight(), true);
    });
  });

  group('verifyOtp', () {
    test('should save auth session and return User on success', () async {
      when(() => mockAuthRemoteDataSource.verifyOtp(any(), any()))
          .thenAnswer((_) async => Right(tUserModel));
      when(() => mockSecureStorageService.saveAuthSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            userJson: any(named: 'userJson'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => Future.value());

      final result =
          await authRepositoryImpl.verifyOtp('1234567890', '1234');

      verify(() => mockAuthRemoteDataSource.verifyOtp('1234567890', '1234'))
          .called(1);
      verify(() => mockSecureStorageService.saveAuthSession(
            accessToken: 'test-token',
            refreshToken: 'test-token',
            userJson: any(named: 'userJson'),
            userId: 1,
          )).called(1);
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should return Right'),
        (user) {
          expect(user.id, 1);
          expect(user.name, 'Test User');
          expect(user.phone, '1234567890');
        },
      );
    });

    test('should return ApiFailure with message on 401', () async {
      final tApiFailure =
          ApiFailure(statusCode: 401, message: 'Invalid or expired OTP.');
      when(() => mockAuthRemoteDataSource.verifyOtp(any(), any()))
          .thenAnswer((_) async => Left(tApiFailure));

      final result =
          await authRepositoryImpl.verifyOtp('1234567890', '1234');

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect((failure as ApiFailure).statusCode, 401);
        },
        (r) => fail('Should return Left'),
      );
    });
  });

  group('logout', () {
    test('should clear auth data and return Right on successful logout',
        () async {
      when(() => mockAuthRemoteDataSource.logout())
          .thenAnswer((_) async => const Right(null));
      when(() => mockSecureStorageService.clearAuthData())
          .thenAnswer((_) async => Future.value());

      final result = await authRepositoryImpl.logout();

      verify(() => mockAuthRemoteDataSource.logout()).called(1);
      verify(() => mockSecureStorageService.clearAuthData()).called(1);
      expect(result.isRight(), true);
    });

    test('should clear auth data even when remote logout fails', () async {
      final tApiFailure =
          ApiFailure(statusCode: 500, message: 'Server error');
      when(() => mockAuthRemoteDataSource.logout())
          .thenAnswer((_) async => Left(tApiFailure));
      when(() => mockSecureStorageService.clearAuthData())
          .thenAnswer((_) async => Future.value());

      final result = await authRepositoryImpl.logout();

      verify(() => mockAuthRemoteDataSource.logout()).called(1);
      verify(() => mockSecureStorageService.clearAuthData()).called(1);
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (r) => fail('Should return Left'),
      );
    });
  });

  group('getUser', () {
    test('should return User when valid user JSON exists', () async {
      const userJson =
          '{"id": 1, "name": "Test User", "phone": "1234567890"}';
      when(() => mockSecureStorageService.getUser())
          .thenAnswer((_) async => userJson);

      final result = await authRepositoryImpl.getUser();

      verify(() => mockSecureStorageService.getUser()).called(1);
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.name, 'Test User');
      expect(result.phone, '1234567890');
    });

    test('should return null when no user JSON exists', () async {
      when(() => mockSecureStorageService.getUser())
          .thenAnswer((_) async => null);

      final result = await authRepositoryImpl.getUser();

      verify(() => mockSecureStorageService.getUser()).called(1);
      expect(result, isNull);
    });

    test('should return null and delete user when JSON is invalid', () async {
      const invalidJson = 'invalid json';
      when(() => mockSecureStorageService.getUser())
          .thenAnswer((_) async => invalidJson);
      when(() => mockSecureStorageService.deleteUser())
          .thenAnswer((_) async => Future.value());

      final result = await authRepositoryImpl.getUser();

      verify(() => mockSecureStorageService.getUser()).called(1);
      verify(() => mockSecureStorageService.deleteUser()).called(1);
      expect(result, isNull);
    });

    test('should return null when decoded data is not a Map', () async {
      const listJson = '["data"]';
      when(() => mockSecureStorageService.getUser())
          .thenAnswer((_) async => listJson);
      when(() => mockSecureStorageService.deleteUser())
          .thenAnswer((_) async => Future.value());

      final result = await authRepositoryImpl.getUser();

      verify(() => mockSecureStorageService.getUser()).called(1);
      verify(() => mockSecureStorageService.deleteUser()).called(1);
      expect(result, isNull);
    });
  });

  group('clearSession', () {
    test('should call clearAuthData on storage service', () async {
      when(() => mockSecureStorageService.clearAuthData())
          .thenAnswer((_) async => Future.value());

      await authRepositoryImpl.clearSession();

      verify(() => mockSecureStorageService.clearAuthData()).called(1);
    });
  });
}
