part of 'bookings_bloc.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

final class GetBookingsEvent extends BookingsEvent {
  const GetBookingsEvent();
}
