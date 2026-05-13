import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/explore/domain/entities/appointment_booking_request.dart';
import 'package:salon_booker_app/features/explore/domain/entities/salon_booking_details.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/book_appointment_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_salon_booking_details_use_case.dart';

part 'salon_booking_event.dart';
part 'salon_booking_state.dart';

class SalonBookingBloc extends Bloc<SalonBookingEvent, SalonBookingState> {
  SalonBookingBloc(
    this._getSalonBookingDetailsUseCase,
    this._bookAppointmentUseCase,
  ) : super(const SalonBookingState()) {
    on<SalonBookingDetailsRequested>(_onDetailsRequested);
    on<SalonAppointmentRequested>(_onAppointmentRequested);
  }

  final GetSalonBookingDetailsUseCase _getSalonBookingDetailsUseCase;
  final BookAppointmentUseCase _bookAppointmentUseCase;

  Future<void> _onDetailsRequested(
    SalonBookingDetailsRequested event,
    Emitter<SalonBookingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SalonBookingStatus.loading,
        clearMessage: true,
        clearBookingFeedback: true,
      ),
    );

    final result = await _getSalonBookingDetailsUseCase(event.salonId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SalonBookingStatus.failure,
          message: failure.message ?? 'Failed to load salon details',
        ),
      ),
      (details) => emit(
        state.copyWith(
          status: SalonBookingStatus.success,
          details: details,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> _onAppointmentRequested(
    SalonAppointmentRequested event,
    Emitter<SalonBookingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearBookingFeedback: true));

    final result = await _bookAppointmentUseCase(event.request);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          bookingStatus: AppointmentBookingStatus.failure,
          bookingMessage:
              failure.message ??
              'Failed to book appointment. Please try again.',
        ),
      ),
      (response) => emit(
        state.copyWith(
          isSubmitting: false,
          bookingStatus: AppointmentBookingStatus.success,
          bookingMessage: response.message,
        ),
      ),
    );
  }
}
