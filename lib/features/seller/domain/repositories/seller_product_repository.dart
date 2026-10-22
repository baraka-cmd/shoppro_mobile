// ============================================
// REPOSITORY (INTERFACE) : SellerProductRepository
// ============================================
// Contrat que doit respecter toute implémentation
// du repository des produits vendeur.
//
// Principe Clean Architecture :
//   - Le domaine définit CE QU'ON VEUT faire
//   - L'implémentation (data) définit COMMENT on le fait
//   - Le provider (presentation) utilise l'interface,
//     jamais l'implémentation directement
//
// Avantages :
//   - Testable (on peut mocker le repository)
//   - Découplé (on peut changer l'impl sans toucher au reste)
//   - Documenté (le contrat est explicite)
// ============================================

// Entity
import '../entities/seller_product.dart';

// API Result (le repository renvoie le résultat paginé)
import '../../data/sources/seller_product_api.dart';

abstract class SellerProductRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupère la liste paginée des produits du vendeur.
  ///
  /// [page]        : numéro de page (défaut 1)
  /// [perPage]     : nombre par page (défaut 15, max 50)
  /// [search]      : recherche par nom ou SKU
  /// [categoryId]  : filtre par catégorie
  /// [status]      : all | draft | active | archived | out_of_stock | low_stock
  /// [sortBy]      : created_at | price | sales_count | views_count | stock
  /// [sortDir]     : asc | desc
  ///
  /// Peut lever :
  ///   - SellerProductUnauthorizedException (token expiré)
  ///   - SellerProductForbiddenException (KYC pending)
  ///   - SellerProductNetworkException (offline)
  ///   - SellerProductServerException (500)
  Future<SellerProductsResult> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    String? status,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  });

  /// Récupère le détail d'un produit.
  Future<SellerProduct> getProductById(int id);

  /// Récupère l'aperçu client d'un produit.
  Future<SellerProduct> previewProduct(int id);

  // ============================================
  // CRÉATION & MODIFICATION
  // ============================================

  /// Crée un nouveau produit (brouillon).
  Future<SellerProduct> createProduct(Map<String, dynamic> data);

  /// Met à jour un produit existant.
  Future<SellerProduct> updateProduct(int id, Map<String, dynamic> data);

  /// Archive un produit (soft delete).
  Future<void> deleteProduct(int id);

  // ============================================
  // PUBLICATION
  // ============================================

  /// Publie un produit (draft → active).
  Future<SellerProduct> publishProduct(int id);

  /// Dépublie un produit (active → draft).
  Future<SellerProduct> unpublishProduct(int id);

  /// Duplique un produit.
  Future<SellerProduct> duplicateProduct(int id);

  // ============================================
  // IMAGES
  // ============================================

  /// Upload une ou plusieurs images.
  Future<SellerProduct> uploadImages(int productId, List<String> imagePaths);

  /// Supprime une image.
  Future<SellerProduct> deleteImage(int productId, int imageId);

  /// Réorganise les images.
  Future<SellerProduct> reorderImages(int productId, List<int> imageIds);

  // ============================================
  // HELPERS
  // ============================================

  /// Récupère les catégories disponibles pour le formulaire.
  ///
  /// Renvoie une liste de catégories actives.
  /// Utilisé pour peupler le dropdown "Catégorie" dans le formulaire.
  Future<List<SellerProductCategory>> getCategories();

  /// Récupère les marques disponibles pour le formulaire.
  Future<List<SellerProductBrand>> getBrands();

  // ============================================
  // CACHE
  // ============================================

  /// Efface le cache local (changement de compte, logout).
  Future<void> clearCache();
}