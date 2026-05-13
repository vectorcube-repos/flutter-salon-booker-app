import 'package:salon_booker_app/features/explore/domain/entities/category_list_item.dart';
import 'package:salon_booker_app/core/entities/product.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/domain/entities/product_details.dart';
import 'package:salon_booker_app/features/explore/domain/entities/products_page_data.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_params.dart';

abstract class ProductRepository {
  ResultFuture<ProductsPageData> getProducts(GetProductsParams params);
  ResultFuture<List<CategoryListItem>> getCategories();
  ResultFuture<ProductDetails> getProductDetails(int productId);
  ResultFuture<List<Product>> getFavorites();
  ResultFuture<void> addToFavorites(int productId);
  ResultFuture<void> removeFromFavorites(int productId);
}
