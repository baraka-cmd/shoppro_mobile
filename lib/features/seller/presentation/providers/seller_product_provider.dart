// ============================================
// PROVIDER : SellerProductProvider
// ============================================
// Gestion d'état de la liste des produits vendeur.
//
// Responsabilités :
//   - Chargement paginé
//   - Recherche, filtres, tri
//   - Actions CRUD (création, mise à jour, suppression)
//   - Publication / dépublication / duplication
//   - Upload / suppression d'images
//   - Gestion des erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enum
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_product.dart';
import '../../domain/repositories/seller_product_repository.dart';

// Data
import '../../data/repositories/seller_product_repository_impl.dart';
import '../../data/sources/seller_product_api.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

enum SellerProductListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  forbidden,
  unauthorized,
}

enum SellerProductActionStatus {
  idle,
  creating,
  updating,
  deleting,
  publishing,
  unpublishing,
  duplicating,
  uploadingImages,
  deletingImage,
  error,
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerProductProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final SellerProductRepository _repository;

  SellerProductProvider({SellerProductRepository? repository})
      : _repository = repository ?? SellerProductRepositoryImpl();

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerProductListStatus _listStatus = SellerProductListStatus.initial;
  List<SellerProduct> _products = [];
  String? _listError;
  String? _kycStatus;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 15;

  // Filtres
  String _search = '';
  int? _filterCategoryId;
  String _filterStatus = 'all';
  String _sortBy = 'created_at';
  String _sortDir = 'desc';

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerProductActionStatus _actionStatus = SellerProductActionStatus.idle;
  String? _actionError;
  SellerProduct? _lastAffectedProduct;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerProductListStatus get listStatus => _listStatus;
  List<SellerProduct> get products => List.unmodifiable(_products);
  String? get listError => _listError;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _listStatus == SellerProductListStatus.loading;
  bool get isLoaded => _listStatus == SellerProductListStatus.loaded;
  bool get isLoadingMore => _listStatus == SellerProductListStatus.loadingMore;
  bool get hasError => _listStatus == SellerProductListStatus.error;
  bool get isForbidden => _listStatus == SellerProductListStatus.forbidden;
  bool get isUnauthorized => _listStatus == SellerProductListStatus.unauthorized;

  bool get isEmpty => _products.isEmpty;
  int get productsCount => _products.length;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _hasMore;

  // Filtres
  String get search => _search;
  int? get filterCategoryId => _filterCategoryId;
  String get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  String get sortDir => _sortDir;

  /// Le provider a-t-il des filtres actifs (hors défaut) ?
  bool get hasActiveFilters =>
      _search.isNotEmpty ||
      _filterCategoryId != null ||
      _filterStatus != 'all';

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerProductActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  SellerProduct? get lastAffectedProduct => _lastAffectedProduct;

  bool get isCreating => _actionStatus == SellerProductActionStatus.creating;
  bool get isUpdating => _actionStatus == SellerProductActionStatus.updating;
  bool get isDeleting => _actionStatus == SellerProductActionStatus.deleting;
  bool get isPublishing => _actionStatus == SellerProductActionStatus.publishing;
  bool get isUnpublishing => _actionStatus == SellerProductActionStatus.unpublishing;
  bool get isDuplicating => _actionStatus == SellerProductActionStatus.duplicating;
  bool get isUploadingImages => _actionStatus == SellerProductActionStatus.uploadingImages;
  bool get isDeletingImage => _actionStatus == SellerProductActionStatus.deletingImage;
  bool get hasActionError => _actionStatus == SellerProductActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerProductActionStatus.idle &&
      _actionStatus != SellerProductActionStatus.error;

  // ============================================
  // CHARGEMENT DE LA LISTE
  // ============================================

  /// Charge la première page.
  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerProductListStatus.loading;
    _listError = null;
    _kycStatus = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _repository.getProducts(
        page: 1,
        perPage: _perPage,
        search: _search.isNotEmpty ? _search : null,
        categoryId: _filterCategoryId,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _products = result.products;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerProductListStatus.loaded;
    } on SellerProductForbiddenException catch (e) {
      _listStatus = SellerProductListStatus.forbidden;
      _listError = e.message;
      _kycStatus = e.code;
      debugPrint('🚫 Produits forbidden: ${e.message}');
    } on SellerProductUnauthorizedException catch (e) {
      _listStatus = SellerProductListStatus.unauthorized;
      _listError = e.message;
      debugPrint('🔒 Produits unauthorized: ${e.message}');
    } on SellerProductNetworkException catch (e) {
      _listStatus = SellerProductListStatus.error;
      _listError = e.message;
      debugPrint('📡 Produits network error: ${e.message}');
    } on SellerProductServerException catch (e) {
      _listStatus = SellerProductListStatus.error;
      _listError = e.message;
      debugPrint('💥 Produits server error: ${e.message}');
    } catch (e) {
      _listStatus = SellerProductListStatus.error;
      _listError = 'Une erreur inattendue est survenue.';
      debugPrint('❌ Produits unknown error: $e');
    }

    notifyListeners();
  }

  /// Charge la page suivante (pagination infinie).
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerProductListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.getProducts(
        page: nextPage,
        perPage: _perPage,
        search: _search.isNotEmpty ? _search : null,
        categoryId: _filterCategoryId,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _products = [..._products, ...result.products];
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerProductListStatus.loaded;
    } catch (e) {
      _listStatus = SellerProductListStatus.error;
      _listError = e.toString();
      debugPrint('❌ Erreur loadMore: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit la liste (pull-to-refresh).
  Future<void> refresh() async {
    await loadProducts(forceRefresh: true);
  }

  // ============================================
  // FILTRES & RECHERCHE
  // ============================================

  /// Change la recherche et recharge.
  Future<void> setSearch(String value) async {
    _search = value.trim();
    await loadProducts();
  }

  /// Change le filtre catégorie.
  Future<void> setCategoryFilter(int? categoryId) async {
    _filterCategoryId = categoryId;
    await loadProducts();
  }

  /// Change le filtre statut.
  Future<void> setStatusFilter(String status) async {
    _filterStatus = status;
    await loadProducts();
  }

  /// Change le tri.
  Future<void> setSort(String sortBy, {String? sortDir}) async {
    _sortBy = sortBy;
    if (sortDir != null) _sortDir = sortDir;
    await loadProducts();
  }

  /// Efface tous les filtres.
  Future<void> clearFilters() async {
    _search = '';
    _filterCategoryId = null;
    _filterStatus = 'all';
    _sortBy = 'created_at';
    _sortDir = 'desc';
    await loadProducts();
  }

  // ============================================
  // ACTIONS : CRUD
  // ============================================

  /// Crée un nouveau produit.
  ///
  /// Retourne le produit créé si succès, null sinon.
  Future<SellerProduct?> createProduct(Map<String, dynamic> data) async {
    _actionStatus = SellerProductActionStatus.creating;
    _actionError = null;
    notifyListeners();

    try {
      final product = await _repository.createProduct(data);

      // Insérer en tête de liste
      _products = [product, ..._products];
      _total++;

      _lastAffectedProduct = product;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return product;
    } on SellerProductValidationException catch (e) {
      _actionError = e.message;
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    } on SellerProductConflictException catch (e) {
      _actionError = e.message;
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    } on SellerProductForbiddenException catch (e) {
      _actionError = e.message;
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Met à jour un produit existant.
  Future<SellerProduct?> updateProduct(int id, Map<String, dynamic> data) async {
    _actionStatus = SellerProductActionStatus.updating;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProduct(id, data);
      _replaceProduct(updated);
      _lastAffectedProduct = updated;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Archive un produit (soft delete).
  Future<bool> deleteProduct(int id) async {
    _actionStatus = SellerProductActionStatus.deleting;
    _actionError = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      _products = _products.where((p) => p.id != id).toList();
      _total--;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // ACTIONS : PUBLICATION
  // ============================================

  /// Publie un produit.
  Future<SellerProduct?> publishProduct(int id) async {
    _actionStatus = SellerProductActionStatus.publishing;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _repository.publishProduct(id);
      _replaceProduct(updated);
      _lastAffectedProduct = updated;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Dépublie un produit.
  Future<SellerProduct?> unpublishProduct(int id) async {
    _actionStatus = SellerProductActionStatus.unpublishing;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _repository.unpublishProduct(id);
      _replaceProduct(updated);
      _lastAffectedProduct = updated;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }


  // ============================================
// MÉTADONNÉES (Catégories & Marques)
// ============================================

Future<List<SellerProductCategory>> loadCategories() async {
  try {
    return await _repository.getCategories();
  } catch (e) {
    debugPrint('❌ Erreur loadCategories: $e');
    return [];
  }
}

Future<List<SellerProductBrand>> loadBrands() async {
  try {
    return await _repository.getBrands();
  } catch (e) {
    debugPrint('❌ Erreur loadBrands: $e');
    return [];
  }
}

  /// Duplique un produit.
  Future<SellerProduct?> duplicateProduct(int id) async {
    _actionStatus = SellerProductActionStatus.duplicating;
    _actionError = null;
    notifyListeners();

    try {
      final newProduct = await _repository.duplicateProduct(id);
      _products = [newProduct, ..._products];
      _total++;
      _lastAffectedProduct = newProduct;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return newProduct;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // ACTIONS : IMAGES
  // ============================================

  /// Upload une ou plusieurs images.
  Future<SellerProduct?> uploadImages(int productId, List<String> paths) async {
    _actionStatus = SellerProductActionStatus.uploadingImages;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _repository.uploadImages(productId, paths);
      _replaceProduct(updated);
      _lastAffectedProduct = updated;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Supprime une image.
  Future<SellerProduct?> deleteImage(int productId, int imageId) async {
    _actionStatus = SellerProductActionStatus.deletingImage;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _repository.deleteImage(productId, imageId);
      _replaceProduct(updated);
      _lastAffectedProduct = updated;
      _actionStatus = SellerProductActionStatus.idle;
      notifyListeners();
      return updated;
    } catch (e) {
      _actionError = e.toString().replaceFirst('Exception: ', '');
      _actionStatus = SellerProductActionStatus.error;
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Remplace un produit dans la liste.
  void _replaceProduct(SellerProduct updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      final newList = List<SellerProduct>.from(_products);
      newList[index] = updated;
      _products = newList;
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Réinitialise complètement le provider.
  Future<void> reset() async {
    _listStatus = SellerProductListStatus.initial;
    _actionStatus = SellerProductActionStatus.idle;
    _products = [];
    _listError = null;
    _actionError = null;
    _kycStatus = null;
    _lastAffectedProduct = null;
    _search = '';
    _filterCategoryId = null;
    _filterStatus = 'all';
    _sortBy = 'created_at';
    _sortDir = 'desc';
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;

    await _repository.clearCache();

    notifyListeners();
  }


  /// Charge un produit par ID (détail ou retour de formulaire).
Future<SellerProduct?> loadProductById(int id) async {
  try {
    // 1. Chercher dans la liste locale
    for (final p in _products) {
      if (p.id == id) return p;
    }

    // 2. Sinon appeler l'API
    final product = await _repository.getProductById(id);

    // 3. Ajouter au cache local
    _products = [product, ..._products];
    notifyListeners();

    return product;
  } catch (e) {
    debugPrint('❌ Erreur loadProductById: $e');
    return null;
  }
}


  /// Efface les erreurs (liste + action).
  void clearErrors() {
    _listError = null;
    _actionError = null;

    if (_listStatus == SellerProductListStatus.error) {
      _listStatus = _products.isNotEmpty
          ? SellerProductListStatus.loaded
          : SellerProductListStatus.initial;
    }

    if (_actionStatus == SellerProductActionStatus.error) {
      _actionStatus = SellerProductActionStatus.idle;
    }

    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SellerProductProvider(listStatus: $_listStatus, '
        'products: ${_products.length}, total: $_total, '
        'actionStatus: $_actionStatus)';
  }
}