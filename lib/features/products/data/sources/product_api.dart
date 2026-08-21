// Service API des produits
// Contient toutes les requêtes HTTP vers le backend Laravel

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste paginée des produits
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'un produit
  Future<ProductModel> getProductDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.productDetails}$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data']);
      }

      throw Exception('Produit introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits en vedette
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.featuredProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits populaires
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits récents
  Future<List<ProductModel>> getRecentProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.recentProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits en promotion
  Future<List<ProductModel>> getOnSaleProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.onSaleProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Rechercher des produits
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchProducts,
        queryParameters: {
          'q': query,
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Filtrer les produits
  Future<Map<String, dynamic>> filterProducts({
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    double? minRating,
    bool? onSale,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
      };

      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (brandId != null) queryParameters['brand_id'] = brandId;
      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;
      if (inStock != null) queryParameters['in_stock'] = inStock.toString();
      if (minRating != null) queryParameters['min_rating'] = minRating;
      if (onSale != null) queryParameters['on_sale'] = onSale.toString();

      final response = await _dio.get(
        ApiConstants.filterProducts,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits par catégorie
  Future<Map<String, dynamic>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categoryProducts}$categoryId',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits par marque
  Future<Map<String, dynamic>> getProductsByBrand({
    required int brandId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.brandProducts}$brandId',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits similaires
  Future<List<ProductModel>> getSimilarProducts(int productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.productDetails}$productId/similar',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gérer les erreurs Dio
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Délai de connexion dépassé. Veuillez réessayer.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}