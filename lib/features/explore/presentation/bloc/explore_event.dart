part of 'explore_bloc.dart';

sealed class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

final class ExploreRequested extends ExploreEvent {
  final String? serviceId;
  final int page;
  final bool isInitialLoad;

  const ExploreRequested({
    this.serviceId,
    this.page = 1,
    this.isInitialLoad = false,
  });

  @override
  List<Object?> get props => [serviceId, page, isInitialLoad];
}

final class ExploreServiceSelected extends ExploreEvent {
  final String serviceId;

  const ExploreServiceSelected(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

final class ExploreNextPageRequested extends ExploreEvent {
  const ExploreNextPageRequested();
}
