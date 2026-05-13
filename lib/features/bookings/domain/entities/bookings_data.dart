import 'package:equatable/equatable.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/booking_item.dart';

class BookingsData extends Equatable {
  final List<BookingItem> items;

  const BookingsData({this.items = const []});

  @override
  List<Object?> get props => [items];
}
