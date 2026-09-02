// ============================================
// API SOURCE : AdminOrderApi
// ============================================
// Source de données distante pour la gestion des commandes.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant les commandes administrées.
//
// Responsabilités :
// - Appels API de gestion des commandes avec Dio
// - Changement de statut
// - Gestion des paiements
// - Notes admin
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Packages externes
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Source de données API pour la gestion des commandes.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminOrderApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminOrderApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des commandes.
  ///
  /// Endpoint : GET /admin/orders
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  /// - [status] : Filtrer par statut
  /// - [paymentStatus] : Filtrer par statut de paiement
  /// - [userId] : Filtrer par client
  /// - [searchQuery] : Recherche par numéro
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  /// - [sortBy] : Champ de tri
  /// - [sortDirection] : Direction du tri
  Future<Map<String, dynamic>> getOrders({
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
      final response = await _dio.get(
        '/admin/orders',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null && status.isNotEmpty) 'status': status,
          if (paymentStatus != null && paymentStatus.isNotEmpty) 'payment_status': paymentStatus,
          if (userId != null) 'user_id': userId,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDirection != null) 'sort_direction': sortDirection,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Recherche des commandes.
  ///
  /// Endpoint : GET /admin/orders/search
  Future<Map<String, dynamic>> searchOrders(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/orders/search',
        queryParameters: {'q': query, 'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes en attente.
  ///
  /// Endpoint : GET /admin/orders/pending
  Future<Map<String, dynamic>> getPendingOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/pending',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes confirmées.
  ///
  /// Endpoint : GET /admin/orders/confirmed
  Future<Map<String, dynamic>> getConfirmedOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/confirmed',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes en traitement.
  ///
  /// Endpoint : GET /admin/orders/processing
  Future<Map<String, dynamic>> getProcessingOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/processing',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes expédiées.
  ///
  /// Endpoint : GET /admin/orders/shipped
  Future<Map<String, dynamic>> getShippedOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/shipped',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes livrées.
  ///
  /// Endpoint : GET /admin/orders/delivered
  Future<Map<String, dynamic>> getDeliveredOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/delivered',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes annulées.
  ///
  /// Endpoint : GET /admin/orders/cancelled
  Future<Map<String, dynamic>> getCancelledOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/orders/cancelled',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes d'un client.
  ///
  /// Endpoint : GET /admin/orders/by-user/{userId}
  Future<Map<String, dynamic>> getOrdersByUser(int userId) async {
    try {
      final response = await _dio.get('/admin/orders/by-user/$userId');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une commande.
  ///
  /// Endpoint : GET /admin/orders/{id}
  Future<Map<String, dynamic>> getOrderById(int id) async {
    try {
      final response = await _dio.get('/admin/orders/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère une commande par son numéro.
  ///
  /// Endpoint : GET /admin/orders/by-number/{orderNumber}
  Future<Map<String, dynamic>> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _dio.get('/admin/orders/by-number/$orderNumber');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des statuts.
  ///
  /// Endpoint : GET /admin/orders/{id}/history
  Future<Map<String, dynamic>> getOrderStatusHistory(int orderId) async {
    try {
      final response = await _dio.get('/admin/orders/$orderId/history');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le suivi de livraison.
  ///
  /// Endpoint : GET /admin/orders/{id}/tracking
  Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    try {
      final response = await _dio.get('/admin/orders/$orderId/tracking');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CHANGEMENT DE STATUT
  // ============================================

  /// Confirme une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/confirm
  Future<Map<String, dynamic>> confirmOrder(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/confirm');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque comme en traitement.
  ///
  /// Endpoint : POST /admin/orders/{id}/process
  Future<Map<String, dynamic>> processOrder(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/process');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Expédie une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/ship
  Future<Map<String, dynamic>> shipOrder(
    int orderId, {
    String? trackingNumber,
    String? carrier,
  }) async {
    try {
      final response = await _dio.post(
        '/admin/orders/$orderId/ship',
        data: {
          'tracking_number': trackingNumber,
          'carrier': carrier,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Livre une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/deliver
  Future<Map<String, dynamic>> deliverOrder(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/deliver');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Annule une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/cancel
  Future<Map<String, dynamic>> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/admin/orders/$orderId/cancel',
        data: {'reason': reason},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Rembourse une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/refund
  Future<Map<String, dynamic>> refundOrder(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/refund');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Retourne une commande.
  ///
  /// Endpoint : POST /admin/orders/{id}/return
  Future<Map<String, dynamic>> returnOrder(int orderId, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/admin/orders/$orderId/return',
        data: {'reason': reason},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // PAIEMENT
  // ============================================

  /// Marque le paiement comme reçu.
  ///
  /// Endpoint : POST /admin/orders/{id}/payment/paid
  Future<Map<String, dynamic>> markPaymentAsPaid(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/payment/paid');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque le paiement comme échoué.
  ///
  /// Endpoint : POST /admin/orders/{id}/payment/failed
  Future<Map<String, dynamic>> markPaymentAsFailed(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/payment/failed');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque le paiement comme remboursé.
  ///
  /// Endpoint : POST /admin/orders/{id}/payment/refunded
  Future<Map<String, dynamic>> markPaymentAsRefunded(int orderId) async {
    try {
      final response = await _dio.post('/admin/orders/$orderId/payment/refunded');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // NOTES ADMIN
  // ============================================

  /// Ajoute une note admin.
  ///
  /// Endpoint : POST /admin/orders/{id}/notes
  Future<Map<String, dynamic>> addAdminNote(int orderId, String note) async {
    try {
      final response = await _dio.post(
        '/admin/orders/$orderId/notes',
        data: {'note': note},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notes admin.
  ///
  /// Endpoint : GET /admin/orders/{id}/notes
  Future<Map<String, dynamic>> getAdminNotes(int orderId) async {
    try {
      final response = await _dio.get('/admin/orders/$orderId/notes');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de commandes.
  ///
  /// Endpoint : GET /admin/orders/stats/count
  Future<Map<String, dynamic>> getTotalOrdersCount() async {
    try {
      final response = await _dio.get('/admin/orders/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de commandes par statut.
  ///
  /// Endpoint : GET /admin/orders/stats/by-status
  Future<Map<String, dynamic>> getOrdersCountByStatus() async {
    try {
      final response = await _dio.get('/admin/orders/stats/by-status');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le revenu total.
  ///
  /// Endpoint : GET /admin/orders/stats/total-revenue
  Future<Map<String, dynamic>> getTotalRevenue() async {
    try {
      final response = await _dio.get('/admin/orders/stats/total-revenue');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime une commande (soft delete).
  ///
  /// Endpoint : DELETE /admin/orders/{id}
  Future<Map<String, dynamic>> deleteOrder(int id) async {
    try {
      final response = await _dio.delete('/admin/orders/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Restaure une commande supprimée.
  ///
  /// Endpoint : POST /admin/orders/{id}/restore
  Future<Map<String, dynamic>> restoreOrder(int id) async {
    try {
      final response = await _dio.post('/admin/orders/$id/restore');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parse la réponse HTTP.
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  /// Gère les erreurs Dio avec messages clairs.
  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Commande introuvable.');
      case 422:
        final errors = e.response?.data?['errors'];
        return Exception('Erreur de validation: $errors');
      case 500:
        return Exception('Erreur serveur.');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Exception('Délai de connexion dépassé.');
        }
        if (e.type == DioExceptionType.connectionError) {
          return Exception('Impossible de se connecter au serveur.');
        }
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}