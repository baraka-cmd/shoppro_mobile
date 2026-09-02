// ============================================
// IMPLÉMENTATION DU REPOSITORY DES PRODUITS
// ============================================
// Cette classe implémente l'interface ProductRepository.
// Gère les appels API, le cache local et l'historique.
// ============================================

import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../models/product_image_model.dart';
import '../sources/product_api.dart';
import '../sources/category_api.dart';
import '../sources/brand_api.dart';

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
  // PRODUITS - LISTE & PAGINATION
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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur getProducts: $e');
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
        if (pagination != null) {
          return _parseBool(pagination['has_more']);
        }
        final data = response['data'] as List<dynamic>? ?? [];
        return data.isNotEmpty;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ Erreur hasMoreProducts: $e');
      return false;
    }
  }

  @override
  Future<Product> getProductDetails(int id) async {
    try {
      return await _productApi.getProductDetails(id);
    } catch (e) {
      debugPrint('❌ Erreur getProductDetails($id): $e');
      rethrow;
    }
  }

  // ============================================
  // PRODUITS - SECTIONS
  // ============================================

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      return await _productApi.getFeaturedProducts(limit: limit);
    } catch (e) {
      debugPrint('❌ Erreur getFeaturedProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      return await _productApi.getPopularProducts(limit: limit);
    } catch (e) {
      debugPrint('❌ Erreur getPopularProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getRecentProducts({int limit = 10}) async {
    try {
      return await _productApi.getRecentProducts(limit: limit);
    } catch (e) {
      debugPrint('❌ Erreur getRecentProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getOnSaleProducts({int limit = 10}) async {
    try {
      return await _productApi.getOnSaleProducts(limit: limit);
    } catch (e) {
      debugPrint('❌ Erreur getOnSaleProducts: $e');
      rethrow;
    }
  }

  // ============================================
  // PRODUITS - RECHERCHE & FILTRES
  // ============================================

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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur searchProducts: $e');
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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur filterProducts: $e');
      rethrow;
    }
  }

  // ============================================
  // PRODUITS - RELATIONS
  // ============================================

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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur getProductsByCategory: $e');
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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur getProductsByBrand: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getSimilarProducts(int productId) async {
    try {
      return await _productApi.getSimilarProducts(productId);
    } catch (e) {
      debugPrint('❌ Erreur getSimilarProducts($productId): $e');
      rethrow;
    }
  }

  // ============================================
  // CATÉGORIES
  // ============================================

  @override
  Future<List<Category>> getCategories({bool includeInactive = false}) async {
    try {
      return await _categoryApi.getCategories();
    } catch (e) {
      debugPrint('❌ Erreur getCategories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getRootCategories() async {
    try {
      final categories = await _categoryApi.getCategories();
      return categories.where((category) => category.isRoot).toList();
    } catch (e) {
      debugPrint('❌ Erreur getRootCategories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getFeaturedCategories() async {
    try {
      final categories = await _categoryApi.getCategories();
      return categories.where((category) => category.isFeatured).toList();
    } catch (e) {
      debugPrint('❌ Erreur getFeaturedCategories: $e');
      rethrow;
    }
  }

  @override
  Future<Category> getCategoryDetails(int id) async {
    try {
      return await _categoryApi.getCategoryDetails(id);
    } catch (e) {
      debugPrint('❌ Erreur getCategoryDetails($id): $e');
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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur getCategoryProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getSubcategories(int categoryId) async {
    try {
      final category = await _categoryApi.getCategoryDetails(categoryId);
      return category.children;
    } catch (e) {
      debugPrint('❌ Erreur getSubcategories($categoryId): $e');
      rethrow;
    }
  }

  // ============================================
  // MARQUES
  // ============================================

  @override
  Future<List<Brand>> getBrands({bool includeInactive = false}) async {
    try {
      return await _brandApi.getBrands();
    } catch (e) {
      debugPrint('❌ Erreur getBrands: $e');
      rethrow;
    }
  }

  @override
  Future<List<Brand>> getFeaturedBrands() async {
    try {
      final brands = await _brandApi.getBrands();
      return brands.where((brand) => brand.isFeatured).toList();
    } catch (e) {
      debugPrint('❌ Erreur getFeaturedBrands: $e');
      rethrow;
    }
  }

  @override
  Future<Brand> getBrandDetails(int id) async {
    try {
      return await _brandApi.getBrandDetails(id);
    } catch (e) {
      debugPrint('❌ Erreur getBrandDetails($id): $e');
      rethrow;
    }
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

      return _parseProductList(response);
    } catch (e) {
      debugPrint('❌ Erreur getBrandProducts: $e');
      rethrow;
    }
  }

  // ============================================
  // IMAGES & GALERIE
  // ============================================

  @override
  Future<List<ProductImage>> getProductImages(int productId) async {
    try {
      final product = await _productApi.getProductDetails(productId);
      return product.images;
    } catch (e) {
      debugPrint('❌ Erreur getProductImages($productId): $e');
      rethrow;
    }
  }

  @override
  Future<ProductImage?> getPrimaryImage(int productId) async {
    try {
      final images = await getProductImages(productId);
      return images.where((image) => image.isPrimary).firstOrNull;
    } catch (e) {
      debugPrint('❌ Erreur getPrimaryImage($productId): $e');
      return null;
    }
  }

  // ============================================
  // AVIS
  // ============================================

  @override
  Future<List<dynamic>> getProductReviews({
    required int productId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await _productApi.getProductReviews(
        productId: productId,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      debugPrint('❌ Erreur getProductReviews($productId): $e');
      rethrow;
    }
  }

  @override
  Future<double> getProductAverageRating(int productId) async {
    try {
      return await _productApi.getProductAverageRating(productId);
    } catch (e) {
      debugPrint('❌ Erreur getProductAverageRating($productId): $e');
      return 0;
    }
  }

  // ============================================
  // PRODUITS RÉCEMMENT CONSULTÉS
  // ============================================

  @override
  Future<List<Product>> getRecentlyViewedProducts({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('recently_viewed_products') ?? [];

      final products = <Product>[];
      for (final idStr in ids.take(limit)) {
        final id = int.tryParse(idStr);
        if (id != null) {
          try {
            final product = await getProductDetails(id);
            products.add(product);
          } catch (e) {
            debugPrint('⚠️ Produit récent $id introuvable: $e');
          }
        }
      }
      return products;
    } catch (e) {
      debugPrint('❌ Erreur getRecentlyViewedProducts: $e');
      return [];
    }
  }

  @override
  Future<void> addToRecentlyViewed(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('recently_viewed_products') ?? [];

      ids.removeWhere((id) => id == productId.toString());
      ids.insert(0, productId.toString());
      if (ids.length > 10) ids.removeRange(10, ids.length);

      await prefs.setStringList('recently_viewed_products', ids);
    } catch (e) {
      debugPrint('❌ Erreur addToRecentlyViewed: $e');
    }
  }

  @override
  Future<void> clearRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recently_viewed_products');
    } catch (e) {
      debugPrint('❌ Erreur clearRecentlyViewed: $e');
    }
  }

  // ============================================
  // HISTORIQUE DE RECHERCHE
  // ============================================

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('search_history') ?? [];
  }

  Future<void> addToSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);
    if (history.length > 10) history.removeRange(10, history.length);
    await prefs.setStringList('search_history', history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parser une liste de produits depuis une réponse API
  List<Product> _parseProductList(Map<String, dynamic> response) {
    if (response['success'] == true) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}