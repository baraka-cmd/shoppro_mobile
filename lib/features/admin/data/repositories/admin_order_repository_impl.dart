// ============================================
// REPOSITORY IMPL : AdminOrderRepositoryImpl
// ============================================
// Implémentation concrète du repository de gestion des commandes.
// Cette classe implémente l'interface [AdminOrderRepository]
// et orchestre les appels API pour la gestion des commandes.
//
// Responsabilités :
// - Appels API via AdminOrderApi
// - Transformation des données
// - Changement de statut
// - Gestion des paiements
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features)
import '../../../orders/domain/entities/order.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_order_repository.dart';

// Sources (même feature admin)
import '../sources/admin_order_api.dart';

// Ajouter l'import du OrderModel
import '../../../orders/data/models/order_model.dart';


// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository de gestion des commandes.
///
/// Gère toutes les opérations de gestion des commandes administrées.
class AdminOrderRepositoryImpl implements AdminOrderRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminOrderApi _api;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminOrderRepositoryImpl({AdminOrderApi? api}) : _api = api ?? AdminOrderApi();

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  @override
  Future<List<Order>> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
    String? paymentStatus,
    int? userId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _api.getOrders(
        page: page,
        perPage: perPage,
        status: status,
        paymentStatus: paymentStatus,
        userId: userId,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> searchOrders(String query, {int limit = 20}) async {
    try {
      final response = await _api.searchOrders(query, limit: limit);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur searchOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getPendingOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getPendingOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getPendingOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getConfirmedOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getConfirmedOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getConfirmedOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getProcessingOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getProcessingOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getProcessingOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getShippedOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getShippedOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getShippedOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getDeliveredOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getDeliveredOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getDeliveredOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getCancelledOrders({int page = 1, int perPage = 20}) async {
    try {
      final response = await _api.getCancelledOrders(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getCancelledOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getReturnedOrders({int page = 1, int perPage = 20}) async {
    return getOrders(status: 'returned', page: page, perPage: perPage);
  }

  @override
  Future<List<Order>> getOrdersByUser(int userId) async {
    try {
      final response = await _api.getOrdersByUser(userId);
      final data = response['data'];
      if (data is List) {
        return _parseOrders(data);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOrdersByUser: $e');
      rethrow;
    }
  }

  @override
  Future<List<Order>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getOrders(startDate: startDate, endDate: endDate);
  }

  // ============================================
  // DÉTAILS
  // ============================================

  @override
Future<Order?> getOrderById(int id) async {
  try {
    final response = await _api.getOrderById(id);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return _parseOrder(data);
    }
    if (data is Map) {
      return _parseOrder(Map<String, dynamic>.from(data));
    }
    return null;
  } catch (e) {
    debugPrint('Erreur getOrderById: $e');
    rethrow;
  }
}

@override
Future<Order?> getOrderByNumber(String orderNumber) async {
  try {
    final response = await _api.getOrderByNumber(orderNumber);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return _parseOrder(data);
    }
    if (data is Map) {
      return _parseOrder(Map<String, dynamic>.from(data));
    }
    return null;
  } catch (e) {
    debugPrint('Erreur getOrderByNumber: $e');
    rethrow;
  }
}

  

  @override
  Future<List<Map<String, dynamic>>> getOrderStatusHistory(int orderId) async {
    try {
      final response = await _api.getOrderStatusHistory(orderId);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOrderStatusHistory: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrderTracking(int orderId) async {
    try {
      final response = await _api.getOrderTracking(orderId);
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getOrderTracking: $e');
      rethrow;
    }
  }

  // ============================================
  // CHANGEMENT DE STATUT
  // ============================================

  @override
  Future<bool> confirmOrder(int orderId) async {
    try {
      final response = await _api.confirmOrder(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur confirmOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> processOrder(int orderId) async {
    try {
      final response = await _api.processOrder(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur processOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> shipOrder(int orderId, {String? trackingNumber, String? carrier}) async {
    try {
      final response = await _api.shipOrder(
        orderId,
        trackingNumber: trackingNumber,
        carrier: carrier,
      );
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur shipOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deliverOrder(int orderId) async {
    try {
      final response = await _api.deliverOrder(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deliverOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _api.cancelOrder(orderId, reason: reason);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur cancelOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> refundOrder(int orderId) async {
    try {
      final response = await _api.refundOrder(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur refundOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> returnOrder(int orderId, {String? reason}) async {
    try {
      final response = await _api.returnOrder(orderId, reason: reason);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur returnOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreOrder(int orderId) async {
    try {
      final response = await _api.restoreOrder(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur restoreOrder: $e');
      rethrow;
    }
  }

  // ============================================
  // PAIEMENT
  // ============================================

  @override
  Future<bool> markPaymentAsPaid(int orderId) async {
    try {
      final response = await _api.markPaymentAsPaid(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markPaymentAsPaid: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markPaymentAsFailed(int orderId) async {
    try {
      final response = await _api.markPaymentAsFailed(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markPaymentAsFailed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markPaymentAsRefunded(int orderId) async {
    try {
      final response = await _api.markPaymentAsRefunded(orderId);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markPaymentAsRefunded: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderPayments(int orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return [];
      // Récupérer les paiements depuis l'ordre ou via l'API
      return [];
    } catch (e) {
      debugPrint('Erreur getOrderPayments: $e');
      rethrow;
    }
  }

  // ============================================
  // NOTES ADMIN
  // ============================================

  @override
  Future<bool> addAdminNote(int orderId, String note) async {
    try {
      final response = await _api.addAdminNote(orderId, note);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur addAdminNote: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAdminNotes(int orderId) async {
    try {
      final response = await _api.getAdminNotes(orderId);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getAdminNotes: $e');
      rethrow;
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalOrdersCount() async {
    try {
      final response = await _api.getTotalOrdersCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalOrdersCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getOrdersCountByStatus() async {
    try {
      final response = await _api.getOrdersCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getOrdersCountByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getOrdersCountByPaymentStatus() async {
    try {
      final response = await _api.getOrdersCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getOrdersCountByPaymentStatus: $e');
      rethrow;
    }
  }

  @override
  Future<double> getTotalRevenue() async {
    try {
      final response = await _api.getTotalRevenue();
      final data = response['data'];
      if (data is Map) {
        return (data['total'] as num?)?.toDouble() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalRevenue: $e');
      rethrow;
    }
  }

  @override
  Future<double> getAverageOrderValue() async {
    final total = await getTotalRevenue();
    final count = await getTotalOrdersCount();
    if (count == 0) return 0;
    return total / count;
  }

  @override
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    return getOrders(perPage: limit, sortBy: 'created_at', sortDirection: 'desc');
  }

  @override
  Future<List<Order>> getHighestValueOrders({int limit = 10}) async {
    return getOrders(perPage: limit, sortBy: 'total', sortDirection: 'desc');
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  @override
  Future<bool> deleteOrder(int id) async {
    try {
      final response = await _api.deleteOrder(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteOrder: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreOrderById(int id) async {
    try {
      final response = await _api.restoreOrder(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur restoreOrderById: $e');
      rethrow;
    }
  }

  @override
  Future<bool> forceDeleteOrder(int id) async {
    try {
      final response = await _api.deleteOrder(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur forceDeleteOrder: $e');
      rethrow;
    }
  }

  // ============================================
  // PAGINATION
  // ============================================

  @override
  Future<bool> hasMoreOrders({required int page, int perPage = 20}) async {
    final orders = await getOrders(page: page + 1, perPage: perPage);
    return orders.isNotEmpty;
  }

  @override
  Future<int> getTotalPages({int perPage = 20}) async {
    final total = await getTotalOrdersCount();
    return (total / perPage).ceil();
  }

  // ============================================
  // HELPERS PRIVÉS DE PARSING
  // ============================================

  /// Parse une liste de commandes depuis le JSON.
List<Order> _parseOrders(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((e) => _parseOrder(Map<String, dynamic>.from(e)))
      .toList();
}

  /// Parse une commande depuis le JSON.

  Order _parseOrder(Map<String, dynamic> json) {
    return OrderModel.fromJson(json);
  }
}