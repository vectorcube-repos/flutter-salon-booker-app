import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/search/domain/entities/search_result_data.dart';
import 'package:salon_booker_app/features/search/domain/use_cases/search_catalog_use_case.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchCatalogUseCase) : super(const SearchState());

  final SearchCatalogUseCase _searchCatalogUseCase;
  int _searchRequestId = 0;
  Timer? _debounce;

  void onQueryChanged(String rawQuery) {
    final query = rawQuery.trimLeft();
    emit(
      state.copyWith(
        query: query,
        status: query.trim().length < 2 ? SearchStatus.initial : state.status,
        clearMessage: true,
        results: query.trim().length < 2
            ? const SearchResultData()
            : state.results,
      ),
    );

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (isClosed) return;
      search(query);
    });
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < 2) {
      emit(SearchState(status: SearchStatus.initial, query: query));
      return;
    }

    final requestId = ++_searchRequestId;
    emit(
      state.copyWith(
        status: SearchStatus.searching,
        query: query,
        clearMessage: true,
      ),
    );

    final result = await _searchCatalogUseCase(query);
    if (requestId != _searchRequestId || isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          query: query,
          results: const SearchResultData(),
          message: failure.message ?? 'Failed to search right now',
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: SearchStatus.success,
          query: query,
          results: data,
          message: data.isEmpty ? 'No results found' : null,
        ),
      ),
    );
  }

  void clear() {
    _debounce?.cancel();
    _searchRequestId++;
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
