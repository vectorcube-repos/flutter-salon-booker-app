import 'package:flutter_test/flutter_test.dart';
import 'package:salon_booker_app/features/authentication/data/models/user_model.dart';
import 'package:salon_booker_app/features/authentication/domain/entities/user.dart';

void main() {
  final tUserModel = UserModel(
    id: 1,
    name: 'John Doe',
    phone: '1234567890',
    token: 'token',
  );

  group('UserModel', () {
    test('should be a subclass of [User] entity', () {
      expect(tUserModel, isA<User>());
    });

    test('should have correct props for equality comparison', () {
      final userModel1 = UserModel(
        id: 1,
        name: 'John Doe',
        phone: '1234567890',
        token: 'token',
      );
      final userModel2 = UserModel(
        id: 1,
        name: 'John Doe',
        phone: '1234567890',
        token: 'token',
      );
      expect(userModel1, equals(userModel2));
    });
  });

  group('fromLocalJson', () {
    test('should return a [UserModel] when local JSON is valid with token', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'phone': '1234567890',
        'token': 'token',
      };
      final result = UserModel.fromLocalJson(json);
      expect(result.id, 1);
      expect(result.name, 'John Doe');
      expect(result.phone, '1234567890');
      expect(result.token, 'token');
    });

    test('should return [UserModel] with empty token when token is missing', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'phone': '1234567890',
      };
      final result = UserModel.fromLocalJson(json);
      expect(result.id, 1);
      expect(result.name, 'John Doe');
      expect(result.phone, '1234567890');
      expect(result.token, '');
    });

    test('should throw [FormatException] when id is missing', () {
      final json = {
        'name': 'John Doe',
        'phone': '1234567890',
      };
      expect(
        () => UserModel.fromLocalJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw [FormatException] when name is missing', () {
      final json = {
        'id': 1,
        'phone': '1234567890',
      };
      expect(
        () => UserModel.fromLocalJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw [FormatException] when phone is missing', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
      };
      expect(
        () => UserModel.fromLocalJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('fromVerifyOtpJson', () {
    test('should return valid [UserModel] from verify OTP response', () {
      final json = {
        'status': true,
        'message': 'Login successful.',
        'data': {
          'user': {
            'id': 8,
            'first_name': 'John',
            'last_name': 'Doe',
            'phone': '1234567890',
            'role': 'customer',
          },
          'token': 'test-token',
        },
      };
      final result = UserModel.fromVerifyOtpJson(json);
      expect(result, isA<UserModel>());
      expect(result.id, 8);
      expect(result.name, 'John Doe');
      expect(result.phone, '1234567890');
      expect(result.token, 'test-token');
    });

    test('should use Guest when first_name and last_name are null', () {
      final json = {
        'status': true,
        'message': 'Login successful.',
        'data': {
          'user': {
            'id': 1,
            'first_name': null,
            'last_name': null,
            'phone': '1234567890',
            'role': 'customer',
          },
          'token': 't',
        },
      };
      final result = UserModel.fromVerifyOtpJson(json);
      expect(result.name, 'Guest');
    });

    test('should throw [FormatException] when status is not true', () {
      final json = {
        'status': false,
        'data': {'user': {}, 'token': 't'},
      };
      expect(
        () => UserModel.fromVerifyOtpJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('toLocalJson', () {
    test('should return a valid JSON map without token', () {
      final result = tUserModel.toLocalJson();
      expect(result, {
        'id': 1,
        'name': 'John Doe',
        'phone': '1234567890',
      });
      expect(result.containsKey('token'), false);
    });
  });

  group('toEntity', () {
    test('should return a valid [User] entity', () {
      final result = tUserModel.toEntity();
      expect(result, isA<User>());
      expect(result.id, tUserModel.id);
      expect(result.name, tUserModel.name);
      expect(result.phone, tUserModel.phone);
    });
  });
}
