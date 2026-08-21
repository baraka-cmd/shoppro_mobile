// Interface du repository des produits
// Définit le contrat que le repository doit respecter

import '../entities/product.dart';
import '../entities/category.dart';
import '../entities/brand.dart';

abstract class ProductRepository {
  /// Récupérer la liste paginée des produits
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer les détails d'un produit
  Future<Product> getProductDetails(int id);

  /// Récupérer les produits en vedette
  Future<List<Product>> getFeaturedProducts({int limit = 10});

  /// Récupérer les produits populaires
  Future<List<Product>> getPopularProducts({int limit = 10});

  /// Récupérer les produits récents
  Future<List<Product>> getRecentProducts({int limit = 10});

  /// Récupérer les produits en promotion
  Future<List<Product>> getOnSaleProducts({int limit = 10});

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

  /// Récupérer toutes les catégories
  Future<List<Category>> getCategories();

  /// Récupérer les détails d'une catégorie
  Future<Category> getCategoryDetails(int id);

  /// Récupérer les produits d'une catégorie
  Future<List<Product>> getCategoryProducts({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  });

  /// Récupérer toutes les marques
  Future<List<Brand>> getBrands();

  /// Récupérer les détails d'une marque
  Future<Brand> getBrandDetails(int id);

  /// Récupérer les produits d'une marque
  Future<List<Product>> getBrandProducts({
    required int brandId,
    int page = 1,
    int perPage = 15,
  });

  /// Vérifier si plus de produits sont disponibles (pagination)
  Future<bool> hasMoreProducts({
    int page = 1,
    int perPage = 15,
  });
}