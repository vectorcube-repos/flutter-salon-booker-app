import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_category.dart';
import 'package:salon_booker_app/features/explore/domain/entities/explore_salon.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/presentation/cubit/salon_favorites_cubit.dart';
import 'package:go_router/go_router.dart';

const _exploreBg = Color(0xFFF6F6F7);
const _cardBg = Colors.white;
const _imageFallbackBg = Color(0xFFE7E8EA);
const _saloonImages = [
  'assets/saloons/1.jpg',
  'assets/saloons/2.jpg',
  'assets/saloons/3.jpg',
  'assets/saloons/4.jpg',
  'assets/saloons/5.jpg',
  'assets/saloons/6.jpg',
  'assets/saloons/7.jpg',
  'assets/saloons/9.jpg',
  'assets/saloons/10.jpg',
  'assets/saloons/11.jpg',
  'assets/saloons/12.jpg',
  'assets/saloons/13.jpg',
  'assets/saloons/14.jpg',
];

const _serviceFallbackImages = [
  'assets/images/categories/category_1.jpg',
  'assets/images/categories/category_2.jpg',
  'assets/images/categories/category_3.jpg',
  'assets/images/categories/category_4.jpg',
  'assets/images/categories/category_5.jpg',
  'assets/images/categories/category_6.png',
];

class SaloonsScreen extends StatefulWidget {
  const SaloonsScreen({super.key, this.serviceId = ''});

  final String serviceId;

  @override
  State<SaloonsScreen> createState() => _SaloonsScreenState();
}

class _SaloonsScreenState extends State<SaloonsScreen> {
  @override
  void didUpdateWidget(covariant SaloonsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceId == widget.serviceId) return;

    context.read<ExploreBloc>().add(
      ExploreRequested(serviceId: widget.serviceId, isInitialLoad: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _exploreBg,
      body: SafeArea(
        bottom: false,
        child: BlocListener<ExploreBloc, ExploreState>(
          listener: (context, state) {
            if (state.status != ExploreStatus.success) return;
            context.read<SalonFavoritesCubit>().syncFavoriteStatuses({
              for (final salon in state.data.salons) salon.id: salon.isFavorite,
            });
          },
          child: BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              if (state.status == ExploreStatus.failure) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      state.message ?? 'Failed to load explore data',
                      textAlign: TextAlign.center,
                      style: context.typography.body,
                    ),
                  ),
                );
              }

              final services = state.data.services;
              final salons = state.data.salons;
              return BlocBuilder<SalonFavoritesCubit, SalonFavoritesState>(
                builder: (context, favoritesState) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis != Axis.vertical) {
                        return false;
                      }

                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        context.read<ExploreBloc>().add(
                          const ExploreNextPageRequested(),
                        );
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ExploreBloc>().add(
                          ExploreRequested(
                            serviceId: state.selectedServiceId,
                            isInitialLoad: true,
                          ),
                        );
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                4.h,
                                20.w,
                                8.h,
                              ),
                              child: Text(
                                'Services',
                                style: context.typography.pageTitleMedium
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _ServiceFilterBar(
                              categories: services,
                              selectedServiceId: state.selectedServiceId,
                              isLoading:
                                  state.status == ExploreStatus.loading &&
                                  services.isEmpty,
                              onFilterTap: (serviceId) {
                                context.read<ExploreBloc>().add(
                                  ExploreServiceSelected(serviceId),
                                );
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                14.h,
                                20.w,
                                8.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'All Salons',
                                    style: context.typography.pageTitleMedium
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${state.data.pagination.total} results',
                                    style: context.typography.body.copyWith(
                                      color: const Color(0xFF62666D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.status == ExploreStatus.loading &&
                              state.data.salons.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 24.h),
                                  child: const CircularProgressIndicator(),
                                ),
                              ),
                            )
                          else if (salons.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  child: Text(
                                    'No salons found for this category.',
                                    textAlign: TextAlign.center,
                                    style: context.typography.body.copyWith(
                                      color: const Color(0xFF62666D),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                4.h,
                                20.w,
                                20.h,
                              ),
                              sliver: SliverList.builder(
                                itemCount:
                                    salons.length +
                                    (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= salons.length) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.h,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final salon = salons[index];
                                  final isFavorite =
                                      favoritesState.favoriteStatuses[salon
                                          .id] ??
                                      salon.isFavorite;
                                  final isFavoriteLoading = favoritesState
                                      .loadingSalonIds
                                      .contains(salon.id);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: _SalonExploreCard(
                                      imageUrl: salon.image,
                                      fallbackAsset:
                                          _saloonImages[index %
                                              _saloonImages.length],
                                      title: salon.name,
                                      location: _buildSalonLocation(salon),
                                      status: salon.status,
                                      isFavorite: isFavorite,
                                      isFavoriteLoading: isFavoriteLoading,
                                      onFavoriteTap: () {
                                        context
                                            .read<SalonFavoritesCubit>()
                                            .toggleFavorite(
                                              salonId: salon.id,
                                              isFavorite: isFavorite,
                                            );
                                      },
                                      onTap: () => context.pushNamed(
                                        'product',
                                        pathParameters: {
                                          'id': salon.id.toString(),
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static String _buildSalonLocation(ExploreSalon salon) {
    final segments = [
      salon.city,
      salon.state,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();

    if (segments.isNotEmpty) {
      return segments.join(', ');
    }

    final address = salon.address?.trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }

    return 'Location unavailable';
  }
}

class _ServiceFilterBar extends StatelessWidget {
  const _ServiceFilterBar({
    required this.categories,
    required this.selectedServiceId,
    required this.isLoading,
    required this.onFilterTap,
  });

  final List<ExploreCategory> categories;
  final String selectedServiceId;
  final bool isLoading;
  final ValueChanged<String> onFilterTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 52.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(width: 8.w),
          itemBuilder: (context, index) => Container(
            width: index == 0 ? 76.w : 110.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE3E5E9)),
            ),
          ),
        ),
      );
    }

    final items = <({String id, String name, String? image})>[
      (id: '', name: 'All', image: null),
      ...categories.map(
        (category) => (
          id: category.id.toString(),
          name: category.name,
          image: category.image,
        ),
      ),
    ];

    return SizedBox(
      height: 52.h,
      child: items.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No services available',
                  style: context.typography.body.copyWith(
                    color: const Color(0xFF62666D),
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedServiceId;

                return GestureDetector(
                  onTap: () => onFilterTap(item.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE3E5E9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isSelected ? 0.08 : 0.03,
                          ),
                          blurRadius: isSelected ? 10 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.18)
                                : const Color(0xFFF2F3F5),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: item.id.isEmpty
                                ? Icon(
                                    Icons.apps_rounded,
                                    size: 16.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF2D3137),
                                  )
                                : _RemoteOrAssetImage(
                                    imageUrl: item.image,
                                    fallbackAsset:
                                        _serviceFallbackImages[index %
                                            _serviceFallbackImages.length],
                                    fit: BoxFit.cover,
                                    placeholderIcon:
                                        Icons.design_services_rounded,
                                    placeholderSize: 16,
                                  ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          item.name,
                          style: context.typography.body.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2D3137),
                            fontWeight: FontWeight.w600,
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

class _SalonExploreCard extends StatelessWidget {
  const _SalonExploreCard({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.title,
    required this.location,
    required this.onTap,
    required this.onFavoriteTap,
    required this.isFavorite,
    required this.isFavoriteLoading,
    this.status,
  });

  final String? imageUrl;
  final String fallbackAsset;
  final String title;
  final String location;
  final String? status;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;
  final bool isFavoriteLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(18.r),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: 120.w,
                    height: 120.h,
                    child: _RemoteOrAssetImage(
                      imageUrl: imageUrl,
                      fallbackAsset: fallbackAsset,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.storefront_outlined,
                      placeholderSize: 38,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.pageTitleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: isFavoriteLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 19.sp,
                                    color: isFavorite
                                        ? const Color(0xFFE24D59)
                                        : const Color(0xFF6A6E76),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 17.sp,
                          color: const Color(0xFF3A9B62),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          (status?.trim().isNotEmpty ?? false)
                              ? _titleCase(status!)
                              : 'Open now',
                          style: context.typography.body.copyWith(
                            color: const Color(0xFF51565E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15.sp,
                          color: const Color(0xFF6A6F77),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.body.copyWith(
                              color: const Color(0xFF6A6F77),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        'Book now',
                        style: context.typography.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteOrAssetImage extends StatelessWidget {
  const _RemoteOrAssetImage({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.fit,
    required this.placeholderIcon,
    required this.placeholderSize,
  });

  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double placeholderSize;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);
    final hasNetworkImage =
        normalizedImageUrl != null && normalizedImageUrl.trim().isNotEmpty;

    if (hasNetworkImage) {
      return CachedNetworkImage(
        imageUrl: normalizedImageUrl,
        fit: fit,
        placeholder: (context, url) => Container(
          color: _imageFallbackBg,
          alignment: Alignment.center,
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Explore image load failed: url=$url error=$error');
          return _buildAssetFallback();
        },
      );
    }

    return _buildAssetFallback();
  }

  Widget _buildAssetFallback() {
    return Image.asset(
      fallbackAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        color: _imageFallbackBg,
        alignment: Alignment.center,
        child: Icon(
          placeholderIcon,
          size: placeholderSize.sp,
          color: const Color(0xFF8A8E95),
        ),
      ),
    );
  }
}

String? _normalizeImageUrl(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return null;
  return raw;
}

String _titleCase(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
