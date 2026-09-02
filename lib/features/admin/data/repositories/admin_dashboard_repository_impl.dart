// ============================================
// REPOSITORY IMPL : AdminDashboardRepositoryImpl
// ============================================
// Implémentation concrète du repository du tableau de bord admin.
// Cette classe implémente l'interface [AdminDashboardRepository]
// et orchestre les appels API avec le cache local.
//
// Responsabilités :
// - Appels API via AdminDashboardApi
// - Mise en cache avec SharedPreferences
// - Gestion des erreurs
// - Transformation des données
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Packages externes
import 'package:shared_preferences/shared_preferences.dart';

// Entities (même feature admin)
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/sales_report.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_dashboard_repository.dart';

// Models (même feature admin)
import '../models/dashboard_stats_model.dart';
import '../models/sales_report_model.dart';

// Sources (même feature admin)
import '../sources/admin_dashboard_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository du dashboard admin.
///
/// Gère :
/// - Récupération des statistiques depuis l'API
/// - Mise en cache locale avec SharedPreferences
/// - Récupération depuis le cache en cas d'échec réseau
class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminDashboardApi _api;
  final SharedPreferences? _prefs;

  // ============================================
  // CLÉS DE CACHE
  // ============================================

  static const String _cacheKeyStats = 'admin_dashboard_stats';
  static const String _cacheKeyTimestamp = 'admin_dashboard_timestamp';
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminDashboardRepositoryImpl({
    AdminDashboardApi? api,
    SharedPreferences? prefs,
  })  : _api = api ?? AdminDashboardApi(),
        _prefs = prefs;

  // ============================================
  // STATISTIQUES GÉNÉRALES
  // ============================================

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      // 1. Essayer de récupérer depuis l'API
      final response = await _api.getDashboardStats();
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final stats = DashboardStatsModel.fromJson(data);

      // 2. Mettre en cache
      await _cacheStats(stats);

      return stats;
    } catch (e) {
      debugPrint('Erreur getDashboardStats: $e');

      // 3. Fallback : récupérer depuis le cache
      final cached = await getCachedStats();
      if (cached != null) {
        debugPrint('Utilisation du cache pour les statistiques');
        return cached;
      }

      rethrow;
    }
  }

  @override
  Future<DashboardStats> getStatsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.getStatsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return DashboardStatsModel.fromJson(data);
    } catch (e) {
      debugPrint('Erreur getStatsByPeriod: $e');
      rethrow;
    }
  }

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getSalesByDay() async {
    try {
      final response = await _api.getSalesByDay();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getSalesByDay: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueByMonth() async {
    try {
      final response = await _api.getRevenueByMonth();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRevenueByMonth: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getOrdersByStatus() async {
    try {
      final response = await _api.getOrdersByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getOrdersByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersByHour() async {
    try {
      final response = await _api.getOrdersByHour();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOrdersByHour: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersByDayOfWeek() async {
    try {
      final response = await _api.getOrdersByDayOfWeek();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOrdersByDayOfWeek: $e');
      rethrow;
    }
  }

  // ============================================
  // TOP ÉLÉMENTS
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getTopProducts() async {
    try {
      final response = await _api.getTopProducts();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getTopProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCategories() async {
    try {
      final response = await _api.getTopCategories();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getTopCategories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopBrands() async {
    try {
      final response = await _api.getTopBrands();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getTopBrands: $e');
      rethrow;
    }
  }

  // ============================================
  // DONNÉES RÉCENTES
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _api.getRecentOrders(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRecentOrders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await _api.getRecentUsers(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRecentUsers: $e');
      rethrow;
    }
  }

  // ============================================
  // ALERTES
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final response = await _api.getLowStockProducts();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getLowStockProducts: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPendingReviewsCount() async {
    try {
      final response = await _api.getPendingReviewsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getPendingReviewsCount: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPendingOrdersCount() async {
    try {
      final response = await _api.getPendingOrdersCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getPendingOrdersCount: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPendingPaymentsCount() async {
    try {
      final response = await _api.getPendingPaymentsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getPendingPaymentsCount: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPendingReturnsCount() async {
    try {
      final response = await _api.getPendingReturnsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getPendingReturnsCount: $e');
      rethrow;
    }
  }

  // ============================================
  // RAPPORTS DE VENTES
  // ============================================

  @override
  Future<SalesReport> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.generateSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return SalesReportModel.fromJson(data);
    } catch (e) {
      debugPrint('Erreur generateSalesReport: $e');
      rethrow;
    }
  }

  @override
  Future<SalesReport> getTodayReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return generateSalesReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLast7DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return generateSalesReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLast30DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return generateSalesReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getThisMonthReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return generateSalesReport(startDate: start, endDate: now);
  }

  // ============================================
  // PERFORMANCE
  // ============================================

  @override
  Future<Map<String, dynamic>> getPerformanceStats() async {
    try {
      final response = await _api.getPerformanceStats();
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPerformanceStats: $e');
      rethrow;
    }
  }

  @override
  Future<double> getConversionRate() async {
    final stats = await getPerformanceStats();
    return (stats['conversion_rate'] as num?)?.toDouble() ?? 0;
  }

  @override
  Future<double> getAverageRating() async {
    final stats = await getPerformanceStats();
    return (stats['average_rating'] as num?)?.toDouble() ?? 0;
  }

  // ============================================
  // ACTIONS ADMIN
  // ============================================

  @override
  Future<void> refreshStatsCache() async {
    try {
      final response = await _api.getDashboardStats();
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final stats = DashboardStatsModel.fromJson(data);
      await _cacheStats(stats);
      debugPrint('Cache des statistiques rafraîchi');
    } catch (e) {
      debugPrint('Erreur refreshStatsCache: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearStatsCache() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyStats);
      await prefs.remove(_cacheKeyTimestamp);
      debugPrint('Cache des statistiques effacé');
    } catch (e) {
      debugPrint('Erreur clearStatsCache: $e');
    }
  }

  @override
  Future<bool> hasCachedStats() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKeyStats);
    return cached != null && cached.isNotEmpty;
  }

  @override
  Future<DashboardStats?> getCachedStats() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKeyStats);

      if (cached == null || cached.isEmpty) return null;

      // Vérifier la validité du cache
      final timestamp = prefs.getInt(_cacheKeyTimestamp);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheValidity) {
          return null; // Cache expiré
        }
      }

      final json = jsonDecode(cached) as Map<String, dynamic>;
      return DashboardStatsModel.fromJson(json);
    } catch (e) {
      debugPrint('Erreur getCachedStats: $e');
      return null;
    }
  }

  // ============================================
  // HELPERS PRIVÉS DE CACHE
  // ============================================

  /// Met en cache les statistiques avec horodatage.
  Future<void> _cacheStats(DashboardStats stats) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final model = DashboardStatsModel.fromEntity(stats);
      await prefs.setString(_cacheKeyStats, jsonEncode(model.toJson()));
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Erreur _cacheStats: $e');
    }
  }
}