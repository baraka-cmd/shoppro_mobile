// ============================================
// API SOURCE : AdminStockApi
// ============================================
// Source de données pour les stocks admin.
// Utilise les endpoints /admin/stocks.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AdminStockApi {
  final Dio _dio;

  AdminStockApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Récupère la liste des stocks.
  Future<Map<String, dynamic>> getStocks() async {
    final response = await _dio.get('/admin/stocks');
    return _parseResponse(response);
  }

  /// Récupère les mouvements de stock.
  Future<Map<String, dynamic>> getMovements() async {
    final response = await _dio.get('/admin/stocks/movements');
    return _parseResponse(response);
  }

  /// Réserve du stock.
  Future<Map<String, dynamic>> reserveStock(int stockId, int quantity) async {
    final response = await _dio.post(
      '/admin/stocks/$stockId/reserve',
      data: {'quantity': quantity},
    );
    return _parseResponse(response);
  }

  /// Libère du stock réservé.
  Future<Map<String, dynamic>> releaseStock(int stockId, int quantity) async {
    final response = await _dio.post(
      '/admin/stocks/$stockId/release',
      data: {'quantity': quantity},
    );
    return _parseResponse(response);
  }

  /// Ajuste le stock.
  Future<Map<String, dynamic>> adjustStock(int stockId, int newQuantity) async {
    final response = await _dio.post(
      '/admin/stocks/$stockId/adjust',
      data: {'new_quantity': newQuantity},
    );
    return _parseResponse(response);
  }

  /// Vérifie si un stock a une alerte.
  Future<bool> hasStockAlert(int stockId) async {
    try {
      final response = await _dio.get('/admin/stocks/$stockId');
      final data = response.data;
      if (data is Map) {
        final stock = Map<String, dynamic>.from(data);
        return stock['is_low_stock'] == true || stock['is_out_of_stock'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }
}