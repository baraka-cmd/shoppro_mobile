// ============================================
// API SOURCE : AdminStatsApi
// ============================================
// Source de données distante pour les statistiques et rapports.
// Tous les endpoints pointent vers /admin/dashboard/*
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

/// Source de données API pour les statistiques et rapports.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminStatsApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminStatsApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // HELPERS DE DATES
  // ============================================

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  // ============================================
  // RAPPORTS DE VENTES
  // ============================================

  /// Génère un rapport de ventes personnalisé.
  ///
  /// Endpoint : GET /admin/dashboard/sales-report
  Future<Map<String, dynamic>> generateReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/sales-report',
        queryParameters: {
          'start_date': _formatDate(startDate),
          'end_date': _formatDate(endDate),
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le rapport du jour.
  Future<Map<String, dynamic>> getTodayReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport d'hier.
  Future<Map<String, dynamic>> getYesterdayReport() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end = DateTime(now.year, now.month, now.day).subtract(const Duration(seconds: 1));
    return generateReport(startDate: start, endDate: end);
  }

  /// Récupère le rapport des 7 derniers jours.
  Future<Map<String, dynamic>> getLast7DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport des 30 derniers jours.
  Future<Map<String, dynamic>> getLast30DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport des 90 derniers jours.
  Future<Map<String, dynamic>> getLast90DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport du mois en cours.
  Future<Map<String, dynamic>> getThisMonthReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport du mois dernier.
  Future<Map<String, dynamic>> getLastMonthReport() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final thisMonth = DateTime(now.year, now.month, 1);
    return generateReport(
      startDate: lastMonth,
      endDate: thisMonth.subtract(const Duration(seconds: 1)),
    );
  }

  /// Récupère le rapport de l'année en cours.
  Future<Map<String, dynamic>> getThisYearReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return generateReport(startDate: start, endDate: now);
  }

  /// Récupère le rapport de l'année dernière.
  Future<Map<String, dynamic>> getLastYearReport() async {
    final now = DateTime.now();
    final lastYear = DateTime(now.year - 1, 1, 1);
    final thisYear = DateTime(now.year, 1, 1);
    return generateReport(
      startDate: lastYear,
      endDate: thisYear.subtract(const Duration(seconds: 1)),
    );
  }

  // ============================================
  // ANALYSE DES REVENUS
  // ============================================

  /// Récupère les ventes par jour.
  ///
  /// Endpoint : GET /admin/dashboard/sales-by-day
  Future<Map<String, dynamic>> getRevenueByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
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
  Future<Map<String, dynamic>> getRevenueByMonth({int? year}) async {
    try {
      final response = await _dio.get('/admin/dashboard/revenue-by-month');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le revenu total via le rapport.
  Future<Map<String, dynamic>> getTotalRevenue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/dashboard/sales-report',
        queryParameters: {
          'start_date': _formatDate(startDate),
          'end_date': _formatDate(endDate),
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ANALYSE DES COMMANDES
  // ============================================

  /// Récupère les commandes par statut.
  ///
  /// Endpoint : GET /admin/dashboard/orders-by-status
  Future<Map<String, dynamic>> getOrdersCountByStatus() async {
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

  /// Récupère le nombre total de commandes via le rapport.
  Future<Map<String, dynamic>> getTotalOrders({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return generateReport(startDate: startDate, endDate: endDate);
  }

  // ============================================
  // ANALYSE DES CLIENTS
  // ============================================

  /// Récupère les nouveaux clients (via le rapport).
  Future<Map<String, dynamic>> getNewCustomersByDay({int days = 30}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));
      final response = await _dio.get(
        '/admin/dashboard/sales-report',
        queryParameters: {
          'start_date': _formatDate(start),
          'end_date': _formatDate(now),
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre total de clients via le rapport.
  Future<Map<String, dynamic>> getTotalCustomers() async {
    return getLast30DaysReport();
  }

  /// Récupère le taux de rétention via la performance.
  Future<Map<String, dynamic>> getRetentionRate() async {
    try {
      final response = await _dio.get('/admin/dashboard/performance');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ANALYSE DES PRODUITS
  // ============================================

  /// Récupère les top produits par revenu.
  ///
  /// Endpoint : GET /admin/dashboard/top-products
  Future<Map<String, dynamic>> getTopProductsByRevenue({int limit = 10}) async {
    try {
      final response = await _dio.get('/admin/dashboard/top-products');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les top produits par quantité.
  Future<Map<String, dynamic>> getTopProductsByQuantity({int limit = 10}) async {
    return getTopProductsByRevenue(limit: limit);
  }

  /// Récupère les produits en rupture de stock.
  ///
  /// Endpoint : GET /admin/dashboard/low-stock-products
  Future<Map<String, dynamic>> getOutOfStockProducts() async {
    try {
      final response = await _dio.get('/admin/dashboard/low-stock-products');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ANALYSE DES CATÉGORIES ET MARQUES
  // ============================================

  /// Récupère les top catégories.
  ///
  /// Endpoint : GET /admin/dashboard/top-categories
  Future<Map<String, dynamic>> getTopCategories({int limit = 10}) async {
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
  Future<Map<String, dynamic>> getTopBrands({int limit = 10}) async {
    try {
      final response = await _dio.get('/admin/dashboard/top-brands');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ANALYSE DES PAIEMENTS
  // ============================================

  /// Récupère les paiements par statut (via les commandes).
  Future<Map<String, dynamic>> getPaymentsByMethod() async {
    return getOrdersCountByStatus();
  }

  /// Récupère les paiements par statut.
  Future<Map<String, dynamic>> getPaymentsByStatus() async {
    return getOrdersCountByStatus();
  }

  /// Récupère le total des remboursements (via le rapport).
  Future<Map<String, dynamic>> getTotalRefunds() async {
    return getLast30DaysReport();
  }

  // ============================================
  // COMPARAISON
  // ============================================

  /// Compare deux périodes.
  Future<Map<String, dynamic>> comparePeriods({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) async {
    try {
      final current = await generateReport(startDate: currentStart, endDate: currentEnd);
      final previous = await generateReport(startDate: previousStart, endDate: previousEnd);

      final currentRevenue = (current['data'] is Map)
          ? ((current['data'] as Map)['total_revenue'] as num?)?.toDouble() ?? 0
          : 0.0;
      final previousRevenue = (previous['data'] is Map)
          ? ((previous['data'] as Map)['total_revenue'] as num?)?.toDouble() ?? 0
          : 0.0;

      final revenueChange = previousRevenue > 0
          ? ((currentRevenue - previousRevenue) / previousRevenue) * 100
          : 0.0;

      return {
        'success': true,
        'data': {
          'revenue_change': revenueChange,
          'orders_change': 0,
          'customers_change': 0,
          'average_order_change': 0,
        },
      };
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
        return Exception('Statistiques introuvables.');
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