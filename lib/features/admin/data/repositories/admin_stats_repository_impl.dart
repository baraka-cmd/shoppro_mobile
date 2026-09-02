// ============================================
// REPOSITORY IMPL : AdminStatsRepositoryImpl
// ============================================
// Implémentation concrète du repository des statistiques.
// Cette classe implémente l'interface [AdminStatsRepository]
// et orchestre les appels API pour les rapports détaillés.
//
// Responsabilités :
// - Appels API via AdminStatsApi
// - Transformation des données
// - Génération de rapports
// - Export de données
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
import '../../domain/entities/sales_report.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_stats_repository.dart';

// Models (même feature admin)
import '../models/sales_report_model.dart';

// Sources (même feature admin)
import '../sources/admin_stats_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository des statistiques et rapports.
///
/// Gère la génération des rapports de ventes et les analyses.
class AdminStatsRepositoryImpl implements AdminStatsRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminStatsApi _api;
  final SharedPreferences? _prefs;

  // ============================================
  // CLÉS DE CACHE
  // ============================================

  static const String _cacheKeyReports = 'admin_stats_reports';
  static const String _cacheKeyTimestamp = 'admin_stats_timestamp';
  static const Duration _cacheValidity = Duration(minutes: 10);

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminStatsRepositoryImpl({
    AdminStatsApi? api,
    SharedPreferences? prefs,
  })  : _api = api ?? AdminStatsApi(),
        _prefs = prefs;

  // ============================================
  // RAPPORTS DE VENTES
  // ============================================

  @override
  Future<SalesReport> generateReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.generateReport(
        startDate: startDate,
        endDate: endDate,
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return SalesReportModel.fromJson(data);
    } catch (e) {
      debugPrint('Erreur generateReport: $e');
      rethrow;
    }
  }

  @override
  Future<SalesReport> getTodayReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getYesterdayReport() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end = DateTime(now.year, now.month, now.day).subtract(const Duration(seconds: 1));
    return generateReport(startDate: start, endDate: end);
  }

  @override
  Future<SalesReport> getLast7DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLast30DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLast90DaysReport() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getThisMonthReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLastMonthReport() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final thisMonth = DateTime(now.year, now.month, 1);
    return generateReport(startDate: lastMonth, endDate: thisMonth.subtract(const Duration(seconds: 1)));
  }

  @override
  Future<SalesReport> getThisYearReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return generateReport(startDate: start, endDate: now);
  }

  @override
  Future<SalesReport> getLastYearReport() async {
    final now = DateTime.now();
    final lastYear = DateTime(now.year - 1, 1, 1);
    final thisYear = DateTime(now.year, 1, 1);
    return generateReport(startDate: lastYear, endDate: thisYear.subtract(const Duration(seconds: 1)));
  }

  // ============================================
  // ANALYSE DES REVENUS
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getRevenueByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.getRevenueByDay(startDate: startDate, endDate: endDate);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRevenueByDay: $e');
      rethrow;
    }
  }

 @override
Future<List<Map<String, dynamic>>> getRevenueByWeek({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    // Utiliser getRevenueByDay et regrouper par semaine manuellement
    final response = await _api.getRevenueByDay(startDate: startDate, endDate: endDate);
    final data = response['data'];

    if (data is List) {
      final daily = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Regrouper par semaine (7 jours)
      final weekly = <String, Map<String, dynamic>>{};

      for (final day in daily) {
        final dateStr = day['date'] as String? ?? '';
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;

        final weekKey = 'Semaine ${(date.day - 1) ~/ 7 + 1}';
        final revenue = (day['revenue'] as num?)?.toDouble() ?? 0;
        final orders = (day['orders'] as num?)?.toInt() ?? 0;

        if (!weekly.containsKey(weekKey)) {
          weekly[weekKey] = {
            'week': weekKey,
            'revenue': 0.0,
            'orders': 0,
          };
        }

        weekly[weekKey]!['revenue'] = (weekly[weekKey]!['revenue'] as double) + revenue;
        weekly[weekKey]!['orders'] = (weekly[weekKey]!['orders'] as int) + orders;
      }

      return weekly.values.toList();
    }

    return [];
  } catch (e) {
    debugPrint('Erreur getRevenueByWeek: $e');
    rethrow;
  }
}

  @override
  Future<List<Map<String, dynamic>>> getRevenueByMonth({int? year}) async {
    try {
      final response = await _api.getRevenueByMonth(year: year);
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
  Future<double> getTotalRevenue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.getTotalRevenue(startDate: startDate, endDate: endDate);
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
  Future<double> getNetRevenue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final report = await generateReport(startDate: startDate, endDate: endDate);
    return report.netRevenue;
  }

  // ============================================
  // ANALYSE DES COMMANDES
  // ============================================

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

  @override
  Future<int> getTotalOrders({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.getTotalOrders(startDate: startDate, endDate: endDate);
      final data = response['data'];
      if (data is Map) {
        return (data['total'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalOrders: $e');
      rethrow;
    }
  }

  @override
  Future<double> getAverageOrderValue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final report = await generateReport(startDate: startDate, endDate: endDate);
    return report.averageOrderValue;
  }

  // ============================================
  // ANALYSE DES CLIENTS
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getNewCustomersByDay({int days = 30}) async {
    try {
      final response = await _api.getNewCustomersByDay(days: days);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getNewCustomersByDay: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTotalCustomers() async {
    try {
      final response = await _api.getTotalCustomers();
      final data = response['data'];
      if (data is Map) {
        return (data['total'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalCustomers: $e');
      rethrow;
    }
  }

  @override
  Future<int> getActiveCustomers() async {
    try {
      final response = await _api.getTotalCustomers();
      final data = response['data'];
      if (data is Map) {
        return (data['active'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getActiveCustomers: $e');
      rethrow;
    }
  }

  @override
  Future<double> getRetentionRate() async {
    try {
      final response = await _api.getRetentionRate();
      final data = response['data'];
      if (data is Map) {
        return (data['rate'] as num?)?.toDouble() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getRetentionRate: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLoyalCustomers({int limit = 10}) async {
    try {
      final response = await _api.getTopProductsByRevenue(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getLoyalCustomers: $e');
      rethrow;
    }
  }

  // ============================================
  // ANALYSE DES PRODUITS
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getTopProductsByRevenue({int limit = 10}) async {
    try {
      final response = await _api.getTopProductsByRevenue(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getTopProductsByRevenue: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopProductsByQuantity({int limit = 10}) async {
    try {
      final response = await _api.getTopProductsByQuantity(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getTopProductsByQuantity: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWorstProducts({int limit = 10}) async {
    try {
      final allProducts = await getTopProductsByQuantity(limit: 100);
      allProducts.sort((a, b) => ((a['quantity'] as num?) ?? 0).compareTo((b['quantity'] as num?) ?? 0));
      return allProducts.take(limit).toList();
    } catch (e) {
      debugPrint('Erreur getWorstProducts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOutOfStockProducts() async {
    try {
      final response = await _api.getOutOfStockProducts();
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getOutOfStockProducts: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTotalItemsSold() async {
    try {
      final report = await getLast30DaysReport();
      return report.totalItemsSold;
    } catch (e) {
      debugPrint('Erreur getTotalItemsSold: $e');
      rethrow;
    }
  }

  // ============================================
  // ANALYSE DES CATÉGORIES ET MARQUES
  // ============================================

  @override
  Future<List<Map<String, dynamic>>> getTopCategories({int limit = 10}) async {
    try {
      final response = await _api.getTopCategories(limit: limit);
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
  Future<List<Map<String, dynamic>>> getTopBrands({int limit = 10}) async {
    try {
      final response = await _api.getTopBrands(limit: limit);
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
  // ANALYSE DES PAIEMENTS
  // ============================================

  @override
  Future<Map<String, int>> getPaymentsByMethod() async {
    try {
      final response = await _api.getPaymentsByMethod();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPaymentsByMethod: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getPaymentsByStatus() async {
    try {
      final response = await _api.getPaymentsByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPaymentsByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<double> getTotalRefunds() async {
    try {
      final response = await _api.getTotalRefunds();
      final data = response['data'];
      if (data is Map) {
        return (data['total'] as num?)?.toDouble() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalRefunds: $e');
      rethrow;
    }
  }

  // ============================================
  // COMPARAISON
  // ============================================

  @override
  Future<Map<String, dynamic>> comparePeriods({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) async {
    try {
      final response = await _api.comparePeriods(
        currentStart: currentStart,
        currentEnd: currentEnd,
        previousStart: previousStart,
        previousEnd: previousEnd,
      );
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      debugPrint('Erreur comparePeriods: $e');
      rethrow;
    }
  }

  // ============================================
  // EXPORT
  // ============================================

  @override
  Future<String> exportReportToCsv(SalesReport report) async {
    final model = SalesReportModel.fromEntity(report);
    return model.toCsv();
  }

  @override
  Future<String> exportReportToJson(SalesReport report) async {
    final model = SalesReportModel.fromEntity(report);
    return model.toPrettyJson();
  }

  // ============================================
  // CACHE
  // ============================================

  @override
  Future<void> refreshCache() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final report = await getLast30DaysReport();
      final model = SalesReportModel.fromEntity(report);
      await prefs.setString(_cacheKeyReports, jsonEncode(model.toJson()));
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
      debugPrint('Cache des statistiques rafraîchi');
    } catch (e) {
      debugPrint('Erreur refreshCache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyReports);
      await prefs.remove(_cacheKeyTimestamp);
      debugPrint('Cache des statistiques effacé');
    } catch (e) {
      debugPrint('Erreur clearCache: $e');
    }
  }

  @override
  Future<bool> hasCachedStats() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKeyReports);
    return cached != null && cached.isNotEmpty;
  }
}