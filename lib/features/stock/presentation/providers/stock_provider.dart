// Provider des stocks
// Gère l'état des stocks et les actions

import 'package:flutter/foundation.dart';
import '../../domain/entities/stock.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../data/repositories/stock_repository_impl.dart';

enum StockStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class StockProvider extends ChangeNotifier {
  final StockRepository _stockRepository;

  StockProvider({StockRepository? stockRepository})
      : _stockRepository = stockRepository ?? StockRepositoryImpl();

  StockStatus _status = StockStatus.initial;
  List<Stock> _stocks = [];
  List<StockMovement> _movements = [];
  String? _errorMessage;

  // Getters
  StockStatus get status => _status;
  List<Stock> get stocks => _stocks;
  List<StockMovement> get movements => _movements;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == StockStatus.loading;
  bool get hasError => _status == StockStatus.error;
  bool get isEmpty => _stocks.isEmpty;
  int get stocksCount => _stocks.length;

  /// Stocks faibles
  List<Stock> get lowStocks => _stocks.where((s) => s.isLowStock).toList();

  /// Stocks épuisés
  List<Stock> get outOfStock => _stocks.where((s) => s.isOutOfStock).toList();

  /// Stocks en stock
  List<Stock> get inStock => _stocks.where((s) => !s.isLowStock && !s.isOutOfStock).toList();

  /// Nombre de stocks faibles
  int get lowStockCount => lowStocks.length;

  /// Nombre de stocks épuisés
  int get outOfStockCount => outOfStock.length;

  /// Charger les stocks
  Future<void> loadStocks() async {
    _setStatus(StockStatus.loading);
    _clearError();

    try {
      _stocks = await _stockRepository.getStocks();
      _setStatus(StockStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(StockStatus.error);
    }

    notifyListeners();
  }

  /// Charger les mouvements
  Future<void> loadMovements({int? productId}) async {
    try {
      _movements = await _stockRepository.getStockMovements(productId: productId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
    }
  }

  /// Réserver du stock
  Future<bool> reserveStock(int stockId, int quantity) async {
    _setStatus(StockStatus.updating);

    try {
      final stock = await _stockRepository.reserveStock(stockId, quantity);
      _stocks = await _stockRepository.getStocks();
      await loadMovements(productId: stock.productId);
      _setStatus(StockStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(StockStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Libérer du stock
  Future<bool> releaseStock(int stockId, int quantity) async {
    _setStatus(StockStatus.updating);

    try {
      final stock = await _stockRepository.releaseStock(stockId, quantity);
      _stocks = await _stockRepository.getStocks();
      await loadMovements(productId: stock.productId);
      _setStatus(StockStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(StockStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Ajuster le stock
  Future<bool> adjustStock(int stockId, int newQuantity, String reason) async {
    _setStatus(StockStatus.updating);

    try {
      final stock = await _stockRepository.adjustStock(stockId, newQuantity, reason);
      _stocks = await _stockRepository.getStocks();
      await loadMovements(productId: stock.productId);
      _setStatus(StockStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(StockStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Vérifier si un produit a une alerte
  Future<bool> hasStockAlert(int productId) async {
    return await _stockRepository.hasStockAlert(productId);
  }

  /// Récupérer un stock par ID
  Stock? getStockById(int stockId) {
    for (final stock in _stocks) {
      if (stock.id == stockId) return stock;
    }
    return null;
  }

  /// Récupérer un stock par produit
  Stock? getStockByProduct(int productId) {
    for (final stock in _stocks) {
      if (stock.productId == productId) return stock;
    }
    return null;
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(StockStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}