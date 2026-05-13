import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUseCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  final tUser = User(id: 1, name: 'Test User', phone: '1234567890');

  test('should return User when repository has a user', () async {
    // Arrange
    when(() => mockAuthRepository.getUser())
        .thenAnswer((_) async => tUser);

    // Act
    final result = await getCurrentUserUseCase();

    // Assert
    verify(() => mockAuthRepository.getUser()).called(1);
    expect(result, tUser);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return null when repository has no user', () async {
    // Arrange
    when(() => mockAuthRepository.getUser())
        .thenAnswer((_) async => null);

    // Act
    final result = await getCurrentUserUseCase();

    // Assert
    verify(() => mockAuthRepository.getUser()).called(1);
    expect(result, null);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
