// Provider des produits
// Gère l'état des produits dans l'application

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

  // ============================================
  // GETTERS
  // ============================================

  ProductStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == ProductStatus.loading;
  bool get isLoadingMore => _status == ProductStatus.loadingMore;
  bool get hasError => _status == ProductStatus.error;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get popularProducts => _popularProducts;
  List<Product> get recentProducts => _recentProducts;
  List<Product> get onSaleProducts => _onSaleProducts;
  List<Product> get searchResults => _searchResults;
  List<Product> get similarProducts => _similarProducts;

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
      notifyListeners();
      return;
    }

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

  /// Changer le tri
  void setSort(String sortBy, String sortDirection) {
    _sortBy = sortBy;
    _sortDirection = sortDirection;
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
}