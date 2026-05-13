import 'package:salon_booker_app/core/usecases/usecase.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/products_page_data.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_params.dart';

class GetProductsUseCase
    implements UseCase<ProductsPageData, GetProductsParams> {
  final ProductRepository productRepository;

  GetProductsUseCase(this.productRepository);

  @override
  ResultFuture<ProductsPageData> call(GetProductsParams params) async {
    return await productRepository.getProducts(params);
  }
}

