// ============================================
// MODEL : DashboardStatsModel
// ============================================
// Modèle de sérialisation pour les statistiques du tableau de bord.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (DashboardStats).
//
// Responsabilités :
// - Conversion JSON → DashboardStats (fromJson)
// - Conversion DashboardStats → JSON (toJson)
// - Conversion DashboardStats → DashboardStatsModel (fromEntity)
// - Conversion DashboardStatsModel → DashboardStats (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/dashboard_stats.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [DashboardStats].
///
/// Cette classe étend [DashboardStats] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class DashboardStatsModel extends DashboardStats {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const DashboardStatsModel({
    required super.totalRevenue,
    required super.totalOrders,
    required super.totalUsers,
    required super.totalProducts,
    required super.totalCategories,
    required super.totalBrands,
    required super.averageOrderValue,
    required super.conversionRate,
    required super.salesByDay,
    required super.ordersByStatus,
    required super.revenueByMonth,
    required super.topProducts,
    required super.topCategories,
    required super.recentOrders,
    required super.recentUsers,
    required super.lowStockCount,
    required super.lowStockProducts,
    required super.pendingReviewsCount,
    required super.pendingOrdersCount,
    required super.pendingPaymentsCount,
    required super.pendingReturnsCount,
    required super.totalVisits,
    required super.totalFavorites,
    required super.totalReviews,
    required super.averageRating,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory DashboardStatsModel.fromEntity(DashboardStats entity) {
    return DashboardStatsModel(
      totalRevenue: entity.totalRevenue,
      totalOrders: entity.totalOrders,
      totalUsers: entity.totalUsers,
      totalProducts: entity.totalProducts,
      totalCategories: entity.totalCategories,
      totalBrands: entity.totalBrands,
      averageOrderValue: entity.averageOrderValue,
      conversionRate: entity.conversionRate,
      salesByDay: entity.salesByDay,
      ordersByStatus: entity.ordersByStatus,
      revenueByMonth: entity.revenueByMonth,
      topProducts: entity.topProducts,
      topCategories: entity.topCategories,
      recentOrders: entity.recentOrders,
      recentUsers: entity.recentUsers,
      lowStockCount: entity.lowStockCount,
      lowStockProducts: entity.lowStockProducts,
      pendingReviewsCount: entity.pendingReviewsCount,
      pendingOrdersCount: entity.pendingOrdersCount,
      pendingPaymentsCount: entity.pendingPaymentsCount,
      pendingReturnsCount: entity.pendingReturnsCount,
      totalVisits: entity.totalVisits,
      totalFavorites: entity.totalFavorites,
      totalReviews: entity.totalReviews,
      averageRating: entity.averageRating,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées :
  /// - num → double/int
  /// - List → List<Map<String, dynamic>>
  /// - Map → Map<String, int>
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      // Statistiques générales
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalCategories: (json['total_categories'] as num?)?.toInt() ?? 0,
      totalBrands: (json['total_brands'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,

      // Données de graphiques
      salesByDay: _parseListOfMaps(json['sales_by_day']),
      ordersByStatus: _parseMapStringInt(json['orders_by_status']),
      revenueByMonth: _parseListOfMaps(json['revenue_by_month']),

      // Top éléments
      topProducts: _parseListOfMaps(json['top_products']),
      topCategories: _parseListOfMaps(json['top_categories']),

      // Données récentes
      recentOrders: _parseListOfMaps(json['recent_orders']),
      recentUsers: _parseListOfMaps(json['recent_users']),

      // Alertes
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      lowStockProducts: _parseListOfMaps(json['low_stock_products']),
      pendingReviewsCount: (json['pending_reviews_count'] as num?)?.toInt() ?? 0,
      pendingOrdersCount: (json['pending_orders_count'] as num?)?.toInt() ?? 0,
      pendingPaymentsCount: (json['pending_payments_count'] as num?)?.toInt() ?? 0,
      pendingReturnsCount: (json['pending_returns_count'] as num?)?.toInt() ?? 0,

      // Performance
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 0,
      totalFavorites: (json['total_favorites'] as num?)?.toInt() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  /// Convertit le modèle en Map JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'total_users': totalUsers,
      'total_products': totalProducts,
      'total_categories': totalCategories,
      'total_brands': totalBrands,
      'average_order_value': averageOrderValue,
      'conversion_rate': conversionRate,
      'sales_by_day': salesByDay,
      'orders_by_status': ordersByStatus,
      'revenue_by_month': revenueByMonth,
      'top_products': topProducts,
      'top_categories': topCategories,
      'recent_orders': recentOrders,
      'recent_users': recentUsers,
      'low_stock_count': lowStockCount,
      'low_stock_products': lowStockProducts,
      'pending_reviews_count': pendingReviewsCount,
      'pending_orders_count': pendingOrdersCount,
      'pending_payments_count': pendingPaymentsCount,
      'pending_returns_count': pendingReturnsCount,
      'total_visits': totalVisits,
      'total_favorites': totalFavorites,
      'total_reviews': totalReviews,
      'average_rating': averageRating,
    };
  }

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  DashboardStats toEntity() {
    return DashboardStats(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      totalUsers: totalUsers,
      totalProducts: totalProducts,
      totalCategories: totalCategories,
      totalBrands: totalBrands,
      averageOrderValue: averageOrderValue,
      conversionRate: conversionRate,
      salesByDay: salesByDay,
      ordersByStatus: ordersByStatus,
      revenueByMonth: revenueByMonth,
      topProducts: topProducts,
      topCategories: topCategories,
      recentOrders: recentOrders,
      recentUsers: recentUsers,
      lowStockCount: lowStockCount,
      lowStockProducts: lowStockProducts,
      pendingReviewsCount: pendingReviewsCount,
      pendingOrdersCount: pendingOrdersCount,
      pendingPaymentsCount: pendingPaymentsCount,
      pendingReturnsCount: pendingReturnsCount,
      totalVisits: totalVisits,
      totalFavorites: totalFavorites,
      totalReviews: totalReviews,
      averageRating: averageRating,
    );
  }

  // ============================================
  // HELPERS PRIVÉS DE PARSING
  // ============================================

  /// Parse une liste de maps depuis le JSON.
  ///
  /// Gère les cas :
  /// - null → []
  /// - [] → []
  /// - [{'key': 'value'}, ...] → [Map<String, dynamic>, ...]
  static List<Map<String, dynamic>> _parseListOfMaps(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Parse une map de String → int depuis le JSON.
  ///
  /// Gère les cas :
  /// - null → {}
  /// - {} → {}
  /// - {'key': 5, ...} → {'key': 5, ...}
  static Map<String, int> _parseMapStringInt(dynamic data) {
    if (data == null) return {};
    if (data is! Map) return {};

    final result = <String, int>{};
    data.forEach((key, value) {
      if (key is String && value is num) {
        result[key] = value.toInt();
      }
    });
    return result;
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  DashboardStatsModel copyWith({
    double? totalRevenue,
    int? totalOrders,
    int? totalUsers,
    int? totalProducts,
    int? totalCategories,
    int? totalBrands,
    double? averageOrderValue,
    double? conversionRate,
    List<Map<String, dynamic>>? salesByDay,
    Map<String, int>? ordersByStatus,
    List<Map<String, dynamic>>? revenueByMonth,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? topCategories,
    List<Map<String, dynamic>>? recentOrders,
    List<Map<String, dynamic>>? recentUsers,
    int? lowStockCount,
    List<Map<String, dynamic>>? lowStockProducts,
    int? pendingReviewsCount,
    int? pendingOrdersCount,
    int? pendingPaymentsCount,
    int? pendingReturnsCount,
    int? totalVisits,
    int? totalFavorites,
    int? totalReviews,
    double? averageRating,
  }) {
    return DashboardStatsModel(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      totalUsers: totalUsers ?? this.totalUsers,
      totalProducts: totalProducts ?? this.totalProducts,
      totalCategories: totalCategories ?? this.totalCategories,
      totalBrands: totalBrands ?? this.totalBrands,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      conversionRate: conversionRate ?? this.conversionRate,
      salesByDay: salesByDay ?? this.salesByDay,
      ordersByStatus: ordersByStatus ?? this.ordersByStatus,
      revenueByMonth: revenueByMonth ?? this.revenueByMonth,
      topProducts: topProducts ?? this.topProducts,
      topCategories: topCategories ?? this.topCategories,
      recentOrders: recentOrders ?? this.recentOrders,
      recentUsers: recentUsers ?? this.recentUsers,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      pendingReviewsCount: pendingReviewsCount ?? this.pendingReviewsCount,
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      pendingPaymentsCount: pendingPaymentsCount ?? this.pendingPaymentsCount,
      pendingReturnsCount: pendingReturnsCount ?? this.pendingReturnsCount,
      totalVisits: totalVisits ?? this.totalVisits,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalReviews: totalReviews ?? this.totalReviews,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStatsModel &&
        other.totalRevenue == totalRevenue &&
        other.totalOrders == totalOrders &&
        other.totalUsers == totalUsers &&
        other.totalProducts == totalProducts;
  }

  @override
  int get hashCode => Object.hash(totalRevenue, totalOrders, totalUsers, totalProducts);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'DashboardStatsModel(revenue: $totalRevenueFormatted, '
        'orders: $totalOrders, users: $totalUsers, '
        'products: $totalProducts, alerts: $totalAlerts)';
  }
}