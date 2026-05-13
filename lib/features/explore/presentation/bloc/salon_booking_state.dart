part of 'salon_booking_bloc.dart';

enum SalonBookingStatus { initial, loading, success, failure }

enum AppointmentBookingStatus { initial, success, failure }

class SalonBookingState extends Equatable {
  const SalonBookingState({
    this.status = SalonBookingStatus.initial,
    this.bookingStatus = AppointmentBookingStatus.initial,
    this.details,
    this.isSubmitting = false,
    this.message,
    this.bookingMessage,
  });

  final SalonBookingStatus status;
  final AppointmentBookingStatus bookingStatus;
  final SalonBookingDetails? details;
  final bool isSubmitting;
  final String? message;
  final String? bookingMessage;

  SalonBookingState copyWith({
    SalonBookingStatus? status,
    AppointmentBookingStatus? bookingStatus,
    SalonBookingDetails? details,
    bool? isSubmitting,
    String? message,
    String? bookingMessage,
    bool clearMessage = false,
    bool clearBookingFeedback = false,
  }) {
    return SalonBookingState(
      status: status ?? this.status,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      details: details ?? this.details,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
      bookingMessage: clearBookingFeedback
          ? null
          : (bookingMessage ?? this.bookingMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookingStatus,
    details,
    isSubmitting,
    message,
    bookingMessage,
  ];
}
