import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_favorites_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/entities/favorite_salon.dart';
import 'package:go_router/go_router.dart';

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

class ProfileFavoritesScreen extends StatelessWidget {
  const ProfileFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Favourites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: BlocConsumer<ProfileFavoritesBloc, ProfileFavoritesState>(
            listenWhen: (previous, current) =>
                previous.message != current.message,
            listener: (context, state) {
              final message = state.message;
              if (message == null || message.isEmpty) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            builder: (context, state) {
              if (state.status == ProfileFavoritesStatus.loading ||
                  state.status == ProfileFavoritesStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ProfileFavoritesStatus.failure) {
                return Center(
                  child: Text(
                    state.message ?? 'Failed to load favorites',
                    textAlign: TextAlign.center,
                    style: context.typography.body,
                  ),
                );
              }

              if (state.salons.isEmpty) {
                return Center(
                  child: Text(
                    'No favorite salons yet.',
                    textAlign: TextAlign.center,
                    style: context.typography.body.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileFavoritesBloc>().add(
                    const ProfileFavoritesRequested(showLoading: false),
                  );
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.salons.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final salon = state.salons[index];
                    return _FavoriteSalonCard(
                      salon: salon,
                      fallbackAsset:
                          _saloonImages[index % _saloonImages.length],
                      onTap: () => context.pushNamed(
                        'product',
                        pathParameters: {'id': salon.id.toString()},
                      ),
                      onFavoriteTap: () =>
                          context.read<ProfileFavoritesBloc>().add(
                            ProfileFavoriteRemoveRequested(salonId: salon.id),
                          ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoriteSalonCard extends StatelessWidget {
  const _FavoriteSalonCard({
    required this.salon,
    required this.fallbackAsset,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final FavoriteSalon salon;
  final String fallbackAsset;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                    child: _FavoriteSalonImage(
                      imageUrl: salon.image,
                      fallbackAsset: fallbackAsset,
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
                            salon.name,
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
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 19.sp,
                            color: const Color(0xFFE24D59),
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
                          (salon.status?.trim().isNotEmpty ?? false)
                              ? _titleCase(salon.status!)
                              : 'Favorite salon',
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
                            _buildSalonLocation(salon),
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

class _FavoriteSalonImage extends StatelessWidget {
  const _FavoriteSalonImage({
    required this.imageUrl,
    required this.fallbackAsset,
  });

  final String? imageUrl;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);
    if (normalizedImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: normalizedImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFE7E8EA),
          alignment: Alignment.center,
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE7E8EA),
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_outlined,
          size: 38.sp,
          color: const Color(0xFF9A9CA0),
        ),
      ),
    );
  }
}

String _buildSalonLocation(FavoriteSalon salon) {
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
