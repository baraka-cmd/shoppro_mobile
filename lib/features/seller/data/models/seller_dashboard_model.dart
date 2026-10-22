// ============================================
// MODEL : SellerDashboardModel
// ============================================
// Modèle de sérialisation JSON pour le dashboard vendeur.
// Étend SellerDashboard et ajoute les méthodes fromJson/toJson.
//
// Responsabilités :
//   - Parser la réponse API /seller/dashboard
//   - Gérer les valeurs null et les types inattendus
//   - Fournir des conversions sûres (num → double/int)
//   - Fournir des fallbacks pour éviter les crashs UI
// ============================================

import '../../domain/entities/seller_dashboard.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerDashboardModel extends SellerDashboard {
  const SellerDashboardModel({
    super.seller,
    required super.revenue,
    required super.orders,
    required super.products,
    required super.reviews,
    required super.balance,
    super.alerts,
    super.recentOrders,
    super.topProducts,
    super.generatedAt,
    super.fromCache,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerDashboardModel.fromJson(Map<String, dynamic> json) {
    // Parse des KPIs
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};

    return SellerDashboardModel(
      seller: json['seller'] != null
          ? SellerInfoModel.fromJson(
              json['seller'] as Map<String, dynamic>,
            )
          : null,
      revenue: RevenueKpiModel.fromJson(
        kpis['revenue'] as Map<String, dynamic>? ?? {},
      ),
      orders: OrdersKpiModel.fromJson(
        kpis['orders'] as Map<String, dynamic>? ?? {},
      ),
      products: ProductsKpiModel.fromJson(
        kpis['products'] as Map<String, dynamic>? ?? {},
      ),
      reviews: ReviewsKpiModel.fromJson(
        kpis['reviews'] as Map<String, dynamic>? ?? {},
      ),
      balance: BalanceKpiModel.fromJson(
        kpis['balance'] as Map<String, dynamic>? ?? {},
      ),
      alerts: (json['alerts'] as List?)
              ?.whereType<Map>()
              .map((e) => DashboardAlertModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      recentOrders: (json['recent_orders'] as List?)
              ?.whereType<Map>()
              .map((e) => DashboardOrderSummaryModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      topProducts: (json['top_products'] as List?)
              ?.whereType<Map>()
              .map((e) => DashboardTopProductModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList() ??
          const [],
      generatedAt: _parseDate(json['generated_at']),
      fromCache: _parseBool(json['from_cache']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'seller': seller != null
          ? SellerInfoModel.fromEntity(seller!).toJson()
          : null,
      'kpis': {
        'revenue': RevenueKpiModel.fromEntity(revenue).toJson(),
        'orders': OrdersKpiModel.fromEntity(orders).toJson(),
        'products': ProductsKpiModel.fromEntity(products).toJson(),
        'reviews': ReviewsKpiModel.fromEntity(reviews).toJson(),
        'balance': BalanceKpiModel.fromEntity(balance).toJson(),
      },
      'alerts': alerts
          .map((a) => DashboardAlertModel.fromEntity(a).toJson())
          .toList(),
      'recent_orders': recentOrders
          .map((o) => DashboardOrderSummaryModel.fromEntity(o).toJson())
          .toList(),
      'top_products': topProducts
          .map((p) => DashboardTopProductModel.fromEntity(p).toJson())
          .toList(),
      'generated_at': generatedAt?.toIso8601String(),
      'from_cache': fromCache,
    };
  }
}

// ============================================
// MODEL : SellerInfoModel
// ============================================

class SellerInfoModel extends SellerInfo {
  const SellerInfoModel({
    required super.id,
    required super.userId,
    required super.shopName,
    required super.shopSlug,
    super.logoUrl,
    required super.kycStatus,
    required super.kycStatusLabel,
    required super.isVerified,
    required super.isActive,
  });

  factory SellerInfoModel.fromJson(Map<String, dynamic> json) {
    return SellerInfoModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      shopName: _parseString(json['shop_name'], 'Ma boutique'),
      shopSlug: _parseString(json['shop_slug'], 'ma-boutique'),
      logoUrl: _parseNullableString(json['logo_url']),
      kycStatus: _parseString(json['kyc_status'], 'pending'),
      kycStatusLabel: _parseString(json['kyc_status_label'], 'En attente'),
      isVerified: _parseBool(json['is_verified']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
    );
  }

  factory SellerInfoModel.fromEntity(SellerInfo entity) {
    return SellerInfoModel(
      id: entity.id,
      userId: entity.userId,
      shopName: entity.shopName,
      shopSlug: entity.shopSlug,
      logoUrl: entity.logoUrl,
      kycStatus: entity.kycStatus,
      kycStatusLabel: entity.kycStatusLabel,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_name': shopName,
      'shop_slug': shopSlug,
      'logo_url': logoUrl,
      'kyc_status': kycStatus,
      'kyc_status_label': kycStatusLabel,
      'is_verified': isVerified,
      'is_active': isActive,
    };
  }
}

// ============================================
// MODEL : RevenueKpiModel
// ============================================

class RevenueKpiModel extends RevenueKpi {
  const RevenueKpiModel({
    super.total,
    super.totalFormatted,
    super.thisMonth,
    super.thisMonthFormatted,
    super.lastMonth,
    super.lastMonthFormatted,
    super.growthPercent,
    super.growthLabel,
    super.totalCommission,
    super.totalCommissionFormatted,
    super.netRevenue,
    super.netRevenueFormatted,
  });

  factory RevenueKpiModel.fromJson(Map<String, dynamic> json) {
    return RevenueKpiModel(
      total: _parseDouble(json['total']),
      totalFormatted: _parseString(json['total_formatted'], '0 FCFA'),
      thisMonth: _parseDouble(json['this_month']),
      thisMonthFormatted: _parseString(json['this_month_formatted'], '0 FCFA'),
      lastMonth: _parseDouble(json['last_month']),
      lastMonthFormatted: _parseString(json['last_month_formatted'], '0 FCFA'),
      growthPercent: _parseDouble(json['growth_percent']),
      growthLabel: _parseString(json['growth_label'], '0%'),
      totalCommission: _parseDouble(json['total_commission']),
      totalCommissionFormatted:
          _parseString(json['total_commission_formatted'], '0 FCFA'),
      netRevenue: _parseDouble(json['net_revenue']),
      netRevenueFormatted: _parseString(json['net_revenue_formatted'], '0 FCFA'),
    );
  }

  factory RevenueKpiModel.fromEntity(RevenueKpi entity) {
    return RevenueKpiModel(
      total: entity.total,
      totalFormatted: entity.totalFormatted,
      thisMonth: entity.thisMonth,
      thisMonthFormatted: entity.thisMonthFormatted,
      lastMonth: entity.lastMonth,
      lastMonthFormatted: entity.lastMonthFormatted,
      growthPercent: entity.growthPercent,
      growthLabel: entity.growthLabel,
      totalCommission: entity.totalCommission,
      totalCommissionFormatted: entity.totalCommissionFormatted,
      netRevenue: entity.netRevenue,
      netRevenueFormatted: entity.netRevenueFormatted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'total_formatted': totalFormatted,
      'this_month': thisMonth,
      'this_month_formatted': thisMonthFormatted,
      'last_month': lastMonth,
      'last_month_formatted': lastMonthFormatted,
      'growth_percent': growthPercent,
      'growth_label': growthLabel,
      'total_commission': totalCommission,
      'total_commission_formatted': totalCommissionFormatted,
      'net_revenue': netRevenue,
      'net_revenue_formatted': netRevenueFormatted,
    };
  }
}

// ============================================
// MODEL : OrdersKpiModel
// ============================================

class OrdersKpiModel extends OrdersKpi {
  const OrdersKpiModel({
    super.total,
    super.thisMonth,
    super.lastMonth,
    super.toAccept,
    super.toPrepare,
    super.toShip,
    super.shipped,
    super.delivered,
    super.cancelled,
  });

  factory OrdersKpiModel.fromJson(Map<String, dynamic> json) {
    return OrdersKpiModel(
      total: _parseInt(json['total']),
      thisMonth: _parseInt(json['this_month']),
      lastMonth: _parseInt(json['last_month']),
      toAccept: _parseInt(json['to_accept']),
      toPrepare: _parseInt(json['to_prepare']),
      toShip: _parseInt(json['to_ship']),
      shipped: _parseInt(json['shipped']),
      delivered: _parseInt(json['delivered']),
      cancelled: _parseInt(json['cancelled']),
    );
  }

  factory OrdersKpiModel.fromEntity(OrdersKpi entity) {
    return OrdersKpiModel(
      total: entity.total,
      thisMonth: entity.thisMonth,
      lastMonth: entity.lastMonth,
      toAccept: entity.toAccept,
      toPrepare: entity.toPrepare,
      toShip: entity.toShip,
      shipped: entity.shipped,
      delivered: entity.delivered,
      cancelled: entity.cancelled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'this_month': thisMonth,
      'last_month': lastMonth,
      'to_accept': toAccept,
      'to_prepare': toPrepare,
      'to_ship': toShip,
      'shipped': shipped,
      'delivered': delivered,
      'cancelled': cancelled,
    };
  }
}

// ============================================
// MODEL : ProductsKpiModel
// ============================================

class ProductsKpiModel extends ProductsKpi {
  const ProductsKpiModel({
    super.total,
    super.active,
    super.drafts,
    super.archived,
    super.outOfStock,
    super.lowStock,
    super.totalViews,
    super.totalSales,
  });

  factory ProductsKpiModel.fromJson(Map<String, dynamic> json) {
    return ProductsKpiModel(
      total: _parseInt(json['total']),
      active: _parseInt(json['active']),
      drafts: _parseInt(json['drafts']),
      archived: _parseInt(json['archived']),
      outOfStock: _parseInt(json['out_of_stock']),
      lowStock: _parseInt(json['low_stock']),
      totalViews: _parseInt(json['total_views']),
      totalSales: _parseInt(json['total_sales']),
    );
  }

  factory ProductsKpiModel.fromEntity(ProductsKpi entity) {
    return ProductsKpiModel(
      total: entity.total,
      active: entity.active,
      drafts: entity.drafts,
      archived: entity.archived,
      outOfStock: entity.outOfStock,
      lowStock: entity.lowStock,
      totalViews: entity.totalViews,
      totalSales: entity.totalSales,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'drafts': drafts,
      'archived': archived,
      'out_of_stock': outOfStock,
      'low_stock': lowStock,
      'total_views': totalViews,
      'total_sales': totalSales,
    };
  }
}

// ============================================
// MODEL : ReviewsKpiModel
// ============================================

class ReviewsKpiModel extends ReviewsKpi {
  const ReviewsKpiModel({
    super.averageRating,
    super.averageRatingFormatted,
    super.total,
    super.pending,
    super.approved,
    super.rejected,
    super.withPhotos,
    super.toModerate,
  });

  factory ReviewsKpiModel.fromJson(Map<String, dynamic> json) {
    return ReviewsKpiModel(
      averageRating: _parseDouble(json['average_rating']),
      averageRatingFormatted:
          _parseString(json['average_rating_formatted'], '0.0/5'),
      total: _parseInt(json['total']),
      pending: _parseInt(json['pending']),
      approved: _parseInt(json['approved']),
      rejected: _parseInt(json['rejected']),
      withPhotos: _parseInt(json['with_photos']),
      toModerate: _parseInt(json['to_moderate']),
    );
  }

  factory ReviewsKpiModel.fromEntity(ReviewsKpi entity) {
    return ReviewsKpiModel(
      averageRating: entity.averageRating,
      averageRatingFormatted: entity.averageRatingFormatted,
      total: entity.total,
      pending: entity.pending,
      approved: entity.approved,
      rejected: entity.rejected,
      withPhotos: entity.withPhotos,
      toModerate: entity.toModerate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'average_rating_formatted': averageRatingFormatted,
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'with_photos': withPhotos,
      'to_moderate': toModerate,
    };
  }
}

// ============================================
// MODEL : BalanceKpiModel
// ============================================

class BalanceKpiModel extends BalanceKpi {
  const BalanceKpiModel({
    super.available,
    super.availableFormatted,
    super.pending,
    super.pendingFormatted,
    super.total,
    super.totalFormatted,
    super.canRequestPayout,
    super.payoutMethod,
    super.hasPayoutMethod,
  });

  factory BalanceKpiModel.fromJson(Map<String, dynamic> json) {
    return BalanceKpiModel(
      available: _parseDouble(json['available']),
      availableFormatted: _parseString(json['available_formatted'], '0 FCFA'),
      pending: _parseDouble(json['pending']),
      pendingFormatted: _parseString(json['pending_formatted'], '0 FCFA'),
      total: _parseDouble(json['total']),
      totalFormatted: _parseString(json['total_formatted'], '0 FCFA'),
      canRequestPayout: _parseBool(json['can_request_payout']),
      payoutMethod: _parseNullableString(json['payout_method']),
      hasPayoutMethod: _parseBool(json['has_payout_method']),
    );
  }

  factory BalanceKpiModel.fromEntity(BalanceKpi entity) {
    return BalanceKpiModel(
      available: entity.available,
      availableFormatted: entity.availableFormatted,
      pending: entity.pending,
      pendingFormatted: entity.pendingFormatted,
      total: entity.total,
      totalFormatted: entity.totalFormatted,
      canRequestPayout: entity.canRequestPayout,
      payoutMethod: entity.payoutMethod,
      hasPayoutMethod: entity.hasPayoutMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'available_formatted': availableFormatted,
      'pending': pending,
      'pending_formatted': pendingFormatted,
      'total': total,
      'total_formatted': totalFormatted,
      'can_request_payout': canRequestPayout,
      'payout_method': payoutMethod,
      'has_payout_method': hasPayoutMethod,
    };
  }
}

// ============================================
// MODEL : DashboardAlertModel
// ============================================

class DashboardAlertModel extends DashboardAlert {
  const DashboardAlertModel({
    required super.type,
    required super.level,
    required super.message,
    super.count,
    super.action,
    super.icon,
  });

  factory DashboardAlertModel.fromJson(Map<String, dynamic> json) {
    return DashboardAlertModel(
      type: _parseString(json['type'], 'info'),
      level: _parseString(json['level'], 'info'),
      message: _parseString(json['message'], ''),
      count: _parseInt(json['count']),
      action: _parseNullableString(json['action']),
      icon: _parseString(json['icon'], 'info'),
    );
  }

  factory DashboardAlertModel.fromEntity(DashboardAlert entity) {
    return DashboardAlertModel(
      type: entity.type,
      level: entity.level,
      message: entity.message,
      count: entity.count,
      action: entity.action,
      icon: entity.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'level': level,
      'message': message,
      'count': count,
      'action': action,
      'icon': icon,
    };
  }
}

// ============================================
// MODEL : DashboardOrderSummaryModel
// ============================================

class DashboardOrderSummaryModel extends DashboardOrderSummary {
  const DashboardOrderSummaryModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.statusLabel,
    required super.paymentStatus,
    required super.customerName,
    super.itemsCount,
    super.total,
    super.totalFormatted,
    super.createdAt,
    super.createdAtHuman,
  });

  factory DashboardOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardOrderSummaryModel(
      id: _parseInt(json['id']),
      orderNumber: _parseString(json['order_number'], 'CMD-XXXX'),
      status: _parseString(json['status'], 'pending'),
      statusLabel: _parseString(json['status_label'], 'En attente'),
      paymentStatus: _parseString(json['payment_status'], 'pending'),
      customerName: _parseString(json['customer_name'], 'Client'),
      itemsCount: _parseInt(json['items_count']),
      total: _parseDouble(json['total']),
      totalFormatted: _parseString(json['total_formatted'], '0 FCFA'),
      createdAt: _parseDate(json['created_at']),
      createdAtHuman: _parseNullableString(json['created_at_human']),
    );
  }

  factory DashboardOrderSummaryModel.fromEntity(DashboardOrderSummary entity) {
    return DashboardOrderSummaryModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      status: entity.status,
      statusLabel: entity.statusLabel,
      paymentStatus: entity.paymentStatus,
      customerName: entity.customerName,
      itemsCount: entity.itemsCount,
      total: entity.total,
      totalFormatted: entity.totalFormatted,
      createdAt: entity.createdAt,
      createdAtHuman: entity.createdAtHuman,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'status_label': statusLabel,
      'payment_status': paymentStatus,
      'customer_name': customerName,
      'items_count': itemsCount,
      'total': total,
      'total_formatted': totalFormatted,
      'created_at': createdAt?.toIso8601String(),
      'created_at_human': createdAtHuman,
    };
  }
}

// ============================================
// MODEL : DashboardTopProductModel
// ============================================

class DashboardTopProductModel extends DashboardTopProduct {
  const DashboardTopProductModel({
    required super.id,
    required super.name,
    required super.slug,
    super.mainImageUrl,
    super.price,
    super.priceFormatted,
    super.salesCount,
    super.viewsCount,
    super.averageRating,
    super.stock,
    super.isActive,
  });

  factory DashboardTopProductModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopProductModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Produit'),
      slug: _parseString(json['slug'], 'produit'),
      mainImageUrl: _parseNullableString(json['main_image_url']),
      price: _parseDouble(json['price']),
      priceFormatted: _parseString(json['price_formatted'], '0 FCFA'),
      salesCount: _parseInt(json['sales_count']),
      viewsCount: _parseInt(json['views_count']),
      averageRating: _parseDouble(json['average_rating']),
      stock: _parseInt(json['stock']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
    );
  }

  factory DashboardTopProductModel.fromEntity(DashboardTopProduct entity) {
    return DashboardTopProductModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      mainImageUrl: entity.mainImageUrl,
      price: entity.price,
      priceFormatted: entity.priceFormatted,
      salesCount: entity.salesCount,
      viewsCount: entity.viewsCount,
      averageRating: entity.averageRating,
      stock: entity.stock,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'main_image_url': mainImageUrl,
      'price': price,
      'price_formatted': priceFormatted,
      'sales_count': salesCount,
      'views_count': viewsCount,
      'average_rating': averageRating,
      'stock': stock,
      'is_active': isActive,
    };
  }
}

// ============================================
// HELPERS DE PARSING SÉCURISÉS
// ============================================

/// Parse un entier avec fallback à 0.
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Parse un double avec fallback à 0.
double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Parse une string avec fallback.
String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

/// Parse une string nullable.
String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

/// Parse un bool avec fallback.
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

/// Parse une date (ISO 8601 ou null).
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}