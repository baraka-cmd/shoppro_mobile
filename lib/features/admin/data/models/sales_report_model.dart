// ============================================
// MODEL : SalesReportModel
// ============================================
// Modèle de sérialisation pour les rapports de ventes.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (SalesReport).
//
// Responsabilités :
// - Conversion JSON → SalesReport (fromJson)
// - Conversion SalesReport → JSON (toJson)
// - Conversion SalesReport → SalesReportModel (fromEntity)
// - Conversion SalesReportModel → SalesReport (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/sales_report.dart';
import 'dart:convert';
// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [SalesReport].
///
/// Cette classe étend [SalesReport] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class SalesReportModel extends SalesReport {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const SalesReportModel({
    required super.period,
    required super.startDate,
    required super.endDate,
    required super.generatedAt,
    required super.totalRevenue,
    required super.netRevenue,
    required super.taxRevenue,
    required super.shippingRevenue,
    required super.discountAmount,
    required super.refundAmount,
    required super.totalOrders,
    required super.paidOrders,
    required super.pendingOrders,
    required super.cancelledOrders,
    required super.returnedOrders,
    required super.shippedOrders,
    required super.deliveredOrders,
    required super.averageOrderValue,
    required super.medianOrderValue,
    required super.totalCustomers,
    required super.newCustomers,
    required super.activeCustomers,
    required super.loyalCustomers,
    required super.retentionRate,
    required super.totalItemsSold,
    required super.activeProducts,
    required super.outOfStockProducts,
    super.topProduct,
    required super.topProductQuantity,
    required super.comparisonType,
    required super.revenueChange,
    required super.ordersChange,
    required super.customersChange,
    required super.averageOrderChange,
    required super.revenueByDay,
    required super.revenueByWeek,
    required super.revenueByMonth,
    required super.ordersByHour,
    required super.ordersByDayOfWeek,
    required super.topProducts,
    required super.topProductsByQuantity,
    required super.topCategories,
    required super.topBrands,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory SalesReportModel.fromEntity(SalesReport entity) {
    return SalesReportModel(
      period: entity.period,
      startDate: entity.startDate,
      endDate: entity.endDate,
      generatedAt: entity.generatedAt,
      totalRevenue: entity.totalRevenue,
      netRevenue: entity.netRevenue,
      taxRevenue: entity.taxRevenue,
      shippingRevenue: entity.shippingRevenue,
      discountAmount: entity.discountAmount,
      refundAmount: entity.refundAmount,
      totalOrders: entity.totalOrders,
      paidOrders: entity.paidOrders,
      pendingOrders: entity.pendingOrders,
      cancelledOrders: entity.cancelledOrders,
      returnedOrders: entity.returnedOrders,
      shippedOrders: entity.shippedOrders,
      deliveredOrders: entity.deliveredOrders,
      averageOrderValue: entity.averageOrderValue,
      medianOrderValue: entity.medianOrderValue,
      totalCustomers: entity.totalCustomers,
      newCustomers: entity.newCustomers,
      activeCustomers: entity.activeCustomers,
      loyalCustomers: entity.loyalCustomers,
      retentionRate: entity.retentionRate,
      totalItemsSold: entity.totalItemsSold,
      activeProducts: entity.activeProducts,
      outOfStockProducts: entity.outOfStockProducts,
      topProduct: entity.topProduct,
      topProductQuantity: entity.topProductQuantity,
      comparisonType: entity.comparisonType,
      revenueChange: entity.revenueChange,
      ordersChange: entity.ordersChange,
      customersChange: entity.customersChange,
      averageOrderChange: entity.averageOrderChange,
      revenueByDay: entity.revenueByDay,
      revenueByWeek: entity.revenueByWeek,
      revenueByMonth: entity.revenueByMonth,
      ordersByHour: entity.ordersByHour,
      ordersByDayOfWeek: entity.ordersByDayOfWeek,
      topProducts: entity.topProducts,
      topProductsByQuantity: entity.topProductsByQuantity,
      topCategories: entity.topCategories,
      topBrands: entity.topBrands,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      // Informations de base
      period: SalesReportPeriod.fromCode(json['period'] as String?),
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ?? DateTime.now(),

      // Revenus
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0,
      taxRevenue: (json['tax_revenue'] as num?)?.toDouble() ?? 0,
      shippingRevenue: (json['shipping_revenue'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,

      // Commandes
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      paidOrders: (json['paid_orders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pending_orders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelled_orders'] as num?)?.toInt() ?? 0,
      returnedOrders: (json['returned_orders'] as num?)?.toInt() ?? 0,
      shippedOrders: (json['shipped_orders'] as num?)?.toInt() ?? 0,
      deliveredOrders: (json['delivered_orders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0,
      medianOrderValue: (json['median_order_value'] as num?)?.toDouble() ?? 0,

      // Clients
      totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
      newCustomers: (json['new_customers'] as num?)?.toInt() ?? 0,
      activeCustomers: (json['active_customers'] as num?)?.toInt() ?? 0,
      loyalCustomers: (json['loyal_customers'] as num?)?.toInt() ?? 0,
      retentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0,

      // Produits
      totalItemsSold: (json['total_items_sold'] as num?)?.toInt() ?? 0,
      activeProducts: (json['active_products'] as num?)?.toInt() ?? 0,
      outOfStockProducts: (json['out_of_stock_products'] as num?)?.toInt() ?? 0,
      topProduct: json['top_product'] as String?,
      topProductQuantity: (json['top_product_quantity'] as num?)?.toInt() ?? 0,

      // Comparaison
      comparisonType: SalesComparisonType.fromCode(json['comparison_type'] as String?),
      revenueChange: (json['revenue_change'] as num?)?.toDouble() ?? 0,
      ordersChange: (json['orders_change'] as num?)?.toDouble() ?? 0,
      customersChange: (json['customers_change'] as num?)?.toDouble() ?? 0,
      averageOrderChange: (json['average_order_change'] as num?)?.toDouble() ?? 0,

      // Données de graphiques
      revenueByDay: _parseListOfMaps(json['revenue_by_day']),
      revenueByWeek: _parseListOfMaps(json['revenue_by_week']),
      revenueByMonth: _parseListOfMaps(json['revenue_by_month']),
      ordersByHour: _parseListOfMaps(json['orders_by_hour']),
      ordersByDayOfWeek: _parseListOfMaps(json['orders_by_day_of_week']),

      // Top éléments
      topProducts: _parseListOfMaps(json['top_products']),
      topProductsByQuantity: _parseListOfMaps(json['top_products_by_quantity']),
      topCategories: _parseListOfMaps(json['top_categories']),
      topBrands: _parseListOfMaps(json['top_brands']),
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  /// Convertit le modèle en Map JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'period': period.code,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'total_revenue': totalRevenue,
      'net_revenue': netRevenue,
      'tax_revenue': taxRevenue,
      'shipping_revenue': shippingRevenue,
      'discount_amount': discountAmount,
      'refund_amount': refundAmount,
      'total_orders': totalOrders,
      'paid_orders': paidOrders,
      'pending_orders': pendingOrders,
      'cancelled_orders': cancelledOrders,
      'returned_orders': returnedOrders,
      'shipped_orders': shippedOrders,
      'delivered_orders': deliveredOrders,
      'average_order_value': averageOrderValue,
      'median_order_value': medianOrderValue,
      'total_customers': totalCustomers,
      'new_customers': newCustomers,
      'active_customers': activeCustomers,
      'loyal_customers': loyalCustomers,
      'retention_rate': retentionRate,
      'total_items_sold': totalItemsSold,
      'active_products': activeProducts,
      'out_of_stock_products': outOfStockProducts,
      'top_product': topProduct,
      'top_product_quantity': topProductQuantity,
      'comparison_type': comparisonType.code,
      'revenue_change': revenueChange,
      'orders_change': ordersChange,
      'customers_change': customersChange,
      'average_order_change': averageOrderChange,
      'revenue_by_day': revenueByDay,
      'revenue_by_week': revenueByWeek,
      'revenue_by_month': revenueByMonth,
      'orders_by_hour': ordersByHour,
      'orders_by_day_of_week': ordersByDayOfWeek,
      'top_products': topProducts,
      'top_products_by_quantity': topProductsByQuantity,
      'top_categories': topCategories,
      'top_brands': topBrands,
    };
  }

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  SalesReport toEntity() {
    return SalesReport(
      period: period,
      startDate: startDate,
      endDate: endDate,
      generatedAt: generatedAt,
      totalRevenue: totalRevenue,
      netRevenue: netRevenue,
      taxRevenue: taxRevenue,
      shippingRevenue: shippingRevenue,
      discountAmount: discountAmount,
      refundAmount: refundAmount,
      totalOrders: totalOrders,
      paidOrders: paidOrders,
      pendingOrders: pendingOrders,
      cancelledOrders: cancelledOrders,
      returnedOrders: returnedOrders,
      shippedOrders: shippedOrders,
      deliveredOrders: deliveredOrders,
      averageOrderValue: averageOrderValue,
      medianOrderValue: medianOrderValue,
      totalCustomers: totalCustomers,
      newCustomers: newCustomers,
      activeCustomers: activeCustomers,
      loyalCustomers: loyalCustomers,
      retentionRate: retentionRate,
      totalItemsSold: totalItemsSold,
      activeProducts: activeProducts,
      outOfStockProducts: outOfStockProducts,
      topProduct: topProduct,
      topProductQuantity: topProductQuantity,
      comparisonType: comparisonType,
      revenueChange: revenueChange,
      ordersChange: ordersChange,
      customersChange: customersChange,
      averageOrderChange: averageOrderChange,
      revenueByDay: revenueByDay,
      revenueByWeek: revenueByWeek,
      revenueByMonth: revenueByMonth,
      ordersByHour: ordersByHour,
      ordersByDayOfWeek: ordersByDayOfWeek,
      topProducts: topProducts,
      topProductsByQuantity: topProductsByQuantity,
      topCategories: topCategories,
      topBrands: topBrands,
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

  // ============================================
  // HELPERS D'EXPORT
  // ============================================

  /// Convertit le rapport en format CSV.
  ///
  /// Retourne une String contenant les données en CSV.
  String toCsv() {
    final buffer = StringBuffer();

    // En-têtes
    buffer.writeln('Période,Revenu total,Revenu net,Commandes,Clients,Panier moyen');

    // Données
    buffer.writeln(
      '$periodName,$totalRevenue,$netRevenue,$totalOrders,$totalCustomers,$averageOrderValue',
    );

    buffer.writeln();
    buffer.writeln('Statistiques détaillées');
    buffer.writeln('Taxes,$taxRevenue');
    buffer.writeln('Livraison,$shippingRevenue');
    buffer.writeln('Remises,$discountAmount');
    buffer.writeln('Remboursements,$refundAmount');
    buffer.writeln('Commandes payées,$paidOrders');
    buffer.writeln('Commandes livrées,$deliveredOrders');
    buffer.writeln('Commandes annulées,$cancelledOrders');
    buffer.writeln('Articles vendus,$totalItemsSold');
    buffer.writeln('Nouveaux clients,$newCustomers');
    buffer.writeln('Taux de rétention,$retentionRate%');
    buffer.writeln('Taux de conversion,$conversionRate%');

    return buffer.toString();
  }

  /// Convertit le rapport en format JSON lisible.
  ///
  /// Retourne une String JSON formatée.
  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  SalesReportModel copyWith({
    SalesReportPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedAt,
    double? totalRevenue,
    double? netRevenue,
    double? taxRevenue,
    double? shippingRevenue,
    double? discountAmount,
    double? refundAmount,
    int? totalOrders,
    int? paidOrders,
    int? pendingOrders,
    int? cancelledOrders,
    int? returnedOrders,
    int? shippedOrders,
    int? deliveredOrders,
    double? averageOrderValue,
    double? medianOrderValue,
    int? totalCustomers,
    int? newCustomers,
    int? activeCustomers,
    int? loyalCustomers,
    double? retentionRate,
    int? totalItemsSold,
    int? activeProducts,
    int? outOfStockProducts,
    String? topProduct,
    int? topProductQuantity,
    SalesComparisonType? comparisonType,
    double? revenueChange,
    double? ordersChange,
    double? customersChange,
    double? averageOrderChange,
    List<Map<String, dynamic>>? revenueByDay,
    List<Map<String, dynamic>>? revenueByWeek,
    List<Map<String, dynamic>>? revenueByMonth,
    List<Map<String, dynamic>>? ordersByHour,
    List<Map<String, dynamic>>? ordersByDayOfWeek,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? topProductsByQuantity,
    List<Map<String, dynamic>>? topCategories,
    List<Map<String, dynamic>>? topBrands,
  }) {
    return SalesReportModel(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedAt: generatedAt ?? this.generatedAt,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      netRevenue: netRevenue ?? this.netRevenue,
      taxRevenue: taxRevenue ?? this.taxRevenue,
      shippingRevenue: shippingRevenue ?? this.shippingRevenue,
      discountAmount: discountAmount ?? this.discountAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      totalOrders: totalOrders ?? this.totalOrders,
      paidOrders: paidOrders ?? this.paidOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      returnedOrders: returnedOrders ?? this.returnedOrders,
      shippedOrders: shippedOrders ?? this.shippedOrders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      medianOrderValue: medianOrderValue ?? this.medianOrderValue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      newCustomers: newCustomers ?? this.newCustomers,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      loyalCustomers: loyalCustomers ?? this.loyalCustomers,
      retentionRate: retentionRate ?? this.retentionRate,
      totalItemsSold: totalItemsSold ?? this.totalItemsSold,
      activeProducts: activeProducts ?? this.activeProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      topProduct: topProduct ?? this.topProduct,
      topProductQuantity: topProductQuantity ?? this.topProductQuantity,
      comparisonType: comparisonType ?? this.comparisonType,
      revenueChange: revenueChange ?? this.revenueChange,
      ordersChange: ordersChange ?? this.ordersChange,
      customersChange: customersChange ?? this.customersChange,
      averageOrderChange: averageOrderChange ?? this.averageOrderChange,
      revenueByDay: revenueByDay ?? this.revenueByDay,
      revenueByWeek: revenueByWeek ?? this.revenueByWeek,
      revenueByMonth: revenueByMonth ?? this.revenueByMonth,
      ordersByHour: ordersByHour ?? this.ordersByHour,
      ordersByDayOfWeek: ordersByDayOfWeek ?? this.ordersByDayOfWeek,
      topProducts: topProducts ?? this.topProducts,
      topProductsByQuantity: topProductsByQuantity ?? this.topProductsByQuantity,
      topCategories: topCategories ?? this.topCategories,
      topBrands: topBrands ?? this.topBrands,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesReportModel &&
        other.period == period &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalRevenue == totalRevenue;
  }

  @override
  int get hashCode => Object.hash(period, startDate, endDate, totalRevenue);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SalesReportModel(period: ${period.displayName}, '
        'revenue: $totalRevenueFormatted, orders: $totalOrders, '
        'customers: $totalCustomers, change: $revenueChangeFormatted)';
  }
}