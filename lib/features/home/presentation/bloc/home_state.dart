part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final HomeDashboardData data;

  const HomeLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

final class HomeLoadingFailure extends HomeState {
  final String message;

  const HomeLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
