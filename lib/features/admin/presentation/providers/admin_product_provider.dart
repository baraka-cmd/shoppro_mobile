// ============================================
// PROVIDER : AdminProductProvider
// ============================================
// Provider de gestion d'état pour le CRUD des produits.
// Utilise le ProductRepository existant (méthodes compatibles).
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features)
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/category.dart';
import '../../../products/domain/entities/brand.dart';

// Repositories (autres features - réutilisés)
import '../../../products/domain/repositories/product_repository.dart';

// Repositories Impl (autres features - réutilisés)
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/data/models/product_model.dart';
// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider produits admin
enum AdminProductStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  saving,
  deleting,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des produits pour l'administration.
///
/// Réutilise le ProductRepository existant pour éviter les doublons.
class AdminProductProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final ProductRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminProductStatus _status = AdminProductStatus.initial;
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Brand> _brands = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;

  // Filtres
  int? _filterCategoryId;
  int? _filterBrandId;
  bool? _filterOnSale;
  bool? _filterInStock;
  String _searchQuery = '';
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  int _activeProducts = 0;
  int _inactiveProducts = 0;
  int _onSaleProducts = 0;
  int _outOfStockProducts = 0;
  int _lowStockProducts = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminProductStatus get status => _status;
  List<Product> get products => List.unmodifiable(_products);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Brand> get brands => List.unmodifiable(_brands);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == AdminProductStatus.loading;
  bool get isLoaded => _status == AdminProductStatus.loaded;
  bool get isLoadingMore => _status == AdminProductStatus.loadingMore;
  bool get isSaving => _status == AdminProductStatus.saving;
  bool get isDeleting => _status == AdminProductStatus.deleting;
  bool get hasError => _status == AdminProductStatus.error;
  int get productsCount => _products.length;
  bool get isEmpty => _products.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);

  // Statistiques
  int get activeProducts => _activeProducts;
  int get inactiveProducts => _inactiveProducts;
  int get onSaleProducts => _onSaleProducts;
  int get outOfStockProducts => _outOfStockProducts;
  int get lowStockProducts => _lowStockProducts;

  /// Produits actifs
  List<Product> get activeProductList =>
      _products.where((p) => p.isActive).toList();

  /// Produits en promotion
  List<Product> get onSaleProductList =>
      _products.where((p) => p.isOnSale).toList();

  /// Produits en rupture de stock
  List<Product> get outOfStockProductList =>
      _products.where((p) => !p.isInStock).toList();

  /// Produits avec stock faible
  List<Product> get lowStockProductList =>
      _products.where((p) => p.isInStock && p.stock <= p.minStock).toList();

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des produits.
  Future<void> loadProducts() async {
  _status = AdminProductStatus.loading;
  _errorMessage = null;
  _currentPage = 1;
  notifyListeners();

  try {
    final products = await _repository.getProducts(
      page: _currentPage,
      perPage: _perPage,
    );

    // ✅ CONVERSION ProductModel → Product (entité)
    final converted = _convertToEntities(products);
    _products = _filterLocally(converted);
    _hasMore = products.length >= _perPage;
    _status = AdminProductStatus.loaded;
    await _loadCategories();
    await _loadBrands();
    _computeStatistics();
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminProductStatus.error;
    debugPrint('Erreur loadProducts: $e');
  }

  notifyListeners();
}



  /// Charge la page suivante.
  Future<void> loadMoreProducts() async {
  if (_status == AdminProductStatus.loadingMore || !_hasMore) return;

  _status = AdminProductStatus.loadingMore;
  notifyListeners();

  try {
    final nextPage = _currentPage + 1;
    final products = await _repository.getProducts(
      page: nextPage,
      perPage: _perPage,
    );

    if (products.isEmpty) {
      _hasMore = false;
    } else {
      // ✅ CONVERSION
      final converted = _convertToEntities(products);
      _products = [..._products, ..._filterLocally(converted)];
      _currentPage = nextPage;
      _hasMore = products.length >= _perPage;
    }

    _status = AdminProductStatus.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminProductStatus.error;
    debugPrint('Erreur loadMoreProducts: $e');
  }

  notifyListeners();
}

  /// Rafraîchit sans loader.
  Future<void> refreshProducts() async {
  try {
    final products = await _repository.getProducts(
      page: 1,
      perPage: _perPage,
    );

    // ✅ CONVERSION ProductModel → Product (entité)
    final converted = _convertToEntities(products);
    _products = _filterLocally(converted);
    _currentPage = 1;
    _hasMore = products.length >= _perPage;
    _status = AdminProductStatus.loaded;
    _computeStatistics();
  } catch (e) {
    _errorMessage = e.toString();
    debugPrint('Erreur refreshProducts: $e');
  }

  notifyListeners();
}

  // ============================================
  // CRUD
  // ============================================

  /// Crée un nouveau produit.
  Future<bool> createProduct(Product product) async {
    _status = AdminProductStatus.saving;
    notifyListeners();

    try {
      _products.insert(0, product);
      _computeStatistics();
      _status = AdminProductStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminProductStatus.error;
      debugPrint('Erreur createProduct: $e');
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un produit.
  Future<bool> updateProduct(Product product) async {
    _status = AdminProductStatus.saving;
    notifyListeners();

    try {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
      _computeStatistics();
      _status = AdminProductStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminProductStatus.error;
      debugPrint('Erreur updateProduct: $e');
      notifyListeners();
      return false;
    }
  }

  /// Supprime un produit.
  Future<bool> deleteProduct(int id) async {
    _status = AdminProductStatus.deleting;
    notifyListeners();

    try {
      _products.removeWhere((p) => p.id == id);
      _selectedIds.remove(id);
      _computeStatistics();
      _status = AdminProductStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminProductStatus.error;
      debugPrint('Erreur deleteProduct: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECHERCHE ET FILTRES
  // ============================================

  /// Recherche des produits (filtrage local).
  void searchLocally(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filtre par catégorie (filtrage local).
  void filterByCategory(int? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  /// Filtre par marque (filtrage local).
  void filterByBrand(int? brandId) {
    _filterBrandId = brandId;
    notifyListeners();
  }

  /// Filtre produits en promotion.
  void filterOnSale(bool? onSale) {
    _filterOnSale = onSale;
    notifyListeners();
  }

  /// Filtre produits en stock.
  void filterInStock(bool? inStock) {
    _filterInStock = inStock;
    notifyListeners();
  }

  /// Efface les filtres.
  void clearFilters() {
    _filterCategoryId = null;
    _filterBrandId = null;
    _filterOnSale = null;
    _filterInStock = null;
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================
  // CATÉGORIES ET MARQUES
  // ============================================

  /// Charge les catégories pour les filtres.
  Future<void> _loadCategories() async {
    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint('Erreur _loadCategories: $e');
    }
  }

  /// Charge les marques pour les filtres.
  Future<void> _loadBrands() async {
    try {
      _brands = await _repository.getBrands();
    } catch (e) {
      debugPrint('Erreur _loadBrands: $e');
    }
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Toggle la sélection.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Sélectionne tout.
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_products.map((p) => p.id));
    notifyListeners();
  }

  /// Efface la sélection.
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Vérifie la sélection.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Applique les filtres locaux.
  List<Product> _filterLocally(List<Product> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filterCategoryId != null) {
      filtered = filtered
          .where((p) => p.category?.id == _filterCategoryId)
          .toList();
    }

    if (_filterBrandId != null) {
      filtered = filtered
          .where((p) => p.brand?.id == _filterBrandId)
          .toList();
    }

    if (_filterOnSale != null) {
      filtered = filtered.where((p) => p.isOnSale == _filterOnSale).toList();
    }

    if (_filterInStock != null) {
      filtered = filtered.where((p) => p.isInStock == _filterInStock).toList();
    }

    return filtered;
  }

  /// Calcule les statistiques locales.
  void _computeStatistics() {
    _activeProducts = _products.where((p) => p.isActive).length;
    _inactiveProducts = _products.where((p) => !p.isActive).length;
    _onSaleProducts = _products.where((p) => p.isOnSale).length;
    _outOfStockProducts = _products.where((p) => !p.isInStock).length;
    _lowStockProducts = _products.where((p) => p.isInStock && p.stock <= p.minStock).length;
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminProductStatus.initial;
    _products = [];
    _categories = [];
    _brands = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterCategoryId = null;
    _filterBrandId = null;
    _filterOnSale = null;
    _filterInStock = null;
    _searchQuery = '';
    _selectedIds.clear();
    _activeProducts = 0;
    _inactiveProducts = 0;
    _onSaleProducts = 0;
    _outOfStockProducts = 0;
    _lowStockProducts = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  // ============================================
// HELPER DE CONVERSION Model → Entity
// ============================================

List<Product> _convertToEntities(List<Product> products) {
  return products.map((p) {
    if (p is ProductModel) {
      return Product(
        id: p.id,
        name: p.name,
        slug: p.slug,
        shortDescription: p.shortDescription,
        description: p.description,
        price: p.price,
        discountPrice: p.discountPrice,
        currentPrice: p.currentPrice,
        discountPercentage: p.discountPercentage,
        stock: p.stock,
        isInStock: p.isInStock,
        stockStatus: p.stockStatus,
        minStock: p.minStock,
        sku: p.sku,
        barcode: p.barcode,
        category: p.category,
        brand: p.brand,
        images: p.images,
        mainImage: p.mainImage,
        mainImageThumbnail: p.mainImageThumbnail,
        viewsCount: p.viewsCount,
        salesCount: p.salesCount,
        favoritesCount: p.favoritesCount,
        averageRating: p.averageRating,
        reviewsCount: p.reviewsCount,
        isFeatured: p.isFeatured,
        isNew: p.isNew,
        isBestseller: p.isBestseller,
        isOnSale: p.isOnSale,
        isActive: p.isActive,
        isAvailable: p.isAvailable,
        availableFrom: p.availableFrom,
        availableUntil: p.availableUntil,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
        subcategoryId: p.subcategoryId,
      );
    }
    return p;
  }).toList();
}
  @override
  String toString() {
    return 'AdminProductProvider(status: $_status, products: ${_products.length}, '
        'categories: ${_categories.length}, brands: ${_brands.length})';
  }
}