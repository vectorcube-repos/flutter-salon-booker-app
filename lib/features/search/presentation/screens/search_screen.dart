import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_salon.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_service.dart';
import 'package:salon_booker_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:go_router/go_router.dart';

const _searchBg = Color(0xFFF5F7FA);

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _searchBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Row(
                children: [
                  _HeaderAction(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      buildWhen: (previous, current) =>
                          previous.query != current.query,
                      builder: (context, state) {
                        return _HomeLikeSearchField(
                          query: state.query,
                          onChanged: context.read<SearchCubit>().onQueryChanged,
                          onClear: state.query.isEmpty
                              ? null
                              : context.read<SearchCubit>().clear,
                          hintText: 'Search salons or services',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (!state.hasQuery) {
                    return const _SearchPlaceholder();
                  }

                  if (state.status == SearchStatus.searching &&
                      !state.hasResults) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == SearchStatus.failure) {
                    return _SearchMessageState(
                      icon: Icons.search_off_rounded,
                      title: 'Search unavailable',
                      message: state.message ?? 'Failed to search right now.',
                      buttonLabel: 'Try again',
                      onTap: () =>
                          context.read<SearchCubit>().search(state.query),
                    );
                  }

                  if (state.showEmptyState) {
                    return _SearchMessageState(
                      icon: Icons.manage_search_rounded,
                      title: 'No results found',
                      message: 'Try another salon or service name.',
                    );
                  }

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state.results.services.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _ResultSectionHeader(
                            title: 'Services',
                            count: state.results.services.length,
                          ),
                        ),
                        SliverList.separated(
                          itemBuilder: (context, index) {
                            final service = state.results.services[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: _ServiceResultTile(service: service),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemCount: state.results.services.length,
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 22.h)),
                      ],
                      if (state.results.salons.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _ResultSectionHeader(
                            title: 'Salons',
                            count: state.results.salons.length,
                          ),
                        ),
                        SliverList.separated(
                          itemBuilder: (context, index) {
                            final salon = state.results.salons[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: _SalonResultTile(salon: salon),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemCount: state.results.salons.length,
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E2E4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: SizedBox(
          width: 48.w,
          height: 48.w,
          child: Icon(icon, color: AppColors.lightText, size: 20.sp),
        ),
      ),
    );
  }
}

class _HomeLikeSearchField extends StatefulWidget {
  const _HomeLikeSearchField({
    required this.query,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search salons or services',
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  @override
  State<_HomeLikeSearchField> createState() => _HomeLikeSearchFieldState();
}

class _HomeLikeSearchFieldState extends State<_HomeLikeSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomeLikeSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query == widget.query) return;
    if (_controller.text == widget.query) return;

    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF54565A),
            size: 30.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: context.typography.body.copyWith(
                  color: const Color(0xFF66686C),
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              style: context.typography.body.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
          if (widget.onClear != null)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear?.call();
                _focusNode.requestFocus();
              },
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F4F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: const Color(0xFF6B7280),
                  size: 16.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return _SearchMessageState(
      icon: Icons.search_rounded,
      title: 'Search salons and services',
      message: 'Type at least 2 characters to start searching.',
    );
  }
}

class _SearchMessageState extends StatelessWidget {
  const _SearchMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Icon(icon, size: 30.sp, color: AppColors.primary),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: context.typography.pageTitleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: context.typography.body.copyWith(
                color: AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onTap != null) ...[
              SizedBox(height: 18.h),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: context.typography.pageTitleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceResultTile extends StatelessWidget {
  const _ServiceResultTile({required this.service});

  final SearchService service;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: () => context.goNamed(
          'products',
          queryParameters: {'service_id': service.id.toString()},
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              _SearchImage(
                imageUrl: service.image,
                size: 72,
                borderRadius: 18,
                icon: Icons.design_services_rounded,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.body.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((service.description ?? '').trim().isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        service.description!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.bodySmall.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (service.activeSalonsCount != null)
                          _InfoPill(
                            label: '${service.activeSalonsCount} salons',
                            icon: Icons.storefront_rounded,
                          ),
                        if (service.durationMinutes != null)
                          _InfoPill(
                            label: '${service.durationMinutes} min',
                            icon: Icons.schedule_rounded,
                          ),
                        if ((service.formattedRate ?? '').trim().isNotEmpty)
                          _InfoPill(
                            label: service.formattedRate!.trim(),
                            icon: Icons.currency_rupee_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: const Color(0xFF8A94A6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalonResultTile extends StatelessWidget {
  const _SalonResultTile({required this.salon});

  final SearchSalon salon;

  String _buildLocation() {
    final city = (salon.city ?? '').trim();
    final state = (salon.state ?? '').trim();
    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return (salon.address ?? '').trim().isNotEmpty
        ? salon.address!.trim()
        : 'Location unavailable';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () => context.pushNamed(
          'product',
          pathParameters: {'id': salon.id.toString()},
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              _SearchImage(
                imageUrl: salon.image,
                size: 84,
                borderRadius: 20,
                icon: Icons.storefront_rounded,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.body.copyWith(
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: const Color(0xFFF5B544),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          salon.rating?.toStringAsFixed(1) ?? '--',
                          style: context.typography.caption.copyWith(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '(${salon.reviewsCount} reviews)',
                          style: context.typography.caption.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _buildLocation(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.bodySmall.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    if ((salon.description ?? '').trim().isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        salon.description!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.caption.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchImage extends StatelessWidget {
  const _SearchImage({
    required this.imageUrl,
    required this.size,
    required this.borderRadius,
    required this.icon,
  });

  final String? imageUrl;
  final double size;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: CachedNetworkImage(
          imageUrl: trimmedUrl,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _FallbackImage(
            size: size,
            borderRadius: borderRadius,
            icon: icon,
          ),
          placeholder: (context, url) => _FallbackImage(
            size: size,
            borderRadius: borderRadius,
            icon: icon,
          ),
        ),
      );
    }

    return _FallbackImage(size: size, borderRadius: borderRadius, icon: icon);
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({
    required this.size,
    required this.borderRadius,
    required this.icon,
  });

  final double size;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF3),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.lightTextSecondary, size: 24.sp),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.lightTextSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: context.typography.caption.copyWith(
              color: AppColors.lightText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
