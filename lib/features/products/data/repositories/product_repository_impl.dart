// Implémentation du repository des produits
// Cette classe implémente l'interface ProductRepository

import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../sources/product_api.dart';
import '../sources/category_api.dart';
import '../sources/brand_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApi _productApi;
  final CategoryApi _categoryApi;
  final BrandApi _brandApi;

  ProductRepositoryImpl({
    ProductApi? productApi,
    CategoryApi? categoryApi,
    BrandApi? brandApi,
  })  : _productApi = productApi ?? ProductApi(),
        _categoryApi = categoryApi ?? CategoryApi(),
        _brandApi = brandApi ?? BrandApi();

  // ============================================
  // PRODUITS
  // ============================================

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _productApi.getProducts(
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProductDetails(int id) async {
    try {
      return await _productApi.getProductDetails(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      return await _productApi.getFeaturedProducts(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      return await _productApi.getPopularProducts(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getRecentProducts({int limit = 10}) async {
    try {
      return await _productApi.getRecentProducts(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getOnSaleProducts({int limit = 10}) async {
    try {
      return await _productApi.getOnSaleProducts(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _productApi.searchProducts(
        query: query,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> filterProducts({
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
      final response = await _productApi.filterProducts(
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
        minRating: minRating,
        onSale: onSale,
        sortBy: sortBy,
        sortDirection: sortDirection,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _productApi.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByBrand({
    required int brandId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _productApi.getProductsByBrand(
        brandId: brandId,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getSimilarProducts(int productId) async {
    try {
      return await _productApi.getSimilarProducts(productId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasMoreProducts({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _productApi.getProducts(
        page: page + 1,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final pagination = response['pagination'] as Map<String, dynamic>?;
        return pagination?['has_more'] as bool? ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // CATÉGORIES
  // ============================================

  @override
  Future<List<Category>> getCategories() async {
    try {
      return await _categoryApi.getCategories();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Category> getCategoryDetails(int id) async {
    try {
      return await _categoryApi.getCategoryDetails(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getCategoryProducts({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _categoryApi.getCategoryProducts(
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // MARQUES
  // ============================================

  @override
  Future<List<Brand>> getBrands() async {
    try {
      return await _brandApi.getBrands();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Brand> getBrandDetails(int id) async {
    try {
      return await _brandApi.getBrandDetails(id);
    } catch (e) {
      rethrow;
    }
  }

  

@override
Future<List<String>> getSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('search_history') ?? [];
}

@override
Future<void> addToSearchHistory(String query) async {
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList('search_history') ?? [];
  history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
  history.insert(0, query);
  if (history.length > 10) history.removeRange(10, history.length);
  await prefs.setStringList('search_history', history);
}

@override
Future<void> clearSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('search_history');
}

  @override
  Future<List<Product>> getBrandProducts({
    required int brandId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _brandApi.getBrandProducts(
        brandId: brandId,
        page: page,
        perPage: perPage,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  
}