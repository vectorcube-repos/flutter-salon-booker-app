part of 'bookings_bloc.dart';

sealed class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

final class BookingsInitial extends BookingsState {}

final class BookingsLoading extends BookingsState {
  final BookingsData previousData;

  const BookingsLoading({this.previousData = const BookingsData()});

  @override
  List<Object?> get props => [previousData];
}

final class BookingsLoaded extends BookingsState {
  final BookingsData data;

  const BookingsLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

final class BookingsLoadingFailure extends BookingsState {
  final String message;
  final BookingsData previousData;

  const BookingsLoadingFailure({
    required this.message,
    this.previousData = const BookingsData(),
  });

  @override
  List<Object?> get props => [message, previousData];
}
