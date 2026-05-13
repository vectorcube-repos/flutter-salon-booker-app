import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_params.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_params.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<Profile> getProfile() async {
    final result = await remoteDataSource.getProfile();
    return result.map((profile) => profile);
  }

  @override
  ResultFuture<Profile> updateProfile(UpdateProfileParams params) async {
    final result = await remoteDataSource.updateProfile(params);
    return result.map((profile) => profile);
  }

  @override
  ResultFuture<void> changePassword(ChangePasswordParams params) async {
    return await remoteDataSource.changePassword(params);
  }
}
