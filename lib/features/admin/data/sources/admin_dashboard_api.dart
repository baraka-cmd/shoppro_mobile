// ============================================
// API SOURCE : AdminDashboardApi
// ============================================
// Source de données distante pour le tableau de bord admin.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant les statistiques du dashboard.
//
// Responsabilités :
// - Appels API avec Dio
// - Gestion des erreurs
// - Formatage des réponses
// ============================================

// ============================================
// IMPORTS
// ============================================

// Packages externes
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Source de données API pour le dashboard admin.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminDashboardApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio (configuré avec les intercepteurs)
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminDashboardApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // STATISTIQUES GÉNÉRALES
  // ============================================

  /// Récupère les statistiques générales du dashboard.
  ///
  /// Endpoint : GET /admin/dashboard/stats
  ///
  /// Retourne la réponse JSON complète.
  ///
  /// Lance une [DioException] en cas d'erreur réseau.
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/dashboard/stats');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les statistiques pour une période donnée.
  ///
  /// Endpoint : GET /admin/dashboard/stats/period
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  Future<Map<String, dynamic>> getStatsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/stats/period',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================

  /// Récupère les ventes par jour.
  ///
  /// Endpoint : GET /admin/dashboard/sales-by-day
  Future<Map<String, dynamic>> getSalesByDay() async {
    try {
      final response = await _dio.get('/admin/dashboard/sales-by-day');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les revenus par mois.
  ///
  /// Endpoint : GET /admin/dashboard/revenue-by-month
  Future<Map<String, dynamic>> getRevenueByMonth() async {
    try {
      final response = await _dio.get('/admin/dashboard/revenue-by-month');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes par statut.
  ///
  /// Endpoint : GET /admin/dashboard/orders-by-status
  Future<Map<String, dynamic>> getOrdersByStatus() async {
    try {
      final response = await _dio.get('/admin/dashboard/orders-by-status');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes par heure.
  ///
  /// Endpoint : GET /admin/dashboard/orders-by-hour
  Future<Map<String, dynamic>> getOrdersByHour() async {
    try {
      final response = await _dio.get('/admin/dashboard/orders-by-hour');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les commandes par jour de la semaine.
  ///
  /// Endpoint : GET /admin/dashboard/orders-by-day-of-week
  Future<Map<String, dynamic>> getOrdersByDayOfWeek() async {
    try {
      final response = await _dio.get('/admin/dashboard/orders-by-day-of-week');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // TOP ÉLÉMENTS
  // ============================================

  /// Récupère les top produits.
  ///
  /// Endpoint : GET /admin/dashboard/top-products
  Future<Map<String, dynamic>> getTopProducts() async {
    try {
      final response = await _dio.get('/admin/dashboard/top-products');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les top catégories.
  ///
  /// Endpoint : GET /admin/dashboard/top-categories
  Future<Map<String, dynamic>> getTopCategories() async {
    try {
      final response = await _dio.get('/admin/dashboard/top-categories');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les top marques.
  ///
  /// Endpoint : GET /admin/dashboard/top-brands
  Future<Map<String, dynamic>> getTopBrands() async {
    try {
      final response = await _dio.get('/admin/dashboard/top-brands');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DONNÉES RÉCENTES
  // ============================================

  /// Récupère les commandes récentes.
  ///
  /// Endpoint : GET /admin/dashboard/recent-orders
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/recent-orders',
        queryParameters: {'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les utilisateurs récents.
  ///
  /// Endpoint : GET /admin/dashboard/recent-users
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<Map<String, dynamic>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/recent-users',
        queryParameters: {'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ALERTES
  // ============================================

  /// Récupère les produits en stock faible.
  ///
  /// Endpoint : GET /admin/dashboard/low-stock-products
  Future<Map<String, dynamic>> getLowStockProducts() async {
    try {
      final response = await _dio.get('/admin/dashboard/low-stock-products');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre d'avis en attente.
  ///
  /// Endpoint : GET /admin/dashboard/pending-reviews-count
  Future<Map<String, dynamic>> getPendingReviewsCount() async {
    try {
      final response = await _dio.get('/admin/dashboard/pending-reviews-count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de commandes en attente.
  ///
  /// Endpoint : GET /admin/dashboard/pending-orders-count
  Future<Map<String, dynamic>> getPendingOrdersCount() async {
    try {
      final response = await _dio.get('/admin/dashboard/pending-orders-count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de paiements en attente.
  ///
  /// Endpoint : GET /admin/dashboard/pending-payments-count
  Future<Map<String, dynamic>> getPendingPaymentsCount() async {
    try {
      final response = await _dio.get('/admin/dashboard/pending-payments-count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de retours en attente.
  ///
  /// Endpoint : GET /admin/dashboard/pending-returns-count
  Future<Map<String, dynamic>> getPendingReturnsCount() async {
    try {
      final response = await _dio.get('/admin/dashboard/pending-returns-count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // RAPPORTS
  // ============================================

  /// Génère un rapport de ventes.
  ///
  /// Endpoint : GET /admin/dashboard/sales-report
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  Future<Map<String, dynamic>> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/sales-report',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // PERFORMANCE
  // ============================================

  /// Récupère les statistiques de performance.
  ///
  /// Endpoint : GET /admin/dashboard/performance
  Future<Map<String, dynamic>> getPerformanceStats() async {
    try {
      final response = await _dio.get('/admin/dashboard/performance');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parse la réponse HTTP et retourne les données.
  ///
  /// Vérifie si la réponse a un statut 2xx et extrait les données.
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {'data': data};
  }

  /// Gère les erreurs Dio et retourne un message clair.
  ///
  /// Format des erreurs :
  /// - 401 : Non autorisé
  /// - 403 : Accès refusé
  /// - 404 : Ressource introuvable
  /// - 422 : Erreur de validation
  /// - 500 : Erreur serveur
  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé. Vous n\'avez pas les permissions nécessaires.');
      case 404:
        return Exception('Ressource introuvable.');
      case 422:
        final errors = e.response?.data?['errors'];
        return Exception('Erreur de validation: $errors');
      case 500:
        return Exception('Erreur serveur. Veuillez réessayer plus tard.');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Exception('Délai de connexion dépassé. Vérifiez votre connexion.');
        }
        if (e.type == DioExceptionType.connectionError) {
          return Exception('Impossible de se connecter au serveur.');
        }
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}