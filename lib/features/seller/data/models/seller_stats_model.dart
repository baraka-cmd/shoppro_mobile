// ============================================
// MODEL : SellerStatsModel
// ============================================
// Sérialisation JSON pour les statistiques vendeur.
//
// Responsabilités :
//   - Parser la réponse API /seller/stats/*
//   - Gérer les valeurs null (parsing défensif)
//   - Convertir types (num → double/int)
//   - Fournir des fallbacks sûrs
// ============================================

import '../../domain/entities/seller_stats.dart';

// ============================================
// MODEL : SellerSalesStatsModel
// ============================================

class SellerSalesStatsModel extends SellerSalesStats {
  const SellerSalesStatsModel({
    required super.totalRevenue,
    required super.previousRevenue,
    required super.totalOrders,
    required super.previousOrders,
    required super.totalItems,
    required super.previousItems,
    required super.averageOrderValue,
    required super.previousAverageOrderValue,
    super.timeline,
    required super.periodDays,
    required super.periodLabel,
    super.startDate,
    super.endDate,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerSalesStatsModel.fromJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};

    // Extraire les valeurs depuis les KPIs (structure imbriquée)
    final revenueKpi = _extractKpi(kpis['total_revenue']);
    final ordersKpi = _extractKpi(kpis['total_orders']);
    final itemsKpi = _extractKpi(kpis['total_items']);
    final avgKpi = _extractKpi(kpis['average_order_value']);

    final comparison = json['comparison'] as Map<String, dynamic>? ?? {};
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final timeline = json['timeline'];

    return SellerSalesStatsModel(
      totalRevenue: revenueKpi.value,
      previousRevenue: _parseDouble(comparison['previous_revenue']),
      totalOrders: ordersKpi.value.toInt(),
      previousOrders: _parseInt(comparison['previous_orders']),
      totalItems: itemsKpi.value.toInt(),
      previousItems: 0, // Pas exposé dans la réponse
      averageOrderValue: avgKpi.value,
      previousAverageOrderValue: 0,
      timeline: _parseTimeline(timeline),
      periodDays: _parseInt(period['days'], defaultValue: 30),
      periodLabel: _parseString(period['label'], '30 derniers jours'),
      startDate: _parseDate(period['start_date']),
      endDate: _parseDate(period['end_date']),
    );
  }

  // ============================================
  // HELPER : Extraction KPI
  // ============================================

  static _KpiValue _extractKpi(dynamic kpi) {
    if (kpi is Map) {
      return _KpiValue(
        value: _parseDouble(kpi['value']),
        formatted: _parseString(kpi['formatted']),
        growthPercent: _parseDouble(kpi['growth_percent']),
        growthLabel: _parseString(kpi['growth_label'], '0%'),
        isPositive: _parseBool(kpi['is_positive'], defaultValue: true),
      );
    }
    return const _KpiValue();
  }

  // ============================================
  // HELPER : Timeline
  // ============================================

  static List<SellerSalesTimelinePoint> _parseTimeline(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return SellerSalesTimelinePoint(
            date: _parseString(map['date']),
            dateFormatted: _parseString(map['date_formatted']),
            dayName: _parseString(map['day_name']),
            revenue: _parseDouble(map['revenue']),
            orders: _parseInt(map['orders']),
            items: _parseInt(map['items']),
          );
        })
        .toList();
  }

  // ============================================
  // toJson
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'previous_revenue': previousRevenue,
      'total_orders': totalOrders,
      'previous_orders': previousOrders,
      'total_items': totalItems,
      'previous_items': previousItems,
      'average_order_value': averageOrderValue,
      'previous_average_order_value': previousAverageOrderValue,
      'timeline': timeline.map((p) => {
        'date': p.date,
        'date_formatted': p.dateFormatted,
        'day_name': p.dayName,
        'revenue': p.revenue,
        'orders': p.orders,
        'items': p.items,
      }).toList(),
      'period_days': periodDays,
      'period_label': periodLabel,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

// ============================================
// CLASSE INTERNE : _KpiValue
// ============================================

class _KpiValue {
  final double value;
  final String formatted;
  final double growthPercent;
  final String growthLabel;
  final bool isPositive;

  const _KpiValue({
    this.value = 0,
    this.formatted = '',
    this.growthPercent = 0,
    this.growthLabel = '0%',
    this.isPositive = true,
  });
}

// ============================================
// MODEL : SellerProductStatsModel
// ============================================

class SellerProductStatsModel extends SellerProductStats {
  const SellerProductStatsModel({
    super.topProducts,
    super.topCategories,
    super.totalProductsSold,
    super.uniqueProducts,
    super.totalRevenue,
    super.periodDays,
    super.periodLabel,
  });

  factory SellerProductStatsModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};

    return SellerProductStatsModel(
      topProducts: _parseProducts(json['top_products']),
      topCategories: _parseCategories(json['top_categories']),
      totalProductsSold: _parseInt(json['total_products_sold']),
      uniqueProducts: _parseInt(json['unique_products']),
      totalRevenue: _parseDouble(json['total_revenue']),
      periodDays: _parseInt(period['days'], defaultValue: 30),
      periodLabel: _parseString(period['label'], '30 derniers jours'),
    );
  }

  static List<SellerProductStat> _parseProducts(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return SellerProductStat(
            rank: _parseInt(map['rank']),
            id: _parseInt(map['id']),
            name: _parseString(map['name'], 'Produit'),
            sku: _parseString(map['sku']),
            imageUrl: _parseNullableString(map['image_url']),
            quantitySold: _parseInt(map['quantity_sold']),
            revenue: _parseDouble(map['revenue']),
            revenueFormatted: _parseString(map['revenue_formatted'], '0 FCFA'),
            ordersCount: _parseInt(map['orders_count']),
            averageRating: _parseDouble(map['average_rating']),
            viewsCount: _parseInt(map['views_count']),
            rankMedal: _parseNullableString(map['rank_medal']),
          );
        })
        .toList();
  }

  static List<SellerCategoryStat> _parseCategories(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return SellerCategoryStat(
            rank: _parseInt(map['rank']),
            id: _parseInt(map['id']),
            name: _parseString(map['name'], 'Catégorie'),
            productsSold: _parseInt(map['products_sold']),
            revenue: _parseDouble(map['revenue']),
            revenueFormatted: _parseString(map['revenue_formatted'], '0 FCFA'),
            percentage: _parseDouble(map['percentage']),
          );
        })
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'top_products': topProducts.map((p) => {
        'rank': p.rank,
        'id': p.id,
        'name': p.name,
        'sku': p.sku,
        'image_url': p.imageUrl,
        'quantity_sold': p.quantitySold,
        'revenue': p.revenue,
        'revenue_formatted': p.revenueFormatted,
        'orders_count': p.ordersCount,
        'average_rating': p.averageRating,
        'views_count': p.viewsCount,
        'rank_medal': p.rankMedal,
      }).toList(),
      'top_categories': topCategories.map((c) => {
        'rank': c.rank,
        'id': c.id,
        'name': c.name,
        'products_sold': c.productsSold,
        'revenue': c.revenue,
        'revenue_formatted': c.revenueFormatted,
        'percentage': c.percentage,
      }).toList(),
      'total_products_sold': totalProductsSold,
      'unique_products': uniqueProducts,
      'total_revenue': totalRevenue,
      'period_days': periodDays,
      'period_label': periodLabel,
    };
  }
}

// ============================================
// MODEL : SellerCustomerStatsModel
// ============================================

class SellerCustomerStatsModel extends SellerCustomerStats {
  const SellerCustomerStatsModel({
    super.topCustomers,
    super.newCustomers,
    super.returningCustomers,
    super.loyalCustomers,
    super.totalCustomers,
    super.newPercentage,
    super.returningPercentage,
    super.loyalPercentage,
    super.totalRevenue,
    super.averageCustomerValue,
    super.periodDays,
    super.periodLabel,
  });

  factory SellerCustomerStatsModel.fromJson(Map<String, dynamic> json) {
    final segments = json['segments'] as Map<String, dynamic>? ?? {};
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final period = json['period'] as Map<String, dynamic>? ?? {};

    return SellerCustomerStatsModel(
      topCustomers: _parseCustomers(json['top_customers']),
      newCustomers: _parseInt(segments['new_customers']),
      returningCustomers: _parseInt(segments['returning_customers']),
      loyalCustomers: _parseInt(segments['loyal_customers']),
      totalCustomers: _parseInt(segments['total_customers']),
      newPercentage: _parseDouble(segments['new_percentage']),
      returningPercentage: _parseDouble(segments['returning_percentage']),
      loyalPercentage: _parseDouble(segments['loyal_percentage']),
      totalRevenue: _parseDouble(summary['total_revenue']),
      averageCustomerValue: _parseDouble(summary['average_customer_value']),
      periodDays: _parseInt(period['days'], defaultValue: 30),
      periodLabel: _parseString(period['label'], '30 derniers jours'),
    );
  }

  static List<SellerCustomerStat> _parseCustomers(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return SellerCustomerStat(
            rank: _parseInt(map['rank']),
            id: _parseInt(map['id']),
            name: _parseString(map['name'], 'Client'),
            initials: _parseString(map['initials'], '?'),
            ordersCount: _parseInt(map['orders_count']),
            totalSpent: _parseDouble(map['total_spent']),
            totalSpentFormatted: _parseString(map['total_spent_formatted'], '0 FCFA'),
            averageOrder: _parseDouble(map['average_order']),
            averageOrderFormatted: _parseString(map['average_order_formatted'], '0 FCFA'),
            lastOrderAt: _parseDate(map['last_order_at']),
            lastOrderHuman: _parseNullableString(map['last_order_human']),
            isLoyal: _parseBool(map['is_loyal']),
            isNew: _parseBool(map['is_new']),
          );
        })
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'top_customers': topCustomers.map((c) => {
        'rank': c.rank,
        'id': c.id,
        'name': c.name,
        'initials': c.initials,
        'orders_count': c.ordersCount,
        'total_spent': c.totalSpent,
        'total_spent_formatted': c.totalSpentFormatted,
        'average_order': c.averageOrder,
        'average_order_formatted': c.averageOrderFormatted,
        'last_order_at': c.lastOrderAt?.toIso8601String(),
        'last_order_human': c.lastOrderHuman,
        'is_loyal': c.isLoyal,
        'is_new': c.isNew,
      }).toList(),
      'new_customers': newCustomers,
      'returning_customers': returningCustomers,
      'loyal_customers': loyalCustomers,
      'total_customers': totalCustomers,
      'new_percentage': newPercentage,
      'returning_percentage': returningPercentage,
      'loyal_percentage': loyalPercentage,
      'total_revenue': totalRevenue,
      'average_customer_value': averageCustomerValue,
      'period_days': periodDays,
      'period_label': periodLabel,
    };
  }
}

// ============================================
// HELPERS DE PARSING
// ============================================

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}