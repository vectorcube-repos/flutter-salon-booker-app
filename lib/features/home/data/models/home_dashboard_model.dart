import 'package:salon_booker_app/features/home/domain/entities/home_dashboard_data.dart';
import 'package:salon_booker_app/features/home/data/models/home_latest_booking_model.dart';
import 'package:salon_booker_app/features/home/data/models/home_salon_model.dart';
import 'package:salon_booker_app/features/home/data/models/home_service_model.dart';

class HomeDashboardModel extends HomeDashboardData {
  const HomeDashboardModel({
    super.services,
    super.salons,
    super.mostBookedServices,
    super.latestBooking,
  });

  factory HomeDashboardModel.fromApiJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<T> parseList<T>(Object? raw, T Function(Map<String, dynamic>) parser) {
      if (raw is! List) return const [];
      return raw.whereType<Map<String, dynamic>>().map(parser).toList();
    }

    return HomeDashboardModel(
      services: parseList(payload['services'], HomeServiceModel.fromApiJson),
      salons: parseList(payload['salons'], HomeSalonModel.fromApiJson),
      mostBookedServices: parseList(
        payload['most_booked_services'],
        HomeServiceModel.fromApiJson,
      ),
      latestBooking: payload['latest_booking'] is Map<String, dynamic>
          ? HomeLatestBookingModel.fromApiJson(
              payload['latest_booking'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
