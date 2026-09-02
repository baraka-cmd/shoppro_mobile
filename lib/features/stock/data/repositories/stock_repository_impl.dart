// Implémentation du repository des stocks
// Gère la logique métier avec stockage local

import '../../domain/entities/stock.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_repository.dart';
import '../models/stock_model.dart';
import '../models/stock_movement_model.dart';
import '../sources/stock_local_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDataSource _localDataSource;

  StockRepositoryImpl({StockLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? StockLocalDataSource();

  @override
  Future<List<Stock>> getStocks() async {
    final stocks = await _localDataSource.getStocks();
    stocks.sort((a, b) => a.availableQuantity.compareTo(b.availableQuantity));
    return stocks;
  }

  @override
  Future<Stock?> getStockById(int stockId) async {
    final stocks = await getStocks();
    for (final stock in stocks) {
      if (stock.id == stockId) {
        return stock;
      }
    }
    return null;
  }

  @override
  Future<Stock?> getStockByProduct(int productId) async {
    final stocks = await getStocks();
    for (final stock in stocks) {
      if (stock.productId == productId) {
        return stock;
      }
    }
    return null;
  }

  @override
  Future<List<Stock>> getLowStocks() async {
    final stocks = await getStocks();
    return stocks.where((s) => s.isLowStock).toList();
  }

  @override
  Future<List<Stock>> getOutOfStock() async {
    final stocks = await getStocks();
    return stocks.where((s) => s.isOutOfStock).toList();
  }

  @override
  Future<Stock> reserveStock(int stockId, int quantity) async {
    final stocks = await getStocks();
    final index = stocks.indexWhere((s) => s.id == stockId);

    if (index < 0) {
      throw Exception('Stock introuvable');
    }

    final stock = stocks[index];

    if (stock.availableQuantity < quantity) {
      throw Exception('Stock insuffisant');
    }

    final updatedStock = StockModel(
      id: stock.id,
      productId: stock.productId,
      productName: stock.productName,
      productImage: stock.productImage,
      productSku: stock.productSku,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      quantity: stock.quantity,
      reservedQuantity: stock.reservedQuantity + quantity,
      availableQuantity: stock.availableQuantity - quantity,
      minQuantity: stock.minQuantity,
      maxQuantity: stock.maxQuantity,
      unitCost: stock.unitCost,
      totalValue: stock.totalValue,
      lastCountedAt: stock.lastCountedAt,
      isActive: stock.isActive,
    );

    stocks[index] = updatedStock;
    await _localDataSource.saveStocks(stocks);

    // Ajouter le mouvement
    await addStockMovement(StockMovementModel(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: stock.productId,
      productName: stock.productName,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      type: 'reservation',
      quantity: quantity,
      quantityBefore: stock.availableQuantity,
      quantityAfter: stock.availableQuantity - quantity,
      reference: 'RES-${DateTime.now().millisecondsSinceEpoch}',
      note: 'Réservation de stock',
      createdAt: DateTime.now(),
    ));

    return updatedStock;
  }

  @override
  Future<Stock> releaseStock(int stockId, int quantity) async {
    final stocks = await getStocks();
    final index = stocks.indexWhere((s) => s.id == stockId);

    if (index < 0) {
      throw Exception('Stock introuvable');
    }

    final stock = stocks[index];

    if (stock.reservedQuantity < quantity) {
      throw Exception('Réservation insuffisante');
    }

    final updatedStock = StockModel(
      id: stock.id,
      productId: stock.productId,
      productName: stock.productName,
      productImage: stock.productImage,
      productSku: stock.productSku,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      quantity: stock.quantity,
      reservedQuantity: stock.reservedQuantity - quantity,
      availableQuantity: stock.availableQuantity + quantity,
      minQuantity: stock.minQuantity,
      maxQuantity: stock.maxQuantity,
      unitCost: stock.unitCost,
      totalValue: stock.totalValue,
      lastCountedAt: stock.lastCountedAt,
      isActive: stock.isActive,
    );

    stocks[index] = updatedStock;
    await _localDataSource.saveStocks(stocks);

    await addStockMovement(StockMovementModel(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: stock.productId,
      productName: stock.productName,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      type: 'release',
      quantity: quantity,
      quantityBefore: stock.availableQuantity,
      quantityAfter: stock.availableQuantity + quantity,
      reference: 'REL-${DateTime.now().millisecondsSinceEpoch}',
      note: 'Libération de stock réservé',
      createdAt: DateTime.now(),
    ));

    return updatedStock;
  }

  @override
  Future<Stock> adjustStock(int stockId, int newQuantity, String reason) async {
    final stocks = await getStocks();
    final index = stocks.indexWhere((s) => s.id == stockId);

    if (index < 0) {
      throw Exception('Stock introuvable');
    }

    final stock = stocks[index];
    final difference = newQuantity - stock.quantity;

    final updatedStock = StockModel(
      id: stock.id,
      productId: stock.productId,
      productName: stock.productName,
      productImage: stock.productImage,
      productSku: stock.productSku,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      quantity: newQuantity,
      reservedQuantity: stock.reservedQuantity,
      availableQuantity: stock.availableQuantity + difference,
      minQuantity: stock.minQuantity,
      maxQuantity: stock.maxQuantity,
      unitCost: stock.unitCost,
      totalValue: stock.unitCost != null ? stock.unitCost! * newQuantity : null,
      lastCountedAt: DateTime.now(),
      isActive: stock.isActive,
    );

    stocks[index] = updatedStock;
    await _localDataSource.saveStocks(stocks);

    await addStockMovement(StockMovementModel(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: stock.productId,
      productName: stock.productName,
      warehouseId: stock.warehouseId,
      warehouseName: stock.warehouseName,
      type: 'adjustment',
      quantity: difference,
      quantityBefore: stock.quantity,
      quantityAfter: newQuantity,
      reference: 'ADJ-${DateTime.now().millisecondsSinceEpoch}',
      note: reason,
      createdAt: DateTime.now(),
    ));

    return updatedStock;
  }

  @override
  Future<List<StockMovement>> getStockMovements({int? stockId, int? productId}) async {
    final movements = await _localDataSource.getMovements();
    movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (productId != null) {
      return movements.where((m) => m.productId == productId).toList();
    }

    return movements;
  }

  @override
  Future<StockMovement> addStockMovement(StockMovement movement) async {
    final movements = await _localDataSource.getMovements();
    movements.add(movement);
    await _localDataSource.saveMovements(movements);
    return movement;
  }

  @override
  Future<int> getLowStockCount() async {
    final lowStocks = await getLowStocks();
    return lowStocks.length;
  }

  @override
  Future<bool> hasStockAlert(int productId) async {
    final stock = await getStockByProduct(productId);
    return stock != null && stock.isLowStock;
  }

  @override
  Future<void> saveStocks(List<Stock> stocks) async {
    await _localDataSource.saveStocks(stocks);
  }

  @override
  Future<List<Stock>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getStocks();
  }
}