import 'package:salon_booker_app/features/bookings/data/models/booking_item_model.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';

class BookingsDataModel extends BookingsData {
  const BookingsDataModel({super.items});

  factory BookingsDataModel.fromApiJson(Map<String, dynamic> json) {
    final itemsRaw = json['data'] is List ? json['data'] : json['items'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map>()
              .map(
                (item) => BookingItemModel.fromApiJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <BookingItemModel>[];

    return BookingsDataModel(items: items);
  }
}
