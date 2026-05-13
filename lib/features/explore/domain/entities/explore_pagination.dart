import 'package:equatable/equatable.dart';

class ExplorePagination extends Equatable {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;

  const ExplorePagination({
    this.total = 0,
    this.perPage = 0,
    this.currentPage = 1,
    this.lastPage = 1,
    this.from,
    this.to,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [total, perPage, currentPage, lastPage, from, to];
}
