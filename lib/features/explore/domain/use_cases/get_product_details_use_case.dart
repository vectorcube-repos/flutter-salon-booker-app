import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/product_details.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository productRepository;

  GetProductDetailsUseCase(this.productRepository);

  ResultFuture<ProductDetails> call(int productId) async {
    return productRepository.getProductDetails(productId);
  }
}
