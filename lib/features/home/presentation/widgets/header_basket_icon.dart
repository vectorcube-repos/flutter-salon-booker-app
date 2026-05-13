import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/theme/app_colors.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';
import 'package:salon_booker_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:go_router/go_router.dart';

class HeaderBasketIcon extends StatelessWidget {
  const HeaderBasketIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingsBloc, BookingsState>(
      builder: (context, state) {
        final bookingsData = _resolveData(state);
        final count = bookingsData.items.length;

        return GestureDetector(
          onTap: () => context.pushNamed('bookings-preview'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_cart, size: 26.w, color: AppColors.lightText),
              if (count > 0)
                Positioned(
                  top: -4.h,
                  right: -6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: count > 99 ? 4.w : 5.w,
                      vertical: 2.h,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.w,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 219, 146, 146),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  BookingsData _resolveData(BookingsState state) {
    if (state is BookingsLoaded) return state.data;
    if (state is BookingsLoading) return state.previousData;
    if (state is BookingsLoadingFailure) return state.previousData;
    return const BookingsData();
  }
}
