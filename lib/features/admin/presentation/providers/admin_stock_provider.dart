// ============================================
// PROVIDER : AdminStockProvider
// ============================================
// Provider de gestion d'état pour la gestion des stocks.
// Utilise AdminStockApi directement (pas de StockRepository).
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features - stock)
import '../../../stock/domain/entities/stock.dart';

// API Sources (même feature admin)
import '../../data/sources/admin_stock_api.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider stocks admin
enum AdminStockStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des stocks pour l'administration.
///
/// Utilise AdminStockApi pour les appels API directs.
class AdminStockProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminStockApi _api;

  // ============================================
  // ÉTAT
  // ============================================

  AdminStockStatus _status = AdminStockStatus.initial;
  List<Stock> _stocks = [];
  List<Map<String, dynamic>> _movements = [];
  String? _errorMessage;

  // Filtres
  bool _showLowStockOnly = false;
  bool _showOutOfStockOnly = false;
  String _searchQuery = '';

  // Statistiques
  int _totalStocks = 0;
  int _lowStocks = 0;
  int _outOfStocks = 0;
  int _totalQuantity = 0;
  int _totalReserved = 0;
  int _totalAvailable = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminStockProvider({AdminStockApi? api}) : _api = api ?? AdminStockApi();

  // ============================================
  // GETTERS
  // ============================================

  AdminStockStatus get status => _status;
  List<Stock> get stocks => List.unmodifiable(_stocks);
  List<Map<String, dynamic>> get movements => List.unmodifiable(_movements);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AdminStockStatus.loading;
  bool get isLoaded => _status == AdminStockStatus.loaded;
  bool get isUpdating => _status == AdminStockStatus.updating;
  bool get hasError => _status == AdminStockStatus.error;
  int get stocksCount => _stocks.length;
  bool get isEmpty => _stocks.isEmpty;

  // Filtres
  bool get showLowStockOnly => _showLowStockOnly;
  bool get showOutOfStockOnly => _showOutOfStockOnly;
  String get searchQuery => _searchQuery;

  // Statistiques
  int get totalStocks => _totalStocks;
  int get lowStocks => _lowStocks;
  int get outOfStocks => _outOfStocks;
  int get totalQuantity => _totalQuantity;
  int get totalReserved => _totalReserved;
  int get totalAvailable => _totalAvailable;

  /// Stocks filtrés
  List<Stock> get filteredStocks {
    var result = _stocks;

    if (_showLowStockOnly) {
      result = result.where((s) => s.isLowStock).toList();
    }

    if (_showOutOfStockOnly) {
      result = result.where((s) => s.isOutOfStock).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((s) =>
              s.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  /// Stocks en alerte (faible ou rupture)
  List<Stock> get alertStocks =>
      _stocks.where((s) => s.isLowStock || s.isOutOfStock).toList();

  /// Nombre d'alertes
  int get alertCount => alertStocks.length;

  /// Vrai s'il y a des alertes
  bool get hasAlerts => alertCount > 0;

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge les stocks.
  Future<void> loadStocks() async {
    _status = AdminStockStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getStocks();
      final data = response['data'];

      if (data is List) {
        _stocks = data
            .whereType<Map>()
            .map((e) => Stock.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      _status = AdminStockStatus.loaded;
      _computeStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStockStatus.error;
      debugPrint('Erreur loadStocks: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshStocks() async {
    try {
      final response = await _api.getStocks();
      final data = response['data'];

      if (data is List) {
        _stocks = data
            .whereType<Map>()
            .map((e) => Stock.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      _status = AdminStockStatus.loaded;
      _computeStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshStocks: $e');
    }

    notifyListeners();
  }

  /// Charge les mouvements de stock.
  Future<void> loadMovements() async {
    try {
      final response = await _api.getMovements();
      final data = response['data'];

      if (data is List) {
        _movements = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur loadMovements: $e');
      notifyListeners();
    }
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Toggle le filtre stock faible.
  void toggleLowStockFilter() {
    _showLowStockOnly = !_showLowStockOnly;
    if (_showLowStockOnly) _showOutOfStockOnly = false;
    notifyListeners();
  }

  /// Toggle le filtre rupture.
  void toggleOutOfStockFilter() {
    _showOutOfStockOnly = !_showOutOfStockOnly;
    if (_showOutOfStockOnly) _showLowStockOnly = false;
    notifyListeners();
  }

  /// Recherche par nom de produit.
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Efface les filtres.
  void clearFilters() {
    _showLowStockOnly = false;
    _showOutOfStockOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================
  // ACTIONS STOCK
  // ============================================

  /// Réserve du stock.
  Future<bool> reserveStock(int stockId, int quantity) async {
    _status = AdminStockStatus.updating;
    notifyListeners();

    try {
      await _api.reserveStock(stockId, quantity);
      await refreshStocks();
      _status = AdminStockStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStockStatus.error;
      debugPrint('Erreur reserveStock: $e');
      notifyListeners();
      return false;
    }
  }

  /// Libère du stock.
  Future<bool> releaseStock(int stockId, int quantity) async {
    _status = AdminStockStatus.updating;
    notifyListeners();

    try {
      await _api.releaseStock(stockId, quantity);
      await refreshStocks();
      _status = AdminStockStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStockStatus.error;
      debugPrint('Erreur releaseStock: $e');
      notifyListeners();
      return false;
    }
  }

  /// Ajuste le stock.
  Future<bool> adjustStock(int stockId, int newQuantity) async {
    _status = AdminStockStatus.updating;
    notifyListeners();

    try {
      await _api.adjustStock(stockId, newQuantity);
      await refreshStocks();
      _status = AdminStockStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStockStatus.error;
      debugPrint('Erreur adjustStock: $e');
      notifyListeners();
      return false;
    }
  }

  /// Vérifie si un stock a une alerte.
  Future<bool> hasStockAlert(int stockId) async {
    return await _api.hasStockAlert(stockId);
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Calcule les statistiques.
  void _computeStatistics() {
    _totalStocks = _stocks.length;
    _lowStocks = _stocks.where((s) => s.isLowStock).length;
    _outOfStocks = _stocks.where((s) => s.isOutOfStock).length;
    _totalQuantity = _stocks.fold(0, (sum, s) => sum + s.quantity);
    _totalReserved = _stocks.fold(0, (sum, s) => sum + s.reservedQuantity);
    _totalAvailable = _stocks.fold(0, (sum, s) => sum + s.availableQuantity);
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminStockStatus.initial;
    _stocks = [];
    _movements = [];
    _errorMessage = null;
    _showLowStockOnly = false;
    _showOutOfStockOnly = false;
    _searchQuery = '';
    _totalStocks = 0;
    _lowStocks = 0;
    _outOfStocks = 0;
    _totalQuantity = 0;
    _totalReserved = 0;
    _totalAvailable = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminStockProvider(status: $_status, stocks: ${_stocks.length}, '
        'low: $_lowStocks, out: $_outOfStocks, total: $_totalQuantity)';
  }
}