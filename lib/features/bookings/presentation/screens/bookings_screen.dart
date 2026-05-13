import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/booking_item.dart';
import 'package:salon_booker_app/features/bookings/presentation/bloc/bookings_bloc.dart';

const _bookingsBg = Color(0xFFF6F6F7);
const _bookingFallbackImages = [
  'assets/saloons/1.jpg',
  'assets/saloons/2.jpg',
  'assets/saloons/3.jpg',
  'assets/saloons/4.jpg',
  'assets/saloons/5.jpg',
  'assets/saloons/6.jpg',
];

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bookingsBg,
      appBar: AppBar(
        backgroundColor: _bookingsBg,
        surfaceTintColor: _bookingsBg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Bookings',
          style: context.typography.pageTitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<BookingsBloc, BookingsState>(
        builder: (context, state) {
          final bookings = _resolveItems(state);

          if (state is BookingsInitial ||
              (state is BookingsLoading && bookings.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingsLoadingFailure && bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: context.typography.body,
                ),
              ),
            );
          }

          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'No bookings found yet.',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    color: const Color(0xFF5F646C),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BookingsBloc>().add(const GetBookingsEvent());
            },
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => _BookingCard(
                booking: bookings[index],
                fallbackAsset:
                    _bookingFallbackImages[index %
                        _bookingFallbackImages.length],
              ),
            ),
          );
        },
      ),
    );
  }

  List<BookingItem> _resolveItems(BookingsState state) {
    if (state is BookingsLoaded) return state.data.items;
    if (state is BookingsLoading) return state.previousData.items;
    if (state is BookingsLoadingFailure) return state.previousData.items;
    return const [];
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.fallbackAsset});

  final BookingItem booking;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status ?? booking.statusLabel);
    final statusBg = statusColor.withValues(alpha: 0.13);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _BookingImage(
                    imageUrl: booking.salonImage,
                    fallbackAsset: fallbackAsset,
                    width: 64.w,
                    height: 64.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.pageTitleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${booking.serviceName} • with ${booking.staffName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.body.copyWith(
                          color: const Color(0xFF5F646C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16.sp,
                            color: const Color(0xFF70757D),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              booking.timeLabel,
                              style: context.typography.body.copyWith(
                                color: const Color(0xFF42474F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              booking.statusLabel,
                              style: context.typography.body.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.sp,
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
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E8E20);
      case 'completed':
        return const Color(0xFF2C6BD9);
      case 'cancelled':
        return const Color(0xFFD94848);
      default:
        return const Color(0xFF676C74);
    }
  }
}

class _BookingImage extends StatelessWidget {
  const _BookingImage({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.width,
    required this.height,
  });

  final String? imageUrl;
  final String fallbackAsset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);
    if (normalizedImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: normalizedImageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE6E8EB),
      alignment: Alignment.center,
      child: SizedBox(
        width: 18.w,
        height: 18.w,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE6E8EB),
        child: Icon(
          Icons.storefront_outlined,
          color: const Color(0xFF858A93),
          size: 30.sp,
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
