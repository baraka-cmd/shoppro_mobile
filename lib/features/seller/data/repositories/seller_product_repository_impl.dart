// ============================================
// REPOSITORY IMPL : SellerProductRepositoryImpl
// ============================================
// Implémentation du repository des produits vendeur.
//
// Stratégie API-first + cache local :
//   - Toutes les opérations passent par l'API
//   - Le cache local est utilisé UNIQUEMENT pour les catégories et marques
//     (afin d'éviter de recharger les dropdowns à chaque ouverture)
//
// Sécurité :
//   - Aucune donnée sensible n'est mise en cache
//   - Les tokens ne sont JAMAIS stockés ici
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

// Dart
import 'dart:convert';

// Domain
import '../../domain/entities/seller_product.dart';
import '../../domain/repositories/seller_product_repository.dart';

// Data
import '../sources/seller_product_api.dart';

import '../../../products/data/sources/category_api.dart';
import '../../../products/data/sources/brand_api.dart';
import '../../../products/data/models/category_model.dart';
import '../../../products/data/models/brand_model.dart';


class SellerProductRepositoryImpl implements SellerProductRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final SellerProductApi _api;

  SellerProductRepositoryImpl({SellerProductApi? api})
      : _api = api ?? SellerProductApi();

  // ============================================
  // CLÉS DE CACHE
  // ============================================

  static const String _cacheKeyCategories = 'seller_categories_cache_v1';
  static const String _cacheKeyBrands = 'seller_brands_cache_v1';

  /// Durée de validité du cache catégories/marques (1 heure).
  static const Duration _cacheValidity = Duration(hours: 1);

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<SellerProductsResult> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    String? status,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) async {
    try {
      return await _api.getProducts(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
        status: status,
        sortBy: sortBy,
        sortDir: sortDir,
      );
    } catch (e) {
      debugPrint('❌ Erreur getProducts: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> getProductById(int id) async {
    try {
      return await _api.getProductById(id);
    } catch (e) {
      debugPrint('❌ Erreur getProductById: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> previewProduct(int id) async {
    try {
      return await _api.previewProduct(id);
    } catch (e) {
      debugPrint('❌ Erreur previewProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // CRÉATION & MODIFICATION
  // ============================================

  @override
  Future<SellerProduct> createProduct(Map<String, dynamic> data) async {
    try {
      return await _api.createProduct(data);
    } catch (e) {
      debugPrint('❌ Erreur createProduct: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      return await _api.updateProduct(id, data);
    } catch (e) {
      debugPrint('❌ Erreur updateProduct: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _api.deleteProduct(id);
    } catch (e) {
      debugPrint('❌ Erreur deleteProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // PUBLICATION
  // ============================================

  @override
  Future<SellerProduct> publishProduct(int id) async {
    try {
      return await _api.publishProduct(id);
    } catch (e) {
      debugPrint('❌ Erreur publishProduct: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> unpublishProduct(int id) async {
    try {
      return await _api.unpublishProduct(id);
    } catch (e) {
      debugPrint('❌ Erreur unpublishProduct: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> duplicateProduct(int id) async {
    try {
      return await _api.duplicateProduct(id);
    } catch (e) {
      debugPrint('❌ Erreur duplicateProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // IMAGES
  // ============================================

  @override
  Future<SellerProduct> uploadImages(
    int productId,
    List<String> imagePaths,
  ) async {
    try {
      return await _api.uploadImages(productId, imagePaths);
    } catch (e) {
      debugPrint('❌ Erreur uploadImages: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> deleteImage(int productId, int imageId) async {
    try {
      return await _api.deleteImage(productId, imageId);
    } catch (e) {
      debugPrint('❌ Erreur deleteImage: $e');
      rethrow;
    }
  }

  @override
  Future<SellerProduct> reorderImages(
    int productId,
    List<int> imageIds,
  ) async {
    try {
      return await _api.reorderImages(productId, imageIds);
    } catch (e) {
      debugPrint('❌ Erreur reorderImages: $e');
      rethrow;
    }
  }

  // ============================================
  // CATÉGORIES & MARQUES (avec cache)
  // ============================================

  // ============================================
// CATÉGORIES & MARQUES (via APIs existantes)
// ============================================

@override
Future<List<SellerProductCategory>> getCategories() async {
  // 1. Essayer le cache
  final cached = await _loadCategoriesFromCache();
  // ⚠️ Si le cache existe ET n'est pas vide, l'utiliser
  if (cached != null && cached.isNotEmpty) {
    debugPrint('✅ Catégories depuis le cache (${cached.length})');
    return cached;
  }

  // 2. Cache miss ou vide → appeler l'API existante
  try {
    final categoryApi = CategoryApi();
    final rawCategories = await categoryApi.getCategories();

    final categories = rawCategories
        .map((c) => SellerProductCategory(
              id: c.id,
              name: c.name,
              slug: c.slug,
              image: c.image,
            ))
        .toList();

    debugPrint('✅ ${categories.length} catégories depuis l\'API');

    await _saveCategoriesToCache(categories);
    return categories;
  } catch (e) {
    debugPrint('❌ Erreur getCategories: $e');
    return [];
  }
}

@override
Future<List<SellerProductBrand>> getBrands() async {
  final cached = await _loadBrandsFromCache();
  if (cached != null && cached.isNotEmpty) {
    debugPrint('✅ Marques depuis le cache (${cached.length})');
    return cached;
  }

  try {
    final brandApi = BrandApi();
    final rawBrands = await brandApi.getBrands();

    final brands = rawBrands
        .map((b) => SellerProductBrand(
              id: b.id,
              name: b.name,
              slug: b.slug,
              logo: b.logo,
            ))
        .toList();

    debugPrint('✅ ${brands.length} marques depuis l\'API');

    await _saveBrandsToCache(brands);
    return brands;
  } catch (e) {
    debugPrint('❌ Erreur getBrands: $e');
    return [];
  }
}


  // ============================================
  // CACHE : Catégories
  // ============================================

  Future<void> _saveCategoriesToCache(
    List<SellerProductCategory> categories,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = categories
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'slug': c.slug,
                'image': c.image,
              })
          .toList();

      await prefs.setString(_cacheKeyCategories, jsonEncode(data));
      await prefs.setInt(
        '${_cacheKeyCategories}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('⚠️ Impossible de sauvegarder les catégories: $e');
    }
  }

  Future<List<SellerProductCategory>?> _loadCategoriesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKeyCategories);
      final timestamp = prefs.getInt('${_cacheKeyCategories}_timestamp');

      if (jsonString == null || timestamp == null) return null;

      // Vérifier la fraîcheur
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheDate) > _cacheValidity) {
        return null;
      }

      final json = jsonDecode(jsonString) as List;
      return json
          .whereType<Map>()
          .map((e) => SellerProductCategory(
                id: (e['id'] as num?)?.toInt() ?? 0,
                name: e['name']?.toString() ?? '',
                slug: e['slug']?.toString() ?? '',
                image: e['image']?.toString(),
              ))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur chargement cache catégories: $e');
      return null;
    }
  }

  // ============================================
  // CACHE : Marques
  // ============================================

  Future<void> _saveBrandsToCache(
    List<SellerProductBrand> brands,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = brands
          .map((b) => {
                'id': b.id,
                'name': b.name,
                'slug': b.slug,
                'logo': b.logo,
              })
          .toList();

      await prefs.setString(_cacheKeyBrands, jsonEncode(data));
      await prefs.setInt(
        '${_cacheKeyBrands}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('⚠️ Impossible de sauvegarder les marques: $e');
    }
  }

  Future<List<SellerProductBrand>?> _loadBrandsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKeyBrands);
      final timestamp = prefs.getInt('${_cacheKeyBrands}_timestamp');

      if (jsonString == null || timestamp == null) return null;

      // Vérifier la fraîcheur
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheDate) > _cacheValidity) {
        return null;
      }

      final json = jsonDecode(jsonString) as List;
      return json
          .whereType<Map>()
          .map((e) => SellerProductBrand(
                id: (e['id'] as num?)?.toInt() ?? 0,
                name: e['name']?.toString() ?? '',
                slug: e['slug']?.toString() ?? '',
                logo: e['logo']?.toString(),
              ))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur chargement cache marques: $e');
      return null;
    }
  }

  // ============================================
  // CLEAR CACHE
  // ============================================

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyCategories);
      await prefs.remove('${_cacheKeyCategories}_timestamp');
      await prefs.remove(_cacheKeyBrands);
      await prefs.remove('${_cacheKeyBrands}_timestamp');
      debugPrint('🗑️ Cache produits vendeur effacé');
    } catch (e) {
      debugPrint('⚠️ Erreur clearCache: $e');
    }
  }
}