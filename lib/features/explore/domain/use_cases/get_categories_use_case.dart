import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category_list_item.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository productRepository;

  GetCategoriesUseCase(this.productRepository);

  ResultFuture<List<CategoryListItem>> call() async {
    return productRepository.getCategories();
  }
}
