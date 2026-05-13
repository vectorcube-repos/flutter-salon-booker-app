import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/common/widgets/elevated_button_widget.dart';
import 'package:salon_booker_app/core/common/widgets/error_text_widget.dart';
import 'package:salon_booker_app/core/common/widgets/labeled_input_field_widget.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_change_password_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileChangePasswordScreen extends StatelessWidget {
  const ProfileChangePasswordScreen({super.key});

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
          'Change Password',
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
      body: BlocConsumer<ProfileChangePasswordBloc, ProfileChangePasswordState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == ProfileChangePasswordStatus.success,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
          context.pop();
        },
        builder: (context, state) {
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
                            'Update Password',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightText,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          LabeledInputFieldWidget(
                            label: 'Current Password*',
                            value: state.currentPassword,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            errorMessage: state.formSubmitted
                                ? state.errors.currentPassword
                                : null,
                            onChanged: (value) => context
                                .read<ProfileChangePasswordBloc>()
                                .add(
                                  ProfileChangePasswordFieldChanged(
                                    field: 'currentPassword',
                                    value: value,
                                  ),
                                ),
                          ),
                          SizedBox(height: 24.h),
                          LabeledInputFieldWidget(
                            label: 'New Password*',
                            value: state.password,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            errorMessage:
                                state.formSubmitted ? state.errors.password : null,
                            onChanged: (value) => context
                                .read<ProfileChangePasswordBloc>()
                                .add(
                                  ProfileChangePasswordFieldChanged(
                                    field: 'password',
                                    value: value,
                                  ),
                                ),
                          ),
                          SizedBox(height: 24.h),
                          LabeledInputFieldWidget(
                            label: 'Confirm Password*',
                            value: state.passwordConfirmation,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            errorMessage: state.formSubmitted
                                ? state.errors.passwordConfirmation
                                : null,
                            onChanged: (value) => context
                                .read<ProfileChangePasswordBloc>()
                                .add(
                                  ProfileChangePasswordFieldChanged(
                                    field: 'passwordConfirmation',
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
                      isLoading: state.status == ProfileChangePasswordStatus.saving,
                      onPressEvent: () => context
                          .read<ProfileChangePasswordBloc>()
                          .add(const ProfileChangePasswordSaveRequested()),
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
