import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:salon_booker_app/features/authentication/data/models/user_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = AuthRemoteDataSourceImpl(mockDioClient);
  });

  final tUserModel = UserModel(
    id: 1,
    name: 'Test User',
    phone: '1234567890',
    token: 'test-token',
  );

  group('requestOtp', () {
    test('should call DioClient.post with correct endpoint and data', () async {
      when(() => mockDioClient.post<void>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Right(null));

      await dataSource.requestOtp('1234567890');

      verify(() => mockDioClient.post<void>(
            '/auth/otp/request',
            data: {'phone': '1234567890'},
            parser: any(named: 'parser'),
          )).called(1);
    });

    test('should return Right(null) on success', () async {
      when(() => mockDioClient.post<void>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Right(null));

      final result = await dataSource.requestOtp('1234567890');

      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when DioClient fails', () async {
      const tFailure = ApiFailure(statusCode: 429, message: 'Too many requests');
      when(() => mockDioClient.post<void>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Left(tFailure));

      final result = await dataSource.requestOtp('1234567890');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (r) => fail('Should return Left'),
      );
    });
  });

  group('verifyOtp', () {
    test('should call DioClient.post with correct endpoint and data', () async {
      when(() => mockDioClient.post<UserModel>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => Right(tUserModel));

      await dataSource.verifyOtp('1234567890', '1234');

      verify(() => mockDioClient.post<UserModel>(
            '/auth/otp/verify',
            data: {'phone': '1234567890', 'otp': '1234'},
            parser: any(named: 'parser'),
          )).called(1);
    });

    test('should return Right(UserModel) on success', () async {
      when(() => mockDioClient.post<UserModel>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => Right(tUserModel));

      final result = await dataSource.verifyOtp('1234567890', '1234');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should return Right'),
        (user) {
          expect(user.id, 1);
          expect(user.name, 'Test User');
          expect(user.phone, '1234567890');
          expect(user.token, 'test-token');
        },
      );
    });

    test('should return Left(Failure) when DioClient fails', () async {
      const tFailure = ApiFailure(statusCode: 401, message: 'Invalid OTP');
      when(() => mockDioClient.post<UserModel>(
            any(),
            data: any(named: 'data'),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Left(tFailure));

      final result = await dataSource.verifyOtp('1234567890', '1234');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ApiFailure>()),
        (r) => fail('Should return Left'),
      );
    });
  });

  group('logout', () {
    test('should call DioClient.post with correct endpoint', () async {
      when(() => mockDioClient.post<void>(
            any(),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Right(null));

      await dataSource.logout();

      verify(() => mockDioClient.post<void>(
            '/auth/logout',
            parser: any(named: 'parser'),
          )).called(1);
    });

    test('should return Right(null) on success', () async {
      when(() => mockDioClient.post<void>(
            any(),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Right(null));

      final result = await dataSource.logout();

      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when DioClient fails', () async {
      const tFailure = NetworkFailure(message: 'No connection');
      when(() => mockDioClient.post<void>(
            any(),
            parser: any(named: 'parser'),
          )).thenAnswer((_) async => const Left(tFailure));

      final result = await dataSource.logout();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (r) => fail('Should return Left'),
      );
    });
  });
}
