// ============================================
// PROVIDER : SellerStockProvider
// ============================================
// Gestion d'état pour les stocks vendeur.
//
// Responsabilités :
//   - Chargement paginé avec filtres (statut, entrepôt, recherche)
//   - Filtres par onglets (Tous, Stock bas, Rupture)
//   - Ajustement de stock (avec sync automatique côté backend)
//   - Historique des mouvements (pagination)
//   - Statistiques globales (total, alerts)
//   - Gestion des erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_stock.dart';

// Data
import '../../data/sources/seller_stock_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerStockListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  forbidden,
  unauthorized,
}

enum SellerStockActionStatus {
  idle,
  adjusting,
  loadingMovements,
  error,
}

// ============================================
// ONGLETS (TABS) DE FILTRE
// ============================================

enum SellerStockTab {
  all('all', 'Tous'),
  lowStock('low_stock', 'Stock bas'),
  outOfStock('out_of_stock', 'Rupture');

  final String statusCode;
  final String label;

  const SellerStockTab(this.statusCode, this.label);
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerStockProvider extends ChangeNotifier {
  final SellerStockApi _api;

  SellerStockProvider({SellerStockApi? api}) : _api = api ?? SellerStockApi();

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerStockListStatus _listStatus = SellerStockListStatus.initial;
  List<SellerStock> _stocks = [];
  String? _listError;
  String? _kycStatus;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 20;

  // Filtres
  SellerStockTab _activeTab = SellerStockTab.all;
  String _search = '';
  int? _filterWarehouseId;
  String _sortBy = 'updated_at';
  String _sortDir = 'desc';

  // Stats
  SellerStockStats _stats = const SellerStockStats.empty();

  // ============================================
  // ÉTAT : DÉTAIL
  // ============================================

  SellerStock? _currentStock;
  List<SellerStockMovement> _currentStockMovements = [];
  bool _isLoadingDetail = false;
  String? _detailError;

  // ============================================
  // ÉTAT : MOUVEMENTS (historique global)
  // ============================================

  List<SellerStockMovement> _movements = [];
  bool _isLoadingMovements = false;
  bool _hasMoreMovements = false;
  int _movementsCurrentPage = 1;
  String? _movementsError;


    // ============================================
  // ÉTAT : MOUVEMENTS D'UN STOCK SPÉCIFIQUE
  // ============================================

  List<SellerStockMovement> _stockMovements = [];
  bool _isLoadingStockMovements = false;
  bool _hasMoreStockMovements = false;
  int _stockMovementsCurrentPage = 1;
  String? _stockMovementsError;
  int? _currentStockId;
  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerStockActionStatus _actionStatus = SellerStockActionStatus.idle;
  String? _actionError;
  int? _lastAdjustedStockId;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerStockListStatus get listStatus => _listStatus;
  List<SellerStock> get stocks => List.unmodifiable(_stocks);
  String? get listError => _listError;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _listStatus == SellerStockListStatus.loading;
  bool get isLoaded => _listStatus == SellerStockListStatus.loaded;
  bool get isLoadingMore => _listStatus == SellerStockListStatus.loadingMore;
  bool get hasError => _listStatus == SellerStockListStatus.error;
  bool get isForbidden => _listStatus == SellerStockListStatus.forbidden;
  bool get isUnauthorized => _listStatus == SellerStockListStatus.unauthorized;

  bool get isEmpty => _stocks.isEmpty;
  int get stocksCount => _stocks.length;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _hasMore;

  SellerStockTab get activeTab => _activeTab;
  String get search => _search;
  int? get filterWarehouseId => _filterWarehouseId;
  String get sortBy => _sortBy;
  String get sortDir => _sortDir;

  bool get hasActiveFilters =>
      _activeTab != SellerStockTab.all ||
      _search.isNotEmpty ||
      _filterWarehouseId != null;



  
  // ============================================
  // GETTERS : STATS
  // ============================================

  SellerStockStats get stats => _stats;

  int get totalStocks => _stats.total;
  int get inStockCount => _stats.inStock;
  int get lowStockCount => _stats.lowStock;
  int get outOfStockCount => _stats.outOfStock;
  int get needsAttentionCount => _stats.needsAttention;
  int get totalAvailable => _stats.totalAvailable;
  int get totalReserved => _stats.totalReserved;

  bool get hasAlerts => _stats.hasAlerts;
  bool get hasCriticalAlerts => _stats.hasCriticalAlerts;

  /// Retourne le count d'un onglet donné.
  int getCountForTab(SellerStockTab tab) {
    switch (tab) {
      case SellerStockTab.all:
        return _stats.total;
      case SellerStockTab.lowStock:
        return _stats.lowStock;
      case SellerStockTab.outOfStock:
        return _stats.outOfStock;
    }
  }

    // ============================================
  // GETTERS : MOUVEMENTS D'UN STOCK
  // ============================================

  List<SellerStockMovement> get stockMovements =>
      List.unmodifiable(_stockMovements);
  bool get isLoadingStockMovements => _isLoadingStockMovements;
  bool get hasMoreStockMovements => _hasMoreStockMovements;
  String? get stockMovementsError => _stockMovementsError;
  // ============================================
  // GETTERS : DÉTAIL
  // ============================================

  SellerStock? get currentStock => _currentStock;
  List<SellerStockMovement> get currentStockMovements =>
      List.unmodifiable(_currentStockMovements);
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;
  bool get hasCurrentStock => _currentStock != null;

  // ============================================
  // GETTERS : MOUVEMENTS
  // ============================================

  List<SellerStockMovement> get movements => List.unmodifiable(_movements);
  bool get isLoadingMovements => _isLoadingMovements;
  bool get hasMoreMovements => _hasMoreMovements;
  String? get movementsError => _movementsError;

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerStockActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  int? get lastAdjustedStockId => _lastAdjustedStockId;

  bool get isAdjusting => _actionStatus == SellerStockActionStatus.adjusting;
  bool get hasActionError => _actionStatus == SellerStockActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerStockActionStatus.idle &&
      _actionStatus != SellerStockActionStatus.error;

  // ============================================
  // CHARGEMENT DE LA LISTE
  // ============================================

  /// Charge la première page avec les filtres actifs.
  Future<void> loadStocks({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerStockListStatus.loading;
    _listError = null;
    _kycStatus = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getStocks(
        page: 1,
        perPage: _perPage,
        status: _activeTab.statusCode,
        search: _search.isNotEmpty ? _search : null,
        warehouseId: _filterWarehouseId,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _stocks = result.stocks;
      _stats = result.stats;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerStockListStatus.loaded;
    } on SellerStockForbiddenException catch (e) {
      _listStatus = SellerStockListStatus.forbidden;
      _listError = e.message;
      _kycStatus = e.code;
    } on SellerStockUnauthorizedException catch (e) {
      _listStatus = SellerStockListStatus.unauthorized;
      _listError = e.message;
    } catch (e) {
      _listStatus = SellerStockListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge la page suivante (pagination infinie).
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerStockListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _api.getStocks(
        page: nextPage,
        perPage: _perPage,
        status: _activeTab.statusCode,
        search: _search.isNotEmpty ? _search : null,
        warehouseId: _filterWarehouseId,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _stocks = [..._stocks, ...result.stocks];
      _stats = result.stats;
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerStockListStatus.loaded;
    } catch (e) {
      _listStatus = SellerStockListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit la liste.
  Future<void> refresh() async {
    await loadStocks(forceRefresh: true);
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Change l'onglet actif.
  Future<void> setActiveTab(SellerStockTab tab) async {
    if (_activeTab == tab) return;
    _activeTab = tab;
    _stocks = [];
    await loadStocks();
  }

  /// Change la recherche.
  Future<void> setSearch(String value) async {
    _search = value.trim();
    await loadStocks();
  }

  /// Change le filtre entrepôt.
  Future<void> setWarehouseFilter(int? warehouseId) async {
    _filterWarehouseId = warehouseId;
    await loadStocks();
  }

  /// Change le tri.
  Future<void> setSort(String sortBy, {String? sortDir}) async {
    _sortBy = sortBy;
    if (sortDir != null) _sortDir = sortDir;
    await loadStocks();
  }

  /// Efface tous les filtres.
  Future<void> clearFilters() async {
    _activeTab = SellerStockTab.all;
    _search = '';
    _filterWarehouseId = null;
    _sortBy = 'updated_at';
    _sortDir = 'desc';
    await loadStocks();
  }

  // ============================================
  // DÉTAIL
  // ============================================

  /// Charge le détail d'un stock.
  Future<void> loadStockDetail(int stockId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _currentStock = null;
    _currentStockMovements = [];
    notifyListeners();

    try {
      final result = await _api.getStockById(stockId);
      _currentStock = result.stock;
      _currentStockMovements = result.recentMovements;
      _isLoadingDetail = false;
    } catch (e) {
      _isLoadingDetail = false;
      _detailError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }


    /// Charge les mouvements d'un stock spécifique (avec pagination).
  Future<void> loadStockMovements(
    int stockId, {
    bool forceRefresh = false,
  }) async {
    if (isLoadingStockMovements && !forceRefresh) return;

    _isLoadingStockMovements = true;
    _stockMovementsError = null;
    _stockMovementsCurrentPage = 1;
    _currentStockId = stockId;
    notifyListeners();

    try {
      final result = await _api.getMovements(
        page: 1,
        perPage: _perPage,
        productId: _currentStock?.productId,
      );

      _stockMovements = result.movements;
      _stockMovementsCurrentPage = result.currentPage;
      _hasMoreStockMovements = result.hasMore;
      _isLoadingStockMovements = false;
    } catch (e) {
      _isLoadingStockMovements = false;
      _stockMovementsError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge plus de mouvements d'un stock spécifique.
  Future<void> loadMoreStockMovements() async {
    if (isLoadingStockMovements || !_hasMoreStockMovements) return;
    if (_currentStockId == null) return;

    _isLoadingStockMovements = true;
    notifyListeners();

    try {
      final nextPage = _stockMovementsCurrentPage + 1;
      final result = await _api.getMovements(
        page: nextPage,
        perPage: _perPage,
        productId: _currentStock?.productId,
      );

      _stockMovements = [..._stockMovements, ...result.movements];
      _stockMovementsCurrentPage = result.currentPage;
      _hasMoreStockMovements = result.hasMore;
      _isLoadingStockMovements = false;
    } catch (e) {
      _isLoadingStockMovements = false;
      _stockMovementsError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Efface le détail courant.
    /// Efface le détail courant.
  void clearCurrentStock() {
    _currentStock = null;
    _currentStockMovements = [];
    _stockMovements = [];
    _currentStockId = null;
    _detailError = null;
    _stockMovementsError = null;
    _hasMoreStockMovements = false;
    _stockMovementsCurrentPage = 1;
    _actionStatus = SellerStockActionStatus.idle;
    _actionError = null;
    _lastAdjustedStockId = null;
    notifyListeners();
  }

  // ============================================
  // MOUVEMENTS
  // ============================================

  /// Charge l'historique des mouvements.
  Future<void> loadMovements({
    bool forceRefresh = false,
    int? productId,
    String? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (isLoadingMovements && !forceRefresh) return;

    _isLoadingMovements = true;
    _movementsError = null;
    _movementsCurrentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getMovements(
        page: 1,
        perPage: _perPage,
        productId: productId,
        type: type,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      _movements = result.movements;
      _movementsCurrentPage = result.currentPage;
      _hasMoreMovements = result.hasMore;
      _isLoadingMovements = false;
    } catch (e) {
      _isLoadingMovements = false;
      _movementsError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge plus de mouvements.
  Future<void> loadMoreMovements() async {
    if (isLoadingMovements || !_hasMoreMovements) return;

    _isLoadingMovements = true;
    notifyListeners();

    try {
      final nextPage = _movementsCurrentPage + 1;
      final result = await _api.getMovements(
        page: nextPage,
        perPage: _perPage,
      );

      _movements = [..._movements, ...result.movements];
      _movementsCurrentPage = result.currentPage;
      _hasMoreMovements = result.hasMore;
      _isLoadingMovements = false;
    } catch (e) {
      _isLoadingMovements = false;
      _movementsError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // ============================================
  // ACTION : AJUSTEMENT
  // ============================================

  /// Ajuste la quantité d'un stock.
  Future<SellerStockAdjustResult?> adjustStock(
    int stockId, {
    required int quantity,
    required String reason,
    String? note,
  }) async {
    _actionStatus = SellerStockActionStatus.adjusting;
    _actionError = null;
    _lastAdjustedStockId = stockId;
    notifyListeners();

    try {
      final result = await _api.adjustStock(
        stockId,
        quantity: quantity,
        reason: reason,
        note: note,
      );

      // Mettre à jour le stock dans la liste
      final index = _stocks.indexWhere((s) => s.id == stockId);
      if (index != -1) {
        final newList = List<SellerStock>.from(_stocks);
        newList[index] = result.stock;
        _stocks = newList;
      }

      // Mettre à jour le détail si on est dessus
      if (_currentStock?.id == stockId) {
        _currentStock = result.stock;
      }

      _actionStatus = SellerStockActionStatus.idle;
      notifyListeners();

      // Rafraîchir les stats en arrière-plan
      _refreshStatsInBackground();

      return result;
    } catch (e) {
      _actionStatus = SellerStockActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Rafraîchit les stats en arrière-plan.
  Future<void> _refreshStatsInBackground() async {
    try {
      final result = await _api.getStocks(page: 1, perPage: 1);
      _stats = result.stats;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Impossible de rafraîchir les stats: $e');
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs.
  void clearErrors() {
    _listError = null;
    _actionError = null;
    _detailError = null;
    _movementsError = null;
    _lastAdjustedStockId = null;

    if (_listStatus == SellerStockListStatus.error) {
      _listStatus = _stocks.isNotEmpty
          ? SellerStockListStatus.loaded
          : SellerStockListStatus.initial;
    }

    if (_actionStatus == SellerStockActionStatus.error) {
      _actionStatus = SellerStockActionStatus.idle;
    }

    notifyListeners();
  }

  /// Réinitialise complètement le provider (logout).
  void reset() {
    _listStatus = SellerStockListStatus.initial;
    _actionStatus = SellerStockActionStatus.idle;
    _stocks = [];
    _currentStock = null;
    _currentStockMovements = [];
    _stockMovements = [];
    _currentStockId = null;
    _stockMovementsError = null;
    _hasMoreStockMovements = false;
    _stockMovementsCurrentPage = 1;
    _isLoadingStockMovements = false;
    _movements = [];
    _listError = null;
    _actionError = null;
    _detailError = null;
    _movementsError = null;
    _lastAdjustedStockId = null;
    _kycStatus = null;
    _activeTab = SellerStockTab.all;
    _search = '';
    _filterWarehouseId = null;
    _sortBy = 'updated_at';
    _sortDir = 'desc';
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;
    _isLoadingDetail = false;
    _isLoadingMovements = false;
    _hasMoreMovements = false;
    _movementsCurrentPage = 1;
    _stats = const SellerStockStats.empty();
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerStockProvider(tab: ${_activeTab.label}, '
        'stocks: ${_stocks.length}, total: $_total, '
        'actionStatus: $_actionStatus)';
  }
}