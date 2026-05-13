import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_date.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_service.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_slot.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_staff_member.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/salon_booking_bloc.dart';
import 'package:go_router/go_router.dart';

const _heroFallbackImage = 'assets/saloons/1.jpg';
const _serviceFallbackImages = [
  'assets/saloons/6.jpg',
  'assets/saloons/7.jpg',
  'assets/saloons/9.jpg',
  'assets/saloons/10.jpg',
];
const _staffFallbackImages = [
  'assets/saloons/2.jpg',
  'assets/saloons/3.jpg',
  'assets/saloons/4.jpg',
  'assets/saloons/5.jpg',
];

class SaloonScreen extends StatefulWidget {
  const SaloonScreen({super.key, required this.saloonId});

  final String saloonId;

  @override
  State<SaloonScreen> createState() => _SaloonScreenState();
}

class _SaloonScreenState extends State<SaloonScreen> {
  late int _selectedServiceIndex;
  late int _selectedProviderIndex;
  late int _selectedDateIndex;
  late int _selectedSlotIndex;
  bool _didApplyInitialStaffSelection = false;
  bool _didApplyInitialDateSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceIndex = 0;
    _selectedProviderIndex = 0;
    _selectedDateIndex = 0;
    _selectedSlotIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonId = int.tryParse(widget.saloonId);
      if (salonId != null) {
        context.read<SalonBookingBloc>().add(
          SalonBookingDetailsRequested(salonId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalonBookingBloc, SalonBookingState>(
      listener: (context, state) {
        final bookingMessage = state.bookingMessage;
        if (bookingMessage == null || bookingMessage.isEmpty) {
          return;
        }

        if (state.bookingStatus == AppointmentBookingStatus.success) {
          final details = state.details;
          final services = details?.services ?? const <SalonBookingService>[];
          final staffMembers =
              details?.staffMembers ?? const <SalonStaffMember>[];
          final dates = details?.dates ?? const <SalonBookingDate>[];
          final slots = details?.slots ?? const <SalonBookingSlot>[];

          final service = services.isEmpty
              ? null
              : services[_selectedServiceIndex.clamp(0, services.length - 1)];
          final staff = staffMembers.isEmpty
              ? null
              : staffMembers[_selectedProviderIndex.clamp(
                  0,
                  staffMembers.length - 1,
                )];
          final date = dates.isEmpty
              ? null
              : dates[_selectedDateIndex.clamp(0, dates.length - 1)];
          final slot = slots.isEmpty
              ? null
              : slots[_selectedSlotIndex.clamp(0, slots.length - 1)];

          context.goNamed(
            'appointment-confirmed',
            extra: {
              'salonName': details?.name,
              'serviceName': service?.name,
              'staffName': staff?.name,
              'slotLabel': [date?.label, slot?.label]
                  .whereType<String>()
                  .where((value) => value.trim().isNotEmpty)
                  .join(', '),
            },
          );
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor:
                  state.bookingStatus == AppointmentBookingStatus.failure
                  ? Colors.red.shade600
                  : null,
              content: Text(bookingMessage),
            ),
          );
      },
      builder: (context, state) {
        if (state.status == SalonBookingStatus.loading &&
            state.details == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F7FB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == SalonBookingStatus.failure &&
            state.details == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF4F7FB),
              surfaceTintColor: const Color(0xFFF4F7FB),
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message ?? 'Failed to load salon details',
                      textAlign: TextAlign.center,
                      style: context.typography.body,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _reloadDetails,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final details = state.details;
        if (details == null) {
          return const SizedBox.shrink();
        }

        final services = details.services;
        final staffMembers = details.staffMembers;
        final dates = details.dates;
        final slots = details.slots;

        final selectedStaffIndex = _resolveSelectedStaffIndex(
          staffMembers,
          details.selectedStaffId,
        );
        if (!_didApplyInitialStaffSelection &&
            selectedStaffIndex >= 0 &&
            selectedStaffIndex < staffMembers.length) {
          _selectedProviderIndex = selectedStaffIndex;
          _didApplyInitialStaffSelection = true;
        }

        final selectedDateIndex = _resolveSelectedDateIndex(
          dates,
          details.selectedDate,
        );
        if (!_didApplyInitialDateSelection &&
            selectedDateIndex >= 0 &&
            selectedDateIndex < dates.length) {
          _selectedDateIndex = selectedDateIndex;
          _didApplyInitialDateSelection = true;
        }

        final hasBookingData = services.isNotEmpty && staffMembers.isNotEmpty;
        final selectedService = hasBookingData
            ? services[_selectedServiceIndex.clamp(0, services.length - 1)]
            : null;
        final selectedProvider = hasBookingData
            ? staffMembers[_selectedProviderIndex.clamp(
                0,
                staffMembers.length - 1,
              )]
            : null;
        final selectedDate = dates.isNotEmpty
            ? dates[_selectedDateIndex.clamp(0, dates.length - 1)]
            : null;
        final selectedSlot = slots.isNotEmpty
            ? slots[_selectedSlotIndex.clamp(0, slots.length - 1)]
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: CustomScrollView(
            slivers: [
              _HeroAppBar(details: details, onBackTap: () => context.pop()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 128.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Choose your staff',
                        subtitle:
                            'Select the expert first to see their schedule',
                      ),
                      SizedBox(height: 10.h),
                      if (staffMembers.isEmpty)
                        _UnavailableCard(
                          message: 'No staff available for this salon yet.',
                        )
                      else
                        SizedBox(
                          height: 146.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: staffMembers.length,
                            separatorBuilder: (_, _) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final staff = staffMembers[index];
                              return _StaffCard(
                                staff: staff,
                                fallbackAsset:
                                    _staffFallbackImages[index %
                                        _staffFallbackImages.length],
                                isSelected: index == _selectedProviderIndex,
                                onTap: () => setState(() {
                                  _selectedProviderIndex = index;
                                }),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 28.h),
                      _SectionHeader(
                        title: 'Choose a service',
                        subtitle:
                            'Pick a service offered by your selected staff',
                      ),
                      SizedBox(height: 10.h),
                      if (services.isEmpty)
                        _UnavailableCard(
                          message: 'No services available for booking yet.',
                        )
                      else
                        SizedBox(
                          height: 152.h,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth = (constraints.maxWidth * 0.36)
                                  .clamp(132.0, 148.0);
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: services.length,
                                separatorBuilder: (_, _) =>
                                    SizedBox(width: 10.w),
                                itemBuilder: (context, index) {
                                  final service = services[index];
                                  return _ServiceCard(
                                    width: cardWidth,
                                    service: service,
                                    fallbackAsset:
                                        _serviceFallbackImages[index %
                                            _serviceFallbackImages.length],
                                    isSelected: index == _selectedServiceIndex,
                                    onTap: () => setState(() {
                                      _selectedServiceIndex = index;
                                    }),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 28.h),
                      _SectionHeader(
                        title: 'Choose a date',
                        subtitle: selectedProvider == null
                            ? 'Select a staff member to continue'
                            : 'Available dates for ${selectedProvider.name.split(' ').first}',
                      ),
                      SizedBox(height: 10.h),
                      if (dates.isEmpty)
                        _UnavailableCard(
                          message: 'No booking dates returned for this salon.',
                        )
                      else
                        SizedBox(
                          height: 98.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dates.length,
                            separatorBuilder: (_, _) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final date = dates[index];
                              return _DateChip(
                                date: date,
                                isSelected: index == _selectedDateIndex,
                                onTap: date.isClosed
                                    ? null
                                    : () => setState(() {
                                        _selectedDateIndex = index;
                                        _selectedSlotIndex = 0;
                                      }),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 28.h),
                      _SectionHeader(
                        title: 'Choose a slot',
                        subtitle: selectedProvider == null
                            ? 'Available slots'
                            : 'Available slots for ${selectedProvider.name.split(' ').first}',
                      ),
                      SizedBox(height: 10.h),
                      if (slots.isEmpty)
                        _UnavailableCard(
                          message: 'No slots returned for the selected date.',
                        )
                      else
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: slots.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12.h,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: 1.9,
                              ),
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            return _SlotChip(
                              slot: slot,
                              isSelected: index == _selectedSlotIndex,
                              onTap: () => setState(() {
                                _selectedSlotIndex = index;
                              }),
                            );
                          },
                        ),
                      SizedBox(height: 28.h),
                      if (selectedService != null &&
                          selectedProvider != null &&
                          selectedDate != null &&
                          selectedSlot != null)
                        _InfoPanel(
                          service: selectedService,
                          provider: selectedProvider,
                          date: selectedDate,
                          slot: selectedSlot,
                        )
                      else
                        _UnavailableCard(
                          message:
                              'Booking becomes available once services and staff are returned by the API.',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BookingBottomBar(
            service: selectedService,
            provider: selectedProvider,
            date: selectedDate,
            slot: selectedSlot,
            isSubmitting: state.isSubmitting,
            onBookTap:
                hasBookingData &&
                    selectedDate != null &&
                    selectedSlot != null &&
                    !state.isSubmitting
                ? () => _bookAppointment(
                    details: details,
                    service: selectedService!,
                    provider: selectedProvider!,
                    date: selectedDate,
                    slot: selectedSlot,
                  )
                : null,
          ),
        );
      },
    );
  }

  void _reloadDetails() {
    final salonId = int.tryParse(widget.saloonId);
    if (salonId == null) return;
    context.read<SalonBookingBloc>().add(SalonBookingDetailsRequested(salonId));
  }

  void _bookAppointment({
    required SalonBookingDetails details,
    required SalonBookingService service,
    required SalonStaffMember provider,
    required SalonBookingDate date,
    required SalonBookingSlot slot,
  }) {
    context.read<SalonBookingBloc>().add(
      SalonAppointmentRequested(
        AppointmentBookingRequest(
          salonId: details.id,
          serviceId: service.id,
          staffId: provider.id,
          slotStart: slot.start,
        ),
      ),
    );
  }

  int _resolveSelectedStaffIndex(
    List<SalonStaffMember> staffMembers,
    int? selectedStaffId,
  ) {
    if (staffMembers.isEmpty) return 0;
    if (selectedStaffId == null) {
      return _selectedProviderIndex.clamp(0, staffMembers.length - 1);
    }

    final index = staffMembers.indexWhere(
      (staff) => staff.id == selectedStaffId,
    );
    if (index == -1) {
      return _selectedProviderIndex.clamp(0, staffMembers.length - 1);
    }
    return index;
  }

  int _resolveSelectedDateIndex(
    List<SalonBookingDate> dates,
    String? selectedDate,
  ) {
    if (dates.isEmpty) return 0;
    if (selectedDate == null || selectedDate.isEmpty) {
      return _selectedDateIndex.clamp(0, dates.length - 1);
    }

    final index = dates.indexWhere((date) => date.date == selectedDate);
    if (index == -1) {
      return _selectedDateIndex.clamp(0, dates.length - 1);
    }
    return index;
  }
}

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.details, required this.onBackTap});

  final SalonBookingDetails details;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final location = [details.address, details.city, details.state]
        .whereType<String>()
        .where((segment) => segment.trim().isNotEmpty)
        .join(', ');

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 320.h,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leadingWidth: 64.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: _CircleActionButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBackTap,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Row(
            children: [
              _CircleActionButton(
                icon: Icons.favorite_border_rounded,
                onTap: () {},
              ),
              SizedBox(width: 8.w),
              _CircleActionButton(icon: Icons.ios_share_rounded, onTap: () {}),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _RemoteOrAssetImage(
              imageUrl: details.image,
              fallbackAsset: _heroFallbackImage,
              fit: BoxFit.cover,
              placeholderIcon: Icons.storefront_rounded,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.02),
                    const Color(0xFFF4F7FB),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 26.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      (details.status ?? 'Available').toUpperCase(),
                      style: context.typography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    details.name,
                    style: context.typography.pageTitle.copyWith(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 17.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            location,
                            style: context.typography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.typography.pageTitleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: context.typography.body.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.width,
    required this.service,
    required this.fallbackAsset,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final SalonBookingService service;
  final String fallbackAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE6EBF3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF0F172A,
              ).withValues(alpha: isSelected ? 0.09 : 0.04),
              blurRadius: isSelected ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: 42.w,
                    height: 42.w,
                    child: _RemoteOrAssetImage(
                      imageUrl: service.image,
                      fallbackAsset: fallbackAsset,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.design_services_rounded,
                    ),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.bodySmall.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _serviceMeta(service),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.caption.copyWith(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _serviceMeta(SalonBookingService service) {
    final parts = <String>[];
    if (service.durationMinutes != null) {
      parts.add('${service.durationMinutes} min');
    }
    if (service.price != null) {
      parts.add('Rs ${service.price!.round()}');
    }
    return parts.isEmpty ? 'Service available' : parts.join('  •  ');
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.fallbackAsset,
    required this.isSelected,
    required this.onTap,
  });

  final SalonStaffMember staff;
  final String fallbackAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 136.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE7ECF3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF0F172A,
              ).withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 40.r,
                    height: 40.r,
                    child: _RemoteOrAssetImage(
                      imageUrl: staff.image,
                      fallbackAsset: fallbackAsset,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.person_rounded,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    staff.rating?.toStringAsFixed(1) ?? '--',
                    style: context.typography.caption.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              staff.name,
              style: context.typography.bodySmall.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              staff.role ?? 'Staff member',
              style: context.typography.bodySmall.copyWith(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FA),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    staff.experience ?? 'Available',
                    style: context.typography.caption.copyWith(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5.sp,
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

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final SalonBookingDate date;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 82.w,
        decoration: BoxDecoration(
          color: date.isClosed
              ? const Color(0xFFE9EDF4)
              : isSelected
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: date.isClosed
                ? const Color(0xFFD9DEE8)
                : isSelected
                ? AppColors.primary
                : const Color(0xFFE6EBF3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF0F172A,
              ).withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.label,
              style: context.typography.caption.copyWith(
                color: date.isClosed
                    ? const Color(0xFF98A3B3)
                    : isSelected
                    ? Colors.white
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              date.dayNumber,
              style: context.typography.pageTitleSmall.copyWith(
                color: date.isClosed
                    ? const Color(0xFF98A3B3)
                    : isSelected
                    ? Colors.white
                    : AppColors.lightText,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              date.month,
              style: context.typography.caption.copyWith(
                color: date.isClosed
                    ? const Color(0xFF98A3B3)
                    : isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final SalonBookingSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFD9E7FF),
          borderRadius: BorderRadius.circular(18.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          slot.label,
          textAlign: TextAlign.center,
          style: context.typography.body.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.service,
    required this.provider,
    required this.date,
    required this.slot,
  });

  final SalonBookingService service;
  final SalonStaffMember provider;
  final SalonBookingDate date;
  final SalonBookingSlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF121826), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking preview',
            style: context.typography.pageTitleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              service.price == null
                  ? 'Estimated total: To be confirmed'
                  : 'Estimated total: Rs ${service.price!.round()}',
              style: context.typography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          _SummaryRow(
            icon: Icons.design_services_rounded,
            title: service.name,
            subtitle: service.durationMinutes == null
                ? 'Service available'
                : '${service.durationMinutes} min service',
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            icon: Icons.person_rounded,
            title: provider.name,
            subtitle: provider.role ?? 'Staff member',
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            icon: Icons.event_rounded,
            title: date.label,
            subtitle: slot.label,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.typography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: context.typography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({
    required this.service,
    required this.provider,
    required this.date,
    required this.slot,
    required this.isSubmitting,
    required this.onBookTap,
  });

  final SalonBookingService? service;
  final SalonStaffMember? provider;
  final SalonBookingDate? date;
  final SalonBookingSlot? slot;
  final bool isSubmitting;
  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    final priceText = service?.price == null
        ? 'Price on request'
        : 'Rs ${service!.price!.round()}';
    final summaryText = provider == null
        ? 'Select staff and service to continue'
        : (date == null || slot == null)
        ? 'Select date and slot to continue'
        : '${provider!.name}  |  ${date!.label}, ${slot!.label}';

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceText,
                    style: context.typography.pageTitleMedium.copyWith(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    summaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.caption.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: onBookTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Book appointment',
                        style: context.typography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(icon, color: AppColors.lightText, size: 20.sp),
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE6EBF3)),
      ),
      child: Text(
        message,
        style: context.typography.body.copyWith(
          color: AppColors.lightTextSecondary,
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
  });

  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return Image.asset(
        fallbackAsset,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => _placeholder(),
      errorWidget: (context, url, error) => Image.asset(
        fallbackAsset,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE7EDF4),
      alignment: Alignment.center,
      child: Icon(placeholderIcon, color: const Color(0xFF97A3B3)),
    );
  }
}
