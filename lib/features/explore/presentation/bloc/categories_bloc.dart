import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category_list_item.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_categories_use_case.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoriesBloc(this.getCategoriesUseCase) : super(CategoriesInitial()) {
    on<GetCategoriesEvent>(_onGetCategories);
  }

  Future<void> _onGetCategories(
    GetCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => emit(
        CategoriesFailure(
          message: failure.message ?? 'Failed to load categories',
        ),
      ),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }
}
