// ============================================
// ENTITÉ : SellerDashboard
// ============================================
// Représente les données complètes du dashboard vendeur.
//
// Structure hiérarchique :
//   SellerDashboard
//   ├── SellerInfo (infos boutique)
//   ├── DashboardKpis (5 catégories de KPIs)
//   │   ├── RevenueKpi
//   │   ├── OrdersKpi
//   │   ├── ProductsKpi
//   │   ├── ReviewsKpi
//   │   └── BalanceKpi
//   ├── List<DashboardAlert>
//   ├── List<DashboardOrderSummary>
//   └── List<DashboardTopProduct>
//
// Aucune dépendance Flutter : cette entité est PURE Dart.
// ============================================

class SellerDashboard {
  // ============================================
  // INFOS VENDEUR
  // ============================================
  final SellerInfo? seller;

  // ============================================
  // KPIs
  // ============================================
  final RevenueKpi revenue;
  final OrdersKpi orders;
  final ProductsKpi products;
  final ReviewsKpi reviews;
  final BalanceKpi balance;

  // ============================================
  // ALERTES ACTIONNABLES
  // ============================================
  final List<DashboardAlert> alerts;

  // ============================================
  // LISTES
  // ============================================
  final List<DashboardOrderSummary> recentOrders;
  final List<DashboardTopProduct> topProducts;

  // ============================================
  // MÉTADONNÉES
  // ============================================
  final DateTime? generatedAt;
  final bool fromCache;

  const SellerDashboard({
    this.seller,
    required this.revenue,
    required this.orders,
    required this.products,
    required this.reviews,
    required this.balance,
    this.alerts = const [],
    this.recentOrders = const [],
    this.topProducts = const [],
    this.generatedAt,
    this.fromCache = false,
  });

  // ============================================
  // GETTERS UTILITAIRES
  // ============================================

  /// Le vendeur a-t-il des alertes ?
  bool get hasAlerts => alerts.isNotEmpty;
  int get alertsCount => alerts.length;

  /// Le vendeur a-t-il des commandes récentes ?
  bool get hasRecentOrders => recentOrders.isNotEmpty;

  /// Le vendeur a-t-il des top produits ?
  bool get hasTopProducts => topProducts.isNotEmpty;

  /// Le dashboard est-il vide (première connexion) ?
  bool get isEmpty =>
      orders.total == 0 &&
      products.total == 0 &&
      revenue.total == 0 &&
      reviews.total == 0;

  /// Nombre d'alertes critiques (danger)
  int get criticalAlertsCount =>
      alerts.where((a) => a.isDanger).length;

  /// Nombre d'alertes warning
  int get warningAlertsCount =>
      alerts.where((a) => a.isWarning).length;

  // ============================================
  // COPYWITH
  // ============================================

  SellerDashboard copyWith({
    SellerInfo? seller,
    RevenueKpi? revenue,
    OrdersKpi? orders,
    ProductsKpi? products,
    ReviewsKpi? reviews,
    BalanceKpi? balance,
    List<DashboardAlert>? alerts,
    List<DashboardOrderSummary>? recentOrders,
    List<DashboardTopProduct>? topProducts,
    DateTime? generatedAt,
    bool? fromCache,
  }) {
    return SellerDashboard(
      seller: seller ?? this.seller,
      revenue: revenue ?? this.revenue,
      orders: orders ?? this.orders,
      products: products ?? this.products,
      reviews: reviews ?? this.reviews,
      balance: balance ?? this.balance,
      alerts: alerts ?? this.alerts,
      recentOrders: recentOrders ?? this.recentOrders,
      topProducts: topProducts ?? this.topProducts,
      generatedAt: generatedAt ?? this.generatedAt,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SellerDashboard(seller: ${seller?.shopName}, '
        'revenue: ${revenue.total}, orders: ${orders.total}, '
        'products: ${products.active}, alerts: ${alerts.length})';
  }
}

// ============================================
// ENTITÉ : SellerInfo
// ============================================
// Informations de la boutique du vendeur.
// ============================================

class SellerInfo {
  final int id;
  final int userId;
  final String shopName;
  final String shopSlug;
  final String? logoUrl;
  final String kycStatus;
  final String kycStatusLabel;
  final bool isVerified;
  final bool isActive;

  const SellerInfo({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.shopSlug,
    this.logoUrl,
    required this.kycStatus,
    required this.kycStatusLabel,
    required this.isVerified,
    required this.isActive,
  });

  // ============================================
  // GETTERS KYC
  // ============================================

  bool get isKycVerified => kycStatus == 'verified';
  bool get isKycPending => kycStatus == 'pending';
  bool get isKycRejected => kycStatus == 'rejected';

  /// A-t-il un logo affichable ?
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Initiales (fallback si pas de logo)
  String get initials {
    final words = shopName.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return shopName.isNotEmpty ? shopName[0].toUpperCase() : 'B';
  }

  @override
  String toString() {
    return 'SellerInfo(id: $id, shopName: $shopName, kyc: $kycStatus)';
  }
}

// ============================================
// ENTITÉ : RevenueKpi
// ============================================
// KPIs de revenus.
// ============================================

class RevenueKpi {
  final double total;
  final String totalFormatted;
  final double thisMonth;
  final String thisMonthFormatted;
  final double lastMonth;
  final String lastMonthFormatted;
  final double growthPercent;
  final String growthLabel;
  final double totalCommission;
  final String totalCommissionFormatted;
  final double netRevenue;
  final String netRevenueFormatted;

  const RevenueKpi({
    this.total = 0,
    this.totalFormatted = '0 FCFA',
    this.thisMonth = 0,
    this.thisMonthFormatted = '0 FCFA',
    this.lastMonth = 0,
    this.lastMonthFormatted = '0 FCFA',
    this.growthPercent = 0,
    this.growthLabel = '0%',
    this.totalCommission = 0,
    this.totalCommissionFormatted = '0 FCFA',
    this.netRevenue = 0,
    this.netRevenueFormatted = '0 FCFA',
  });

  /// Croissance positive ?
  bool get isGrowthPositive => growthPercent > 0;
  bool get isGrowthNegative => growthPercent < 0;
  bool get hasGrowth => growthPercent != 0;

  @override
  String toString() => 'RevenueKpi(total: $totalFormatted, growth: $growthLabel)';
}

// ============================================
// ENTITÉ : OrdersKpi
// ============================================
// KPIs des commandes.
// ============================================

class OrdersKpi {
  final int total;
  final int thisMonth;
  final int lastMonth;
  final int toAccept;
  final int toPrepare;
  final int toShip;
  final int shipped;
  final int delivered;
  final int cancelled;

  const OrdersKpi({
    this.total = 0,
    this.thisMonth = 0,
    this.lastMonth = 0,
    this.toAccept = 0,
    this.toPrepare = 0,
    this.toShip = 0,
    this.shipped = 0,
    this.delivered = 0,
    this.cancelled = 0,
  });

  /// Nombre de commandes en attente d'action
  int get pendingCount => toAccept + toPrepare + toShip;

  /// Le vendeur a-t-il des commandes à traiter ?
  bool get hasPending => pendingCount > 0;

  @override
  String toString() =>
      'OrdersKpi(total: $total, pending: $pendingCount, delivered: $delivered)';
}

// ============================================
// ENTITÉ : ProductsKpi
// ============================================
// KPIs des produits.
// ============================================

class ProductsKpi {
  final int total;
  final int active;
  final int drafts;
  final int archived;
  final int outOfStock;
  final int lowStock;
  final int totalViews;
  final int totalSales;

  const ProductsKpi({
    this.total = 0,
    this.active = 0,
    this.drafts = 0,
    this.archived = 0,
    this.outOfStock = 0,
    this.lowStock = 0,
    this.totalViews = 0,
    this.totalSales = 0,
  });

  /// Le vendeur a-t-il des problèmes de stock ?
  bool get hasStockIssues => outOfStock > 0 || lowStock > 0;

  @override
  String toString() =>
      'ProductsKpi(total: $total, active: $active, outOfStock: $outOfStock)';
}

// ============================================
// ENTITÉ : ReviewsKpi
// ============================================
// KPIs des avis.
// ============================================

class ReviewsKpi {
  final double averageRating;
  final String averageRatingFormatted;
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int withPhotos;
  final int toModerate;

  const ReviewsKpi({
    this.averageRating = 0,
    this.averageRatingFormatted = '0.0/5',
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.withPhotos = 0,
    this.toModerate = 0,
  });

  /// Le vendeur a-t-il des avis à modérer ?
  bool get hasPendingModeration => toModerate > 0;

  /// Note excellente ?
  bool get isExcellentRating => averageRating >= 4.5;

  @override
  String toString() =>
      'ReviewsKpi(rating: $averageRatingFormatted, total: $total)';
}

// ============================================
// ENTITÉ : BalanceKpi
// ============================================
// KPIs du solde financier.
// ============================================

class BalanceKpi {
  final double available;
  final String availableFormatted;
  final double pending;
  final String pendingFormatted;
  final double total;
  final String totalFormatted;
  final bool canRequestPayout;
  final String? payoutMethod;
  final bool hasPayoutMethod;

  const BalanceKpi({
    this.available = 0,
    this.availableFormatted = '0 FCFA',
    this.pending = 0,
    this.pendingFormatted = '0 FCFA',
    this.total = 0,
    this.totalFormatted = '0 FCFA',
    this.canRequestPayout = false,
    this.payoutMethod,
    this.hasPayoutMethod = false,
  });

  /// Le vendeur a-t-il un solde disponible ?
  bool get hasAvailableBalance => available > 0;

  @override
  String toString() =>
      'BalanceKpi(available: $availableFormatted, pending: $pendingFormatted)';
}

// ============================================
// ENTITÉ : DashboardAlert
// ============================================
// Alerte actionnable affichée sur le dashboard.
// ============================================

enum DashboardAlertLevel {
  info,
  warning,
  danger,
}

class DashboardAlert {
  final String type;
  final String level;
  final String message;
  final int count;
  final String? action;
  final String icon;

  const DashboardAlert({
    required this.type,
    required this.level,
    required this.message,
    this.count = 0,
    this.action,
    this.icon = 'info',
  });

  // ============================================
  // GETTERS NIVEAU
  // ============================================

  bool get isInfo => level == 'info';
  bool get isWarning => level == 'warning';
  bool get isDanger => level == 'danger';

  DashboardAlertLevel get levelEnum {
    switch (level) {
      case 'warning':
        return DashboardAlertLevel.warning;
      case 'danger':
        return DashboardAlertLevel.danger;
      default:
        return DashboardAlertLevel.info;
    }
  }

  /// L'alerte a-t-elle un compte affichable ?
  bool get hasCount => count > 0;

  @override
  String toString() => 'DashboardAlert(type: $type, level: $level, msg: $message)';
}

// ============================================
// ENTITÉ : DashboardOrderSummary
// ============================================
// Résumé d'une commande récente.
// ============================================

class DashboardOrderSummary {
  final int id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String customerName;
  final int itemsCount;
  final double total;
  final String totalFormatted;
  final DateTime? createdAt;
  final String? createdAtHuman;

  const DashboardOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.customerName,
    this.itemsCount = 0,
    this.total = 0,
    this.totalFormatted = '0 FCFA',
    this.createdAt,
    this.createdAtHuman,
  });

  /// La commande est-elle en attente d'action ?
  bool get isPending =>
      status == 'pending' || status == 'confirmed' || status == 'processing';

  /// La commande est-elle livrée ?
  bool get isDelivered => status == 'delivered';

  /// La commande est-elle annulée ?
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() =>
      'DashboardOrderSummary($orderNumber: $statusLabel, total: $totalFormatted)';
}

// ============================================
// ENTITÉ : DashboardTopProduct
// ============================================
// Résumé d'un top produit.
// ============================================

class DashboardTopProduct {
  final int id;
  final String name;
  final String slug;
  final String? mainImageUrl;
  final double price;
  final String priceFormatted;
  final int salesCount;
  final int viewsCount;
  final double averageRating;
  final int stock;
  final bool isActive;

  const DashboardTopProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.mainImageUrl,
    this.price = 0,
    this.priceFormatted = '0 FCFA',
    this.salesCount = 0,
    this.viewsCount = 0,
    this.averageRating = 0,
    this.stock = 0,
    this.isActive = true,
  });

  /// Le produit a-t-il une image ?
  bool get hasImage => mainImageUrl != null && mainImageUrl!.isNotEmpty;

  /// Le produit est-il en rupture ?
  bool get isOutOfStock => stock <= 0;

  /// Le produit est-il bien noté ?
  bool get isWellRated => averageRating >= 4.0;

  /// Nombre de ventes formaté (ex: "1.2k")
  String get salesCountFormatted {
    if (salesCount >= 1000) {
      return '${(salesCount / 1000).toStringAsFixed(1)}k';
    }
    return salesCount.toString();
  }

  @override
  String toString() =>
      'DashboardTopProduct($name: $salesCountFormatted ventes, stock: $stock)';
}