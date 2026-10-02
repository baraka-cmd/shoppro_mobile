// ============================================
// PROVIDER DES PRODUITS
// ============================================
// Gère l'état des produits avec pagination,
// filtres, tri, recherche intelligente
// et gestion des avis clients.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

enum ProductStatus {
  initial,       // État initial
  loading,       // Chargement
  loaded,        // Chargé
  loadingMore,   // Chargement supplémentaire (pagination)
  error,         // Erreur
}

/// Statut de la soumission d'un avis
enum ReviewSubmitStatus {
  idle,       // Rien en cours
  submitting, // Envoi en cours
  success,    // Envoyé
  error,      // Erreur
}

class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  ProductStatus _status = ProductStatus.initial;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Filtres actifs
  int? _categoryIdFilter;
  int? _brandIdFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;
  bool? _inStockFilter;
  double? _minRatingFilter;
  bool? _onSaleFilter;
  String _searchQuery = '';

  // ============================================
  // LISTES DE PRODUITS
  // ============================================

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _popularProducts = [];
  List<Product> _recentProducts = [];
  List<Product> _onSaleProducts = [];
  List<Product> _searchResults = [];
  List<Product> _similarProducts = [];
  List<Product> _recentlyViewedProducts = [];

  // ============================================
  // ÉTAT DES AVIS (NOUVEAU)
  // ============================================

  ReviewSubmitStatus _reviewStatus = ReviewSubmitStatus.idle;
  String? _reviewError;
  List<dynamic> _productReviews = [];
  bool _isLoadingReviews = false;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  ProductStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == ProductStatus.loading;
  bool get isLoadingMore => _status == ProductStatus.loadingMore;
  bool get hasError => _status == ProductStatus.error;
  bool get isLoaded => _status == ProductStatus.loaded;
  bool get isEmpty => _products.isEmpty;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get popularProducts => _popularProducts;
  List<Product> get recentProducts => _recentProducts;
  List<Product> get onSaleProducts => _onSaleProducts;
  List<Product> get searchResults => _searchResults;
  List<Product> get similarProducts => _similarProducts;
  List<Product> get recentlyViewedProducts => _recentlyViewedProducts;

  /// Nombre total de produits chargés
  int get productsCount => _products.length;

  /// Produits en vedette (triés)
  List<Product> get featuredProductsSorted {
    final sorted = [..._featuredProducts];
    sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted;
  }

  /// Produits en promotion (triés par réduction)
  List<Product> get onSaleProductsSorted {
    final sorted = [..._onSaleProducts];
    sorted.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return sorted;
  }

  // ============================================
  // GETTERS AVIS (NOUVEAU)
  // ============================================

  ReviewSubmitStatus get reviewStatus => _reviewStatus;
  String? get reviewError => _reviewError;
  bool get isSubmittingReview =>
      _reviewStatus == ReviewSubmitStatus.submitting;
  bool get reviewSubmitSuccess =>
      _reviewStatus == ReviewSubmitStatus.success;
  List<dynamic> get productReviews => _productReviews;
  bool get isLoadingReviews => _isLoadingReviews;

  // ============================================
  // GETTERS FILTRES ACTIFS
  // ============================================

  bool get hasActiveFilters {
    return _categoryIdFilter != null ||
        _brandIdFilter != null ||
        _minPriceFilter != null ||
        _maxPriceFilter != null ||
        _inStockFilter != null ||
        _minRatingFilter != null ||
        _onSaleFilter != null;
  }

  int get activeFiltersCount {
    var count = 0;
    if (_categoryIdFilter != null) count++;
    if (_brandIdFilter != null) count++;
    if (_minPriceFilter != null || _maxPriceFilter != null) count++;
    if (_inStockFilter != null) count++;
    if (_minRatingFilter != null) count++;
    if (_onSaleFilter != null) count++;
    return count;
  }

  String get currentSortLabel {
    switch (_sortBy) {
      case 'price':
        return _sortDirection == 'asc' ? 'Prix croissant' : 'Prix décroissant';
      case 'name':
        return _sortDirection == 'asc' ? 'Nom A-Z' : 'Nom Z-A';
      case 'rating':
        return 'Meilleures notes';
      case 'sales_count':
        return 'Plus populaires';
      case 'created_at':
        return _sortDirection == 'asc' ? 'Plus anciens' : 'Plus récents';
      default:
        return 'Tri par défaut';
    }
  }

  // ============================================
  // CHARGEMENT DES PRODUITS
  // ============================================

  /// Charger les produits (page 1)
  Future<void> loadProducts() async {
    _setStatus(ProductStatus.loading);
    _clearError();

    try {
      _currentPage = 1;
      _products = await _productRepository.getProducts(page: 1);
      _hasMore = await _productRepository.hasMoreProducts(page: 1);
      _setStatus(ProductStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(ProductStatus.error);
    }

    notifyListeners();
  }

  /// Charger plus de produits (pagination)
  Future<void> loadMoreProducts() async {
    if (_status == ProductStatus.loadingMore || !_hasMore) return;

    _setStatus(ProductStatus.loadingMore);

    try {
      final nextPage = _currentPage + 1;
      final newProducts = await _productRepository.getProducts(page: nextPage);

      if (newProducts.isNotEmpty) {
        _products = [..._products, ...newProducts];
        _currentPage = nextPage;
        _hasMore = await _productRepository.hasMoreProducts(page: nextPage);
      } else {
        _hasMore = false;
      }

      _setStatus(ProductStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(ProductStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les produits
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  // ============================================
  // CHARGEMENT DES SECTIONS
  // ============================================

  /// Charger les produits en vedette
  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _productRepository.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur featured: $e');
    }
  }

  /// Charger les produits populaires
  Future<void> loadPopularProducts() async {
    try {
      _popularProducts = await _productRepository.getPopularProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur popular: $e');
    }
  }

  /// Charger les produits récents
  Future<void> loadRecentProducts() async {
    try {
      _recentProducts = await _productRepository.getRecentProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur recent: $e');
    }
  }

  /// Charger les produits en promotion
  Future<void> loadOnSaleProducts() async {
    try {
      _onSaleProducts = await _productRepository.getOnSaleProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur onSale: $e');
    }
  }

  /// Charger toutes les sections
  Future<void> loadAllSections() async {
    await Future.wait([
      loadFeaturedProducts(),
      loadPopularProducts(),
      loadRecentProducts(),
      loadOnSaleProducts(),
    ]);
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Rechercher des produits
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query.trim();
    _setStatus(ProductStatus.loading);

    try {
      _searchResults = await _productRepository.searchProducts(query: query);
      _setStatus(ProductStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(ProductStatus.error);
    }

    notifyListeners();
  }

  /// Effacer les résultats de recherche
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Filtrer les produits
  Future<void> filterProducts({
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    double? minRating,
    bool? onSale,
    String? sortBy,
    String? sortDirection,
  }) async {
    _setStatus(ProductStatus.loading);
    _clearError();

    // Sauvegarder les filtres
    _categoryIdFilter = categoryId;
    _brandIdFilter = brandId;
    _minPriceFilter = minPrice;
    _maxPriceFilter = maxPrice;
    _inStockFilter = inStock;
    _minRatingFilter = minRating;
    _onSaleFilter = onSale;

    try {
      _products = await _productRepository.filterProducts(
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
        minRating: minRating,
        onSale: onSale,
        sortBy: sortBy ?? _sortBy,
        sortDirection: sortDirection ?? _sortDirection,
        page: 1,
      );
      _currentPage = 1;
      _hasMore = await _productRepository.hasMoreProducts(page: 1);
      _setStatus(ProductStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(ProductStatus.error);
    }

    notifyListeners();
  }

  /// Effacer tous les filtres
  Future<void> clearFilters() async {
    _categoryIdFilter = null;
    _brandIdFilter = null;
    _minPriceFilter = null;
    _maxPriceFilter = null;
    _inStockFilter = null;
    _minRatingFilter = null;
    _onSaleFilter = null;
    await loadProducts();
  }

  /// Changer le tri
  void setSort(String sortBy, String sortDirection) {
    _sortBy = sortBy;
    _sortDirection = sortDirection;
    notifyListeners();
  }

  // ============================================
  // PRODUITS SIMILAIRES
  // ============================================

  /// Charger les produits similaires
  Future<void> loadSimilarProducts(int productId) async {
    try {
      _similarProducts = await _productRepository.getSimilarProducts(productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur similar: $e');
    }
  }

  /// Effacer les produits similaires
  void clearSimilarProducts() {
    _similarProducts = [];
    notifyListeners();
  }

  // ============================================
  // PRODUITS RÉCEMMENT CONSULTÉS
  // ============================================

  /// Charger les produits récemment consultés
  Future<void> loadRecentlyViewedProducts() async {
    try {
      _recentlyViewedProducts =
          await _productRepository.getRecentlyViewedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur recently viewed: $e');
    }
  }

  /// Ajouter un produit aux récemment consultés
  Future<void> addToRecentlyViewed(int productId) async {
    try {
      await _productRepository.addToRecentlyViewed(productId);
      await loadRecentlyViewedProducts();
    } catch (e) {
      debugPrint('Erreur addToRecentlyViewed: $e');
    }
  }

  /// Effacer les récemment consultés
  Future<void> clearRecentlyViewed() async {
    try {
      await _productRepository.clearRecentlyViewed();
      _recentlyViewedProducts = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur clearRecentlyViewed: $e');
    }
  }

  // ============================================
  // AVIS (NOUVEAU)
  // ============================================

  /// Charger les avis d'un produit
  Future<void> loadProductReviews(int productId) async {
    _isLoadingReviews = true;
    notifyListeners();

    try {
      _productReviews =
          await _productRepository.getProductReviews(productId: productId);
    } catch (e) {
      debugPrint('Erreur loadProductReviews: $e');
      _productReviews = [];
    }

    _isLoadingReviews = false;
    notifyListeners();
  }

  /// Soumettre un avis avec photos
  /// Retourne `true` si succès, `false` sinon
  Future<bool> submitReview({
    required int productId,
    required double rating,
    required String comment,
    String? title,
    double qualityRating = 0,
    double priceRating = 0,
    double shippingRating = 0,
    List<String> imagePaths = const [],
  }) async {
    // Reset de l'état
    _reviewStatus = ReviewSubmitStatus.submitting;
    _reviewError = null;
    notifyListeners();

    try {
      await _productRepository.submitReview(
        productId: productId,
        rating: rating,
        comment: comment,
        title: title,
        qualityRating: qualityRating,
        priceRating: priceRating,
        shippingRating: shippingRating,
        imagePaths: imagePaths,
      );

      _reviewStatus = ReviewSubmitStatus.success;

      // Recharger les avis du produit
      await loadProductReviews(productId);

      notifyListeners();
      return true;
    } catch (e) {
      _reviewStatus = ReviewSubmitStatus.error;
      _reviewError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Réinitialiser le statut d'avis (à appeler après avoir affiché un message)
  void resetReviewStatus() {
    _reviewStatus = ReviewSubmitStatus.idle;
    _reviewError = null;
    notifyListeners();
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(ProductStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  @override
  String toString() {
    return 'ProductProvider(status: $_status, products: ${_products.length}, '
        'page: $_currentPage, hasMore: $_hasMore, filters: $activeFiltersCount, '
        'sort: $currentSortLabel, reviews: ${_productReviews.length})';
  }
}