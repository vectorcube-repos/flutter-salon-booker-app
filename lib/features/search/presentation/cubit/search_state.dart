part of 'search_cubit.dart';

enum SearchStatus { initial, searching, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const SearchResultData(),
    this.message,
  });

  final SearchStatus status;
  final String query;
  final SearchResultData results;
  final String? message;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get hasResults =>
      results.services.isNotEmpty || results.salons.isNotEmpty;
  bool get showEmptyState =>
      status == SearchStatus.success && query.trim().length >= 2 && !hasResults;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchResultData? results,
    String? message,
    bool clearMessage = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, query, results, message];
}
