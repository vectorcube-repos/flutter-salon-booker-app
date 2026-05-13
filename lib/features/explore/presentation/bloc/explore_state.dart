part of 'explore_bloc.dart';

enum ExploreStatus { initial, loading, success, failure }

class ExploreState extends Equatable {
  final ExploreStatus status;
  final ExploreDashboardData data;
  final String selectedServiceId;
  final bool isLoadingMore;
  final String? message;

  const ExploreState({
    this.status = ExploreStatus.initial,
    this.data = const ExploreDashboardData(),
    this.selectedServiceId = '',
    this.isLoadingMore = false,
    this.message,
  });

  ExploreState copyWith({
    ExploreStatus? status,
    ExploreDashboardData? data,
    String? selectedServiceId,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
  }) {
    return ExploreState(
      status: status ?? this.status,
      data: data ?? this.data,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    selectedServiceId,
    isLoadingMore,
    message,
  ];
}
