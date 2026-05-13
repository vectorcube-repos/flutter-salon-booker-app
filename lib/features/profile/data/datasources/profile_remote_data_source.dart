import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/profile/data/models/profile_model.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_params.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_params.dart';

abstract class ProfileRemoteDataSource {
  ResultFuture<ProfileModel> getProfile();
  ResultFuture<ProfileModel> updateProfile(UpdateProfileParams params);
  ResultFuture<void> changePassword(ChangePasswordParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<ProfileModel> getProfile() {
    return _dioClient.get<ProfileModel>(
      '/profile',
      parser: (data) {
        final profileData = _extractProfileMap(data);
        if (profileData == null) {
          throw const FormatException('Could not parse profile response');
        }
        return ProfileModel.fromApiJson(profileData);
      },
    );
  }

  @override
  ResultFuture<ProfileModel> updateProfile(UpdateProfileParams params) {
    return _dioClient.patch<ProfileModel>(
      '/profile',
      data: {
        'name': params.name,
        'phone': params.phone,
      },
      parser: (data) {
        final profileData = _extractProfileMap(data);
        if (profileData == null) {
          throw const FormatException('Could not parse profile response');
        }
        return ProfileModel.fromApiJson(profileData);
      },
    );
  }

  @override
  ResultFuture<void> changePassword(ChangePasswordParams params) {
    return _dioClient.patch<void>(
      '/profile/password',
      data: {
        'current_password': params.currentPassword,
        'password': params.password,
        'password_confirmation': params.passwordConfirmation,
      },
      parser: (_) {},
    );
  }

  Map<String, dynamic>? _extractProfileMap(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final directProfile = data['profile'];
    if (directProfile is Map<String, dynamic>) return directProfile;

    final directUser = data['user'];
    if (directUser is Map<String, dynamic>) return directUser;

    final inner = data['data'];
    if (inner is Map<String, dynamic>) {
      final innerProfile = inner['profile'];
      if (innerProfile is Map<String, dynamic>) return innerProfile;

      final innerUser = inner['user'];
      if (innerUser is Map<String, dynamic>) return innerUser;

      if (inner.containsKey('name') || inner.containsKey('phone')) {
        return inner;
      }
    }

    if (data.containsKey('name') || data.containsKey('phone')) {
      return data;
    }

    return null;
  }
}
