// Interface du repository des stocks
// Définit le contrat que le repository doit respecter

import '../entities/stock.dart';
import '../entities/stock_movement.dart';

abstract class StockRepository {
  /// Récupérer tous les stocks
  Future<List<Stock>> getStocks();

  /// Récupérer un stock par ID
  Future<Stock?> getStockById(int stockId);

  /// Récupérer le stock d'un produit
  Future<Stock?> getStockByProduct(int productId);

  /// Récupérer les stocks faibles
  Future<List<Stock>> getLowStocks();

  /// Récupérer les stocks épuisés
  Future<List<Stock>> getOutOfStock();

  /// Réserver du stock
  Future<Stock> reserveStock(int stockId, int quantity);

  /// Libérer du stock réservé
  Future<Stock> releaseStock(int stockId, int quantity);

  /// Ajuster le stock
  Future<Stock> adjustStock(int stockId, int newQuantity, String reason);

  /// Récupérer les mouvements de stock
  Future<List<StockMovement>> getStockMovements({int? stockId, int? productId});

  /// Ajouter un mouvement de stock
  Future<StockMovement> addStockMovement(StockMovement movement);

  /// Récupérer le nombre de stocks faibles
  Future<int> getLowStockCount();

  /// Vérifier si un produit a une alerte de stock
  Future<bool> hasStockAlert(int productId);

  /// Sauvegarder les stocks localement
  Future<void> saveStocks(List<Stock> stocks);

  /// Synchroniser avec le backend
  Future<List<Stock>> syncWithBackend();
}