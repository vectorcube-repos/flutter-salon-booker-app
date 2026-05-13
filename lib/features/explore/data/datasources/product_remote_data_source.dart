import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/utils/typedef.dart';
import 'package:salon_booker_app/features/explore/data/models/category_list_item_model.dart';
import 'package:salon_booker_app/features/explore/data/models/product_details_model.dart';
import 'package:salon_booker_app/features/explore/data/models/product_model.dart';
import 'package:salon_booker_app/features/explore/data/models/products_response_model.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_params.dart';

abstract class ProductRemoteDataSource {
  ResultFuture<ProductsResponseModel> getProducts(GetProductsParams params);
  ResultFuture<List<CategoryListItemModel>> getCategories();
  ResultFuture<ProductDetailsModel> getProductDetails(int productId);
  ResultFuture<List<ProductModel>> getFavorites();
  ResultFuture<void> addToFavorites(int productId);
  ResultFuture<void> removeFromFavorites(int productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  ResultFuture<ProductsResponseModel> getProducts(GetProductsParams params) {
    return _dioClient.get<ProductsResponseModel>(
      '/products',
      queryParameters: {
        'page': params.page,
        if (params.categoryId.isNotEmpty) 'category_id': params.categoryId,
        if (params.materialId.isNotEmpty) 'material_id': params.materialId,
        if (params.colorId.isNotEmpty) 'color_id': params.colorId,
        if (params.sortBy.isNotEmpty) 'sort_by': params.sortBy,
        'min_price': params.minPrice.round(),
        'max_price': params.maxPrice.round(),
        if (params.search.isNotEmpty) 'search': params.search,
        if (params.isInitialLoad) 'initial': 1,
      },
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object response, got: ${data.runtimeType}');
        }
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return ProductsResponseModel.fromApiJson(payload);
      },
    );
  }

  @override
  ResultFuture<List<CategoryListItemModel>> getCategories() {
    return _dioClient.get<List<CategoryListItemModel>>(
      '/categories',
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object response, got: ${data.runtimeType}');
        }

        final outerData = data['data'];
        final categoriesData = outerData is Map<String, dynamic>
            ? outerData['categories']
            : ((data['categories'] is Map<String, dynamic>)
                  ? (data['categories'] as Map<String, dynamic>)['data']
                  : null);
        if (categoriesData is! List) {
          return <CategoryListItemModel>[];
        }

        return categoriesData
            .map((e) => CategoryListItemModel.fromApiJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  ResultFuture<ProductDetailsModel> getProductDetails(int productId) {
    return _dioClient.get<ProductDetailsModel>(
      '/salons/$productId',
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException(
              'Expected object response, got: ${data.runtimeType}');
        }

        final payload = data['data'];
        if (payload is! Map<String, dynamic>) {
          throw const FormatException('Expected "data" object in response');
        }

        final productData = payload['product'];
        if (productData is! Map<String, dynamic>) {
          throw const FormatException('Expected "product" object in response');
        }

        return ProductDetailsModel.fromApiJson(productData);
      },
    );
  }

  @override
  ResultFuture<List<ProductModel>> getFavorites() {
    return _dioClient.get<List<ProductModel>>(
      '/favorites',
      parser: (data) {
        if (data is! Map<String, dynamic>) return <ProductModel>[];
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;

        final favoritesRaw = payload['favorites'];
        final productsRaw = payload['products'];
        final rawList = favoritesRaw is List
            ? favoritesRaw
            : favoritesRaw is Map<String, dynamic> && favoritesRaw['data'] is List
                ? favoritesRaw['data'] as List
                : productsRaw is List
                    ? productsRaw
                    : productsRaw is Map<String, dynamic> && productsRaw['data'] is List
                        ? productsRaw['data'] as List
                        : const <dynamic>[];

        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) {
              final productData = item['product'];
              final source = productData is Map<String, dynamic> ? productData : item;
              return ProductModel.fromApiJson({
                ...source,
                'is_favorite': true,
              });
            })
            .toList();
      },
    );
  }

  @override
  ResultFuture<void> addToFavorites(int productId) {
    return _dioClient.post<void>(
      '/favorites',
      data: {'product_id': productId},
      parser: (_) {},
    );
  }

  @override
  ResultFuture<void> removeFromFavorites(int productId) {
    return _dioClient.delete<void>(
      '/favorites/$productId',
      parser: (_) {},
    );
  }
}
