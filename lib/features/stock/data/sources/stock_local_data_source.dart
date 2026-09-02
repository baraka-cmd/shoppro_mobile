// Source de données locale des stocks
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/stock.dart';
import '../../domain/entities/stock_movement.dart';
import '../models/stock_model.dart';
import '../models/stock_movement_model.dart';

class StockLocalDataSource {
  static final StockLocalDataSource _instance = StockLocalDataSource._internal();
  factory StockLocalDataSource() => _instance;
  StockLocalDataSource._internal();

  static const String _stocksKey = 'stocks_data';
  static const String _movementsKey = 'stock_movements_data';

  /// Sauvegarder les stocks
  Future<void> saveStocks(List<Stock> stocks) async {
    final prefs = await SharedPreferences.getInstance();
    final stocksJson = jsonEncode(
      stocks.map((s) => s.toJson()).toList(),
    );
    await prefs.setString(_stocksKey, stocksJson);
  }

  /// Récupérer les stocks
  Future<List<Stock>> getStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final stocksJson = prefs.getString(_stocksKey);

    if (stocksJson == null || stocksJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(stocksJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => StockModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder les mouvements
  Future<void> saveMovements(List<StockMovement> movements) async {
    final prefs = await SharedPreferences.getInstance();
    final movementsJson = jsonEncode(
      movements.map((m) => m.toJson()).toList(),
    );
    await prefs.setString(_movementsKey, movementsJson);
  }

  /// Récupérer les mouvements
  Future<List<StockMovement>> getMovements() async {
    final prefs = await SharedPreferences.getInstance();
    final movementsJson = prefs.getString(_movementsKey);

    if (movementsJson == null || movementsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(movementsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => StockMovementModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer les stocks
  Future<void> clearStocks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stocksKey);
  }

  /// Effacer les mouvements
  Future<void> clearMovements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_movementsKey);
  }
}