import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/datasources/product_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/data/services/favorites_notifier.dart';
import 'package:salon_booker_app/features/explore/domain/entities/category_list_item.dart';
import 'package:salon_booker_app/core/entities/product.dart';
import 'package:salon_booker_app/features/explore/domain/entities/product_details.dart';
import 'package:salon_booker_app/features/explore/domain/entities/products_page_data.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_params.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource productRemoteDataSource;
  final FavoritesNotifier favoritesNotifier;

  ProductRepositoryImpl(this.productRemoteDataSource, this.favoritesNotifier);

  @override
  ResultFuture<ProductsPageData> getProducts(GetProductsParams params) async {
    final result = await productRemoteDataSource.getProducts(params);
    return result.map((response) => ProductsPageData(
          products: response.products,
          categories: response.categories,
          colors: response.colors,
          materials: response.materials,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          total: response.total,
          perPage: response.perPage,
        ));
  }

  @override
  ResultFuture<List<CategoryListItem>> getCategories() async {
    final result = await productRemoteDataSource.getCategories();
    return result.map((categories) => categories);
  }

  @override
  ResultFuture<ProductDetails> getProductDetails(int productId) async {
    final result = await productRemoteDataSource.getProductDetails(productId);
    return result.map((details) => details);
  }

  @override
  ResultFuture<List<Product>> getFavorites() async {
    final result = await productRemoteDataSource.getFavorites();
    return result.map((products) => products);
  }

  @override
  ResultFuture<void> addToFavorites(int productId) async {
    final result = await productRemoteDataSource.addToFavorites(productId);
    result.fold(
      (_) {},
      (_) => favoritesNotifier.notifyFavoriteChanged(productId, true),
    );
    return result;
  }

  @override
  ResultFuture<void> removeFromFavorites(int productId) async {
    final result = await productRemoteDataSource.removeFromFavorites(productId);
    result.fold(
      (_) {},
      (_) => favoritesNotifier.notifyFavoriteChanged(productId, false),
    );
    return result;
  }
}
