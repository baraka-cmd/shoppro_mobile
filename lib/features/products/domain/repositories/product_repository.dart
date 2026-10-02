// ============================================
// INTERFACE DU REPOSITORY DES PRODUITS
// ============================================
// Définit le contrat que le repository doit respecter.
// Inclut la gestion du cache, de l'offline et
// des avis pour une expérience e-commerce complète.
// ============================================

import '../entities/product.dart';
import '../entities/category.dart';
import '../entities/brand.dart';
import '../entities/product_image.dart';

abstract class ProductRepository {
  // ============================================
  // PRODUITS - LISTE & PAGINATION
  // ============================================

  /// Récupérer la liste paginée des produits
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 15,
  });

  /// Vérifier si plus de produits sont disponibles (pagination)
  Future<bool> hasMoreProducts({
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer les détails d'un produit
  Future<Product> getProductDetails(int id);

  // ============================================
  // PRODUITS - SECTIONS
  // ============================================

  /// Récupérer les produits en vedette
  Future<List<Product>> getFeaturedProducts({int limit = 10});

  /// Récupérer les produits populaires
  Future<List<Product>> getPopularProducts({int limit = 10});

  /// Récupérer les produits récents
  Future<List<Product>> getRecentProducts({int limit = 10});

  /// Récupérer les produits en promotion
  Future<List<Product>> getOnSaleProducts({int limit = 10});

  // ============================================
  // PRODUITS - RECHERCHE & FILTRES
  // ============================================

  /// Rechercher des produits
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 15,
  });

  /// Filtrer les produits
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
  });

  // ============================================
  // PRODUITS - RELATIONS
  // ============================================

  /// Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer les produits par marque
  Future<List<Product>> getProductsByBrand({
    required int brandId,
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer les produits similaires
  Future<List<Product>> getSimilarProducts(int productId);

  // ============================================
  // CATÉGORIES
  // ============================================

  /// Récupérer toutes les catégories
  Future<List<Category>> getCategories({
    bool includeInactive = false,
  });

  /// Récupérer les catégories racines uniquement
  Future<List<Category>> getRootCategories();

  /// Récupérer les catégories en vedette
  Future<List<Category>> getFeaturedCategories();

  /// Récupérer les détails d'une catégorie
  Future<Category> getCategoryDetails(int id);

  /// Récupérer les produits d'une catégorie
  Future<List<Product>> getCategoryProducts({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer les sous-catégories d'une catégorie
  Future<List<Category>> getSubcategories(int categoryId);

  // ============================================
  // MARQUES
  // ============================================

  /// Récupérer toutes les marques
  Future<List<Brand>> getBrands({
    bool includeInactive = false,
  });

  /// Récupérer les marques en vedette
  Future<List<Brand>> getFeaturedBrands();

  /// Récupérer les détails d'une marque
  Future<Brand> getBrandDetails(int id);

  /// Récupérer les produits d'une marque
  Future<List<Product>> getBrandProducts({
    required int brandId,
    int page = 1,
    int perPage = 15,
  });

  // ============================================
  // IMAGES & GALERIE
  // ============================================

  /// Récupérer toutes les images d'un produit
  Future<List<ProductImage>> getProductImages(int productId);

  /// Récupérer l'image principale d'un produit
  Future<ProductImage?> getPrimaryImage(int productId);

  // ============================================
  // AVIS
  // ============================================

  /// Récupérer les avis d'un produit
  Future<List<dynamic>> getProductReviews({
    required int productId,
    int page = 1,
    int perPage = 10,
  });

  /// Soumettre un avis avec photos optionnelles
  Future<Map<String, dynamic>> submitReview({
    required int productId,
    required double rating,
    required String comment,
    String? title,
    double qualityRating = 0,
    double priceRating = 0,
    double shippingRating = 0,
    List<String> imagePaths = const [],
  });

  /// Supprimer un avis
  Future<void> deleteReview(int reviewId);

  /// Voter pour un avis (utile / pas utile)
  Future<Map<String, dynamic>> voteReview({
    required int reviewId,
    required bool helpful,
  });

  /// Récupérer la note moyenne d'un produit
  Future<double> getProductAverageRating(int productId);

  // ============================================
  // PRODUITS RÉCEMMENT CONSULTÉS
  // ============================================

  /// Récupérer les produits récemment consultés
  Future<List<Product>> getRecentlyViewedProducts({int limit = 10});

  /// Ajouter un produit à l'historique récent
  Future<void> addToRecentlyViewed(int productId);

  /// Effacer l'historique récent
  Future<void> clearRecentlyViewed();
}