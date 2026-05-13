import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:salon_booker_app/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:salon_booker_app/features/profile/presentation/widgets/profile_top_bar.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileBlocState>(
      builder: (context, state) {
        final name = state.profile?.name ?? '';
        final phone = state.profile?.phone ?? '';

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: state.status == ProfileBlocStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.h),
                            const ProfileTopBar(),
                            SizedBox(height: 28.h),
                            ProfileHeaderCard(name: name, phone: phone),
                            SizedBox(height: 28.h),
                            for (var i = 0; i < _menuItems.length; i++) ...[
                              ProfileMenuTile(
                                label: _menuItems[i],
                                onTap: () {
                                  if (_menuItems[i] == 'Logout') {
                                    context.read<AuthBloc>().add(
                                      const LoggedOut(),
                                    );
                                  } else if (_menuItems[i] == 'Edit Profile') {
                                    context.pushNamed('profile-edit');
                                  } else if (_menuItems[i] ==
                                      'Change Password') {
                                    context.pushNamed(
                                      'profile-change-password',
                                    );
                                  } else if (_menuItems[i] == 'My Favourites') {
                                    context.pushNamed('profile-favorites');
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                color: AppColors.border.withValues(alpha: 0.5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

const _menuItems = ['Edit Profile', 'My Favourites', 'Logout'];
