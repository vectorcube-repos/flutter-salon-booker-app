import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/bookings/domain/entities/bookings_data.dart';
import 'package:salon_booker_app/features/bookings/domain/use_cases/get_bookings_use_case.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final GetBookingsUseCase getBookingsUseCase;

  BookingsBloc(this.getBookingsUseCase) : super(BookingsInitial()) {
    on<GetBookingsEvent>(_onGetBookings);
  }

  Future<void> _onGetBookings(
    GetBookingsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    final previousData = _extractDataFromState();
    emit(BookingsLoading(previousData: previousData));
    final result = await getBookingsUseCase();
    result.fold(
      (failure) => emit(
        BookingsLoadingFailure(
          message: failure.message ?? 'Failed to load bookings',
          previousData: previousData,
        ),
      ),
      (data) => emit(BookingsLoaded(data: data)),
    );
  }

  BookingsData _extractDataFromState() {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      return currentState.data;
    }
    if (currentState is BookingsLoading) {
      return currentState.previousData;
    }
    if (currentState is BookingsLoadingFailure) {
      return currentState.previousData;
    }
    return const BookingsData();
  }
}
