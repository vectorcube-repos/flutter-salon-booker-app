import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_latest_booking.dart';
import 'package:salon_booker_app/features/home/domain/entities/home_salon.dart';
import 'package:salon_booker_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/presentation/cubit/salon_favorites_cubit.dart';
import 'package:go_router/go_router.dart';

const _bgColor = Color(0xFFF5F5F6);
const _salonImageColor = Color(0xFFE5E5E7);
const _radiusSm = 16.0;
const _radiusMd = 18.0;

const _categoryIconMap = {
  'haircut': Icons.content_cut_rounded,
  'spa': Icons.spa_rounded,
  'nail art': Icons.palette_outlined,
  'shaving': Icons.face_3_outlined,
  'manicure': Icons.back_hand_outlined,
  'pedicure': Icons.spa_outlined,
  'facial': Icons.face_retouching_natural_outlined,
  'massage': Icons.self_improvement_outlined,
  'beard trim': Icons.face_3_outlined,
  'blowout': Icons.air_rounded,
  'highlights': Icons.auto_awesome_outlined,
  'balayage': Icons.brush_outlined,
  'keratin treatment': Icons.spa_rounded,
  'deep conditioning': Icons.water_drop_outlined,
  'more': Icons.more_horiz_rounded,
};

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is! HomeLoaded) return;
          context.read<SalonFavoritesCubit>().syncFavoriteStatuses({
            for (final salon in state.data.salons) salon.id: salon.isFavorite,
          });
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeLoadingFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: context.typography.body,
                  ),
                ),
              );
            }

            final loadedState = state as HomeLoaded;
            final services = loadedState.data.services;
            final salons = loadedState.data.salons;
            final mostBookedServices = loadedState.data.mostBookedServices;
            final latestBooking = loadedState.data.latestBooking;
            return BlocBuilder<SalonFavoritesCubit, SalonFavoritesState>(
              builder: (context, favoritesState) {
                return SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(
                        const GetHomeDashboardEvent(),
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: sl<LocationSessionNotifier>(),
                              builder: (context, _) {
                                final address =
                                    sl<LocationSessionNotifier>()
                                        .location
                                        ?.displayLabel ??
                                    'Select your location';
                                return _Header(
                                  address: address,
                                  onAddressTap: () =>
                                      context.pushNamed('location-setup'),
                                  onBellTap: () {},
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            _SearchField(
                              onTap: () => context.pushNamed('search'),
                              onExploreTap: () => context.goNamed('products'),
                            ),
                            SizedBox(height: 16.h),
                            if (latestBooking != null) ...[
                              _CurrentBookingsSection(booking: latestBooking),
                              SizedBox(height: 16.h),
                            ],
                            _SectionTitle(title: 'Services'),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 150.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: services.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 12.w),
                                itemBuilder: (context, index) {
                                  return _CategoryTile(
                                    title: services[index].name,
                                    imageUrl: services[index].imageThumb,
                                    fallbackAsset:
                                        _serviceFallbackImages[index %
                                            _serviceFallbackImages.length],
                                    onTap: () => context.goNamed(
                                      'products',
                                      queryParameters: {
                                        'service_id': services[index].id
                                            .toString(),
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Rated Salons',
                                  style: context.typography.pageTitleMedium
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                GestureDetector(
                                  onTap: () => context.goNamed('products'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F5F8),
                                      borderRadius: BorderRadius.circular(
                                        999.r,
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFE0E4EA),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.w),
                                          child: Text(
                                            'View All',
                                            style: context.typography.body
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF1F252D,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          width: 24.w,
                                          height: 24.w,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 15.sp,
                                            color: const Color(0xFF1F252D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 230.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: salons.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 12.w),
                                itemBuilder: (context, index) {
                                  final salon = salons[index];
                                  final isFavorite =
                                      favoritesState.favoriteStatuses[salon
                                          .id] ??
                                      salon.isFavorite;
                                  final isFavoriteLoading = favoritesState
                                      .loadingSalonIds
                                      .contains(salon.id);
                                  return _SalonTile(
                                    title: salon.name,
                                    imageUrl: salon.imageThumb,
                                    onTap: () => context.pushNamed(
                                      'product',
                                      pathParameters: {
                                        'id': salon.id.toString(),
                                      },
                                    ),
                                    onFavoriteTap: () {
                                      context
                                          .read<SalonFavoritesCubit>()
                                          .toggleFavorite(
                                            salonId: salon.id,
                                            isFavorite: isFavorite,
                                          );
                                    },
                                    isFavorite: isFavorite,
                                    isFavoriteLoading: isFavoriteLoading,
                                    location: _buildSalonLocation(salon),
                                    status: salon.status,
                                    fallbackAsset:
                                        _saloonImages[index %
                                            _saloonImages.length],
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 22.h),
                            _SectionTitle(title: 'Most Booked Services'),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 145.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: mostBookedServices.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 12.w),
                                itemBuilder: (context, index) {
                                  final service = mostBookedServices[index];
                                  return _ServiceTile(
                                    title: service.name,
                                    imageUrl: service.imageThumb,
                                    fallbackAsset:
                                        _saloonImages[(index + 5) %
                                            _saloonImages.length],
                                    onTap: () => context.goNamed(
                                      'products',
                                      queryParameters: {
                                        'service_id': service.id.toString(),
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 14.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _buildSalonLocation(HomeSalon salon) {
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

class _Header extends StatelessWidget {
  const _Header({
    required this.address,
    required this.onAddressTap,
    required this.onBellTap,
  });

  final String address;
  final VoidCallback onAddressTap;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: context.typography.pageTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24.sp,
                ),
                children: const [
                  TextSpan(
                    text: 'Salon',
                    style: TextStyle(color: Color(0xFF1D1D1F)),
                  ),
                  TextSpan(
                    text: 'Booker',
                    style: TextStyle(color: Color(0xFFF06D5A)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: onAddressTap,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 220.w),
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.body.copyWith(
                        color: const Color(0xFF50545A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 19.sp,
                    color: const Color(0xFF50545A),
                  ),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onBellTap,
          child: Icon(
            Icons.notifications_none_rounded,
            size: 30.sp,
            color: const Color(0xFF292A2D),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap, required this.onExploreTap});

  final VoidCallback onTap;
  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_radiusMd.r),
                border: Border.all(color: const Color(0xFFE2E2E4)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF54565A),
                    size: 30.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Search salons or services',
                    style: context.typography.body.copyWith(
                      color: const Color(0xFF66686C),
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onExploreTap,
          child: Container(
            width: 48.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_radiusSm.r),
              border: Border.all(color: const Color(0xFFE2E2E4)),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: const Color(0xFF45474B),
              size: 22.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.typography.pageTitleMedium.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CurrentBookingsSection extends StatelessWidget {
  const _CurrentBookingsSection({required this.booking});

  final HomeLatestBooking booking;

  @override
  Widget build(BuildContext context) {
    final salon = booking.salon;
    final service = booking.service;
    final serviceProvider = booking.serviceProvider;
    final subtitleParts = [
      if (service?.name.trim().isNotEmpty ?? false) service!.name.trim(),
      if (serviceProvider?.displayName.trim().isNotEmpty ?? false)
        'with ${serviceProvider!.displayName.trim()}',
    ];
    final dateLabel = _formatBookingDateTime(booking.slotStart);
    final statusLabel = _titleCase((booking.status ?? 'confirmed').trim());
    final salonImageFallback =
        _saloonImages[(salon?.id ?? booking.id) % _saloonImages.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Bookings',
              style: context.typography.pageTitleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed('bookings-preview'),
              child: Text(
                'View All',
                style: context.typography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radiusMd.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: _NetworkOrAssetImage(
                        imageUrl: salon?.imageThumb,
                        fallbackAsset: salonImageFallback,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.storefront_outlined,
                        placeholderSize: 28,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon?.name.trim().isNotEmpty ?? false
                              ? salon!.name.trim()
                              : 'Upcoming Booking',
                          style: context.typography.pageTitleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          subtitleParts.isNotEmpty
                              ? subtitleParts.join(' • ')
                              : 'Service details available soon',
                          style: context.typography.body.copyWith(
                            color: const Color(0xFF5D626A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16.sp,
                              color: const Color(0xFF6D727A),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: context.typography.body.copyWith(
                                  color: const Color(0xFF42474F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF8EA),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                statusLabel,
                                style: context.typography.body.copyWith(
                                  color: const Color(0xFF2F8E1F),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatBookingDateTime(String? value) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) return 'Upcoming';

  final local = parsed.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final bookingDay = DateTime(local.year, local.month, local.day);
  final dayDifference = bookingDay.difference(today).inDays;

  String twoDigits(int number) => number.toString().padLeft(2, '0');

  final rawHour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minutes = twoDigits(local.minute);
  final meridiem = local.hour >= 12 ? 'PM' : 'AM';
  final timeText = '$rawHour:$minutes $meridiem';

  if (dayDifference == 0) return 'Today, $timeText';
  if (dayDifference == 1) return 'Tomorrow, $timeText';

  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${monthNames[local.month - 1]} ${local.day}, $timeText';
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.imageUrl,
    required this.fallbackAsset,
    required this.onTap,
  });

  final String title;
  final String? imageUrl;
  final String fallbackAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 128.w,
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radiusMd.r),
          border: Border.all(color: const Color(0xFFE8EAEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 72.h,
                    child: _NetworkOrAssetImage(
                      imageUrl: imageUrl,
                      fallbackAsset: fallbackAsset,
                      fit: BoxFit.cover,
                      placeholderIcon:
                          _categoryIconMap[title.toLowerCase()] ??
                          Icons.design_services,
                      placeholderSize: 24,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.02),
                            Colors.black.withValues(alpha: 0.16),
                          ],
                          stops: const [0.45, 1],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.body.copyWith(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF222326),
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '12 Salons',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.body.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5E636B),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE7E9ED)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14.sp,
                            color: const Color(0xFF17181A),
                          ),
                        ),
                      ],
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

class _SalonTile extends StatelessWidget {
  const _SalonTile({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.onFavoriteTap,
    required this.isFavorite,
    required this.isFavoriteLoading,
    required this.location,
    required this.fallbackAsset,
    this.status,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final String location;
  final String fallbackAsset;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 208.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radiusMd.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 116.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radiusMd.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radiusMd.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _NetworkOrAssetImage(
                        imageUrl: imageUrl,
                        fallbackAsset: fallbackAsset,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.storefront_outlined,
                        placeholderSize: 48,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.06),
                              Colors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 10.h,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isFavoriteLoading
                              ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18.sp,
                                  color: isFavorite
                                      ? const Color(0xFFE24D59)
                                      : const Color(0xFF4A4D52),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.pageTitleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 18.sp,
                        color: const Color(0xFF3A9B62),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        (status?.trim().isNotEmpty ?? false)
                            ? _titleCase(status!)
                            : 'Open now',
                        style: context.typography.body.copyWith(
                          color: const Color(0xFF52565D),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: const Color(0xFF6A6D72),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.body.copyWith(
                            color: const Color(0xFF6A6F77),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.fallbackAsset,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radiusSm.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 74.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radiusSm.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radiusSm.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _NetworkOrAssetImage(
                        imageUrl: imageUrl,
                        fallbackAsset: fallbackAsset,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.design_services_outlined,
                        placeholderSize: 36,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.pageTitleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Popular service',
                    style: context.typography.pageTitleSmall.copyWith(
                      color: const Color(0xFF5E636B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkOrAssetImage extends StatelessWidget {
  const _NetworkOrAssetImage({
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
          color: _salonImageColor,
          alignment: Alignment.center,
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Home image load failed: url=$url error=$error');
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
        color: _salonImageColor,
        alignment: Alignment.center,
        child: Icon(
          placeholderIcon,
          size: placeholderSize.sp,
          color: const Color(0xFF9A9CA0),
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
