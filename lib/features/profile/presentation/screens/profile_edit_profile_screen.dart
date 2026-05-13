import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/common/widgets/elevated_button_widget.dart';
import 'package:salon_booker_app/core/common/widgets/error_text_widget.dart';
import 'package:salon_booker_app/core/common/widgets/labeled_input_field_widget.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/features/profile/domain/entities/profile.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_edit_profile_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileEditProfileScreen extends StatelessWidget {
  const ProfileEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9ECEF),
        surfaceTintColor: const Color(0xFFE9ECEF),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ProfileEditProfileBloc, ProfileEditProfileState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == ProfileEditProfileStatus.success,
        listener: (context, state) {
          context.read<ProfileBloc>().add(
                ProfileUpdated(
                  Profile(
                    id: state.profileId!,
                    name: state.name,
                    phone: state.phone,
                  ),
                ),
              );
          context.pop();
        },
        builder: (context, state) {
          if (state.status == ProfileEditProfileStatus.loading ||
              state.status == ProfileEditProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileEditProfileStatus.failure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  state.serverError ?? 'Failed to load profile',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                children: [
                  if (state.serverError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: ErrorTextWidget(errorMessage: state.serverError!),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Info',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightText,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          LabeledInputFieldWidget(
                            label: 'Name*',
                            value: state.name,
                            keyboardType: TextInputType.name,
                            errorMessage:
                                state.formSubmitted ? state.errors.name : null,
                            onChanged: (value) => context
                                .read<ProfileEditProfileBloc>()
                                .add(
                                  ProfileEditProfileFieldChanged(
                                    field: 'name',
                                    value: value,
                                  ),
                                ),
                          ),
                          SizedBox(height: 24.h),
                          LabeledInputFieldWidget(
                            label: 'Phone*',
                            value: state.phone,
                            keyboardType: TextInputType.phone,
                            errorMessage: state.formSubmitted || state.errors.phone != null
                                ? state.errors.phone
                                : null,
                            onChanged: (value) => context
                                .read<ProfileEditProfileBloc>()
                                .add(
                                  ProfileEditProfileFieldChanged(
                                    field: 'phone',
                                    value: value,
                                  ),
                                ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButtonWidget(
                      buttonLabel: 'Save',
                      isLoading: state.status == ProfileEditProfileStatus.saving,
                      onPressEvent: () => context
                          .read<ProfileEditProfileBloc>()
                          .add(const ProfileEditProfileSaveRequested()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
