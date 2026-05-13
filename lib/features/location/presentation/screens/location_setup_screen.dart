import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/location/domain/entities/location_suggestion.dart';
import 'package:salon_booker_app/features/location/presentation/cubit/location_setup_cubit.dart';
import 'package:go_router/go_router.dart';

const _kScreenBackground = Color(0xFFE8EEF2);
const _kCardColor = Colors.white;
const _kPrimaryButton = Color(0xFF2F3440);
const _kPrimaryText = Color(0xFF1F2937);
const _kMutedText = Color(0xFF667084);
const _kAccent = Color(0xFFF06D5A);
const _kBorderColor = Color(0xFFD9E2EC);
const _kSoftSurface = Color(0xFFF5F7FA);
const _kWarningTint = Color(0xFFFFF6E8);
const _kErrorTint = Color(0xFFFFF1F1);

class LocationSetupScreen extends StatelessWidget {
  const LocationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationSetupCubit>(),
      child: const _LocationSetupView(),
    );
  }
}

class _LocationSetupView extends StatefulWidget {
  const _LocationSetupView();

  @override
  State<_LocationSetupView> createState() => _LocationSetupViewState();
}

class _LocationSetupViewState extends State<_LocationSetupView> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<LocationSetupCubit>().search(value);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    context.read<LocationSetupCubit>().search('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSetupCubit, LocationSetupState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.message != current.message,
      listener: (context, state) {
        if (state.status == LocationSetupStatus.success &&
            state.selectedLocation != null) {
          context.go('/');
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _kScreenBackground,
          body: SafeArea(
            child: BlocBuilder<LocationSetupCubit, LocationSetupState>(
              builder: (context, state) {
                final liveQuery = _controller.text.trim();
                final showGenericMessage =
                    state.message != null &&
                    !state.locationServicesDisabled &&
                    !state.permissionDenied &&
                    !state.permissionDeniedForever;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.of(context).canPop()) ...[
                        _BackButton(onTap: () => context.pop()),
                        SizedBox(height: 20.h),
                      ],
                      Text(
                        'Choose your location',
                        style: context.typography.pageTitle.copyWith(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: _kPrimaryText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'We use your location to show the nearest salons, accurate availability, and better recommendations.',
                        style: context.typography.body.copyWith(
                          color: _kMutedText,
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _CurrentLocationCard(
                        isLoading:
                            state.status ==
                            LocationSetupStatus.savingCurrentLocation,
                        onPressed: () => context
                            .read<LocationSetupCubit>()
                            .useCurrentLocation(),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Or search for your area',
                        style: context.typography.pageTitleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kPrimaryText,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _SearchInput(
                        controller: _controller,
                        onChanged: _onQueryChanged,
                        onClear: _clearSearch,
                      ),
                      SizedBox(height: 12.h),
                      if (showGenericMessage) ...[
                        _MessageCard(
                          message: state.message!,
                          isError:
                              state.status == LocationSetupStatus.failure ||
                              state.status == LocationSetupStatus.searchFailure,
                        ),
                        SizedBox(height: 12.h),
                      ],
                      if (state.locationServicesDisabled) ...[
                        _SettingsActionCard(
                          title: 'Location services are turned off',
                          subtitle:
                              'Enable location services on your device, or search manually.',
                          actionLabel: 'Open settings',
                          onTap: () => context
                              .read<LocationSetupCubit>()
                              .openLocationSettings(),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      if (state.permissionDenied) ...[
                        const _MessageCard(
                          message:
                              'Location permission was denied. You can still search manually.',
                          isError: false,
                        ),
                        SizedBox(height: 12.h),
                      ],
                      if (state.permissionDeniedForever) ...[
                        _SettingsActionCard(
                          title: 'Location permission is blocked',
                          subtitle:
                              'Open app settings to allow location access, or search manually.',
                          actionLabel: 'Open app settings',
                          onTap: () => context
                              .read<LocationSetupCubit>()
                              .openAppSettings(),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      _ResultsCard(
                        title: liveQuery.length >= 3
                            ? 'Search results'
                            : 'Search tips',
                        child: _buildResultsContent(
                          context: context,
                          state: state,
                          liveQuery: liveQuery,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent({
    required BuildContext context,
    required LocationSetupState state,
    required String liveQuery,
  }) {
    final isSearching = state.status == LocationSetupStatus.searching;
    final isResolving = state.status == LocationSetupStatus.resolvingSelection;

    if (isSearching || isResolving) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 12.h),
              Text(
                isResolving ? 'Saving location...' : 'Searching locations...',
                style: context.typography.body.copyWith(color: _kMutedText),
              ),
            ],
          ),
        ),
      );
    }

    if (state.suggestions.isNotEmpty) {
      return _SuggestionsList(
        suggestions: state.suggestions,
        onTap: (suggestion) =>
            context.read<LocationSetupCubit>().selectSuggestion(suggestion),
      );
    }

    if (liveQuery.length >= 3) {
      return _EmptyState(
        title: 'No locations found',
        subtitle:
            'Try searching with a nearby landmark, area, or city name instead.',
      );
    }

    return const _SearchTips();
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: _kCardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _kBorderColor),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimaryText,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: _kSoftSurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: _kAccent,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use my current location',
                      style: context.typography.pageTitleMedium.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _kPrimaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Share your live location to find nearby salons faster.',
                      style: context.typography.body.copyWith(
                        color: _kMutedText,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryButton,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Use current location',
                      style: context.typography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasValue = value.text.trim().isNotEmpty;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: hasValue
                  ? const Color(0xFFF2C6BC)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101828).withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: hasValue ? const Color(0xFFFFEFE9) : _kSoftSurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: hasValue ? _kAccent : _kMutedText,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: context.typography.body.copyWith(
                    color: _kPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Search area, city, landmark...',
                    hintStyle: context.typography.body.copyWith(
                      color: _kMutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (hasValue) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: _kSoftSurface,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: _kMutedText,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.pageTitleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: _kPrimaryText,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({required this.suggestions, required this.onTap});

  final List<LocationSuggestion> suggestions;
  final ValueChanged<LocationSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) =>
          Divider(height: 1.h, color: _kBorderColor),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final title = suggestion.mainText.isNotEmpty
            ? suggestion.mainText
            : suggestion.name;
        final subtitle = suggestion.secondaryText.isNotEmpty
            ? suggestion.secondaryText
            : suggestion.address;

        return ListTile(
          onTap: () => onTap(suggestion),
          contentPadding: EdgeInsets.symmetric(vertical: 4.h),
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _kSoftSurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: _kAccent,
              size: 22.sp,
            ),
          ),
          title: Text(
            title,
            style: context.typography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: _kPrimaryText,
            ),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  style: context.typography.body.copyWith(
                    color: _kMutedText,
                    fontSize: 13.sp,
                  ),
                ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: _kMutedText,
          ),
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isError ? _kErrorTint : _kSoftSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        message,
        style: context.typography.body.copyWith(
          color: isError ? const Color(0xFFD64545) : _kMutedText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kWarningTint,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.pageTitleSmall.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _kPrimaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: context.typography.body.copyWith(
              color: _kMutedText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: _kAccent,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: context.typography.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Icon(Icons.travel_explore_rounded, size: 34.sp, color: _kMutedText),
            SizedBox(height: 10.h),
            Text(
              title,
              style: context.typography.pageTitleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: _kPrimaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: context.typography.body.copyWith(
                color: _kMutedText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTips extends StatelessWidget {
  const _SearchTips();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TipRow(text: 'Type at least 3 characters to start searching.'),
        SizedBox(height: 10.h),
        _TipRow(text: 'Use an area, landmark, or city for better matches.'),
        SizedBox(height: 10.h),
        _TipRow(
          text: 'Choose the closest result to keep availability accurate.',
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7.h),
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: _kPrimaryButton,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: context.typography.body.copyWith(
              color: _kMutedText,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
