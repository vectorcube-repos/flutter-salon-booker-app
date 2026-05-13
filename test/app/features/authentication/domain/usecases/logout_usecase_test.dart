import 'package:fpdart/fpdart.dart';
import 'package:salon_booker_app/core/errors/failure.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase logoutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUseCase = LogoutUseCase(mockAuthRepository);
  });

  test('should call the [AuthRepository.logout] method', () async {
    // Arrange
    when(
      () => mockAuthRepository.logout(),
    ).thenAnswer((_) async => const Right(null));

    // Act
    final result = await logoutUseCase(
      NoParams(),
    );

    // Assert
    verify(() => mockAuthRepository.logout())
        .called(1);

    expect(result, const Right(null));

    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return [ApiFailure] when the API call fails', () async {
    // Arrange
    when(
      () => mockAuthRepository.logout(),
    ).thenAnswer((_) async => Left(ApiFailure(message: 'API call failed')));

    // Act
    final result = await logoutUseCase(
      NoParams(),
    );

    // Assert
    verify(() => mockAuthRepository.logout())
        .called(1);
    expect(result, Left(ApiFailure(message: 'API call failed')));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
