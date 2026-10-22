// ============================================
// ENTITÉ : SellerStats
// ============================================
// Représente les statistiques vendeur.
//
// Contient 3 groupes de stats :
//   1. Sales : CA, commandes, panier moyen + timeline
//   2. Products : Top produits + catégories
//   3. Customers : Top clients + segmentation
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

// ============================================
// ENTITÉ : SellerSalesStats
// ============================================
// Statistiques de ventes (CA, commandes, tendance).
// ============================================

class SellerSalesStats {
  final double totalRevenue;
  final double previousRevenue;
  final int totalOrders;
  final int previousOrders;
  final int totalItems;
  final int previousItems;
  final double averageOrderValue;
  final double previousAverageOrderValue;
  final List<SellerSalesTimelinePoint> timeline;
  final int periodDays;
  final String periodLabel;
  final DateTime? startDate;
  final DateTime? endDate;

  const SellerSalesStats({
    required this.totalRevenue,
    required this.previousRevenue,
    required this.totalOrders,
    required this.previousOrders,
    required this.totalItems,
    required this.previousItems,
    required this.averageOrderValue,
    required this.previousAverageOrderValue,
    this.timeline = const [],
    required this.periodDays,
    required this.periodLabel,
    this.startDate,
    this.endDate,
  });

  const SellerSalesStats.empty()
      : totalRevenue = 0,
        previousRevenue = 0,
        totalOrders = 0,
        previousOrders = 0,
        totalItems = 0,
        previousItems = 0,
        averageOrderValue = 0,
        previousAverageOrderValue = 0,
        timeline = const [],
        periodDays = 30,
        periodLabel = '30 derniers jours',
        startDate = null,
        endDate = null;

  // ============================================
  // GETTERS CROISSANCE
  // ============================================

  /// Croissance du CA (en %).
  double get revenueGrowth => _computeGrowth(totalRevenue, previousRevenue);

  /// Croissance du nombre de commandes.
  double get ordersGrowth => _computeGrowth(totalOrders, previousOrders);

  /// Croissance des items vendus.
  double get itemsGrowth => _computeGrowth(totalItems, previousItems);

  /// Croissance du panier moyen.
  double get avgOrderGrowth =>
      _computeGrowth(averageOrderValue, previousAverageOrderValue);

  bool get isRevenuePositive => revenueGrowth >= 0;
  bool get isOrdersPositive => ordersGrowth >= 0;
  bool get isItemsPositive => itemsGrowth >= 0;
  bool get isAvgOrderPositive => avgOrderGrowth >= 0;

  // ============================================
  // GETTERS FORMULES
  // ============================================

  /// CA formaté.
  String get formattedRevenue => _formatPrice(totalRevenue);

  /// CA période précédente formaté.
  String get formattedPreviousRevenue => _formatPrice(previousRevenue);

  /// Panier moyen formaté.
  String get formattedAverageOrderValue => _formatPrice(averageOrderValue);

  /// Label de croissance du CA (ex: "+12,5%").
  String get revenueGrowthLabel => _formatGrowthLabel(revenueGrowth);

  /// Label de croissance des commandes.
  String get ordersGrowthLabel => _formatGrowthLabel(ordersGrowth);

  /// Label de croissance des items.
  String get itemsGrowthLabel => _formatGrowthLabel(itemsGrowth);

  /// Label de croissance du panier moyen.
  String get avgOrderGrowthLabel => _formatGrowthLabel(avgOrderGrowth);

  /// Différence absolue de CA.
  double get revenueChange => totalRevenue - previousRevenue;

  /// Différence de CA formatée.
  String get formattedRevenueChange => _formatPrice(revenueChange);

  /// Le vendeur a-t-il des ventes ?
  bool get hasSales => totalRevenue > 0;

  // ============================================
  // HELPERS
  // ============================================

  double _computeGrowth(num current, num previous) {
    if (previous == 0) {
      return current > 0 ? 100 : 0;
    }
    return ((current - previous) / previous) * 100;
  }

  String _formatPrice(num amount) {
    final str = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  String _formatGrowthLabel(double percent) {
    if (percent > 0) return '+${percent.toStringAsFixed(1)}%';
    if (percent < 0) return '${percent.toStringAsFixed(1)}%';
    return '0%';
  }

  @override
  String toString() {
    return 'SellerSalesStats(revenue: $formattedRevenue, '
        'orders: $totalOrders, growth: $revenueGrowthLabel)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerSalesTimelinePoint
// ============================================
// Un point de la timeline pour le graphique.
// ============================================

class SellerSalesTimelinePoint {
  final String date;
  final String dateFormatted;
  final String dayName;
  final double revenue;
  final int orders;
  final int items;

  const SellerSalesTimelinePoint({
    required this.date,
    required this.dateFormatted,
    required this.dayName,
    required this.revenue,
    required this.orders,
    required this.items,
  });

  @override
  String toString() =>
      'SellerSalesTimelinePoint($dateFormatted: ${revenue.toStringAsFixed(0)} FCFA)';
}

// ============================================
// ENTITÉ : SellerProductStats
// ============================================
// Statistiques produits (top produits + catégories).
// ============================================

class SellerProductStats {
  final List<SellerProductStat> topProducts;
  final List<SellerCategoryStat> topCategories;
  final int totalProductsSold;
  final int uniqueProducts;
  final double totalRevenue;
  final int periodDays;
  final String periodLabel;

  const SellerProductStats({
    this.topProducts = const [],
    this.topCategories = const [],
    this.totalProductsSold = 0,
    this.uniqueProducts = 0,
    this.totalRevenue = 0,
    this.periodDays = 30,
    this.periodLabel = '30 derniers jours',
  });

  const SellerProductStats.empty()
      : topProducts = const [],
        topCategories = const [],
        totalProductsSold = 0,
        uniqueProducts = 0,
        totalRevenue = 0,
        periodDays = 30,
        periodLabel = '30 derniers jours';

  bool get hasProducts => topProducts.isNotEmpty;
  bool get hasCategories => topCategories.isNotEmpty;

  String get formattedTotalRevenue {
    final str = totalRevenue.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  @override
  String toString() =>
      'SellerProductStats(products: ${topProducts.length}, '
      'sold: $totalProductsSold, revenue: $formattedTotalRevenue)';
}

// ============================================
// SOUS-ENTITÉ : SellerProductStat
// ============================================

class SellerProductStat {
  final int rank;
  final int id;
  final String name;
  final String sku;
  final String? imageUrl;
  final int quantitySold;
  final double revenue;
  final String revenueFormatted;
  final int ordersCount;
  final double averageRating;
  final int viewsCount;
  final String? rankMedal;

  const SellerProductStat({
    required this.rank,
    required this.id,
    required this.name,
    required this.sku,
    this.imageUrl,
    required this.quantitySold,
    required this.revenue,
    required this.revenueFormatted,
    required this.ordersCount,
    this.averageRating = 0,
    this.viewsCount = 0,
    this.rankMedal,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isTopThree => rank <= 3;

  @override
  String toString() => 'SellerProductStat(rank: $rank, name: $name)';
}

// ============================================
// SOUS-ENTITÉ : SellerCategoryStat
// ============================================

class SellerCategoryStat {
  final int rank;
  final int id;
  final String name;
  final int productsSold;
  final double revenue;
  final String revenueFormatted;
  final double percentage;

  const SellerCategoryStat({
    required this.rank,
    required this.id,
    required this.name,
    required this.productsSold,
    required this.revenue,
    required this.revenueFormatted,
    this.percentage = 0,
  });

  @override
  String toString() =>
      'SellerCategoryStat(rank: $rank, name: $name, pct: $percentage%)';
}

// ============================================
// ENTITÉ : SellerCustomerStats
// ============================================
// Statistiques clients (top clients + segmentation).
// ============================================

class SellerCustomerStats {
  final List<SellerCustomerStat> topCustomers;
  final int newCustomers;
  final int returningCustomers;
  final int loyalCustomers;
  final int totalCustomers;
  final double newPercentage;
  final double returningPercentage;
  final double loyalPercentage;
  final double totalRevenue;
  final double averageCustomerValue;
  final int periodDays;
  final String periodLabel;

  const SellerCustomerStats({
    this.topCustomers = const [],
    this.newCustomers = 0,
    this.returningCustomers = 0,
    this.loyalCustomers = 0,
    this.totalCustomers = 0,
    this.newPercentage = 0,
    this.returningPercentage = 0,
    this.loyalPercentage = 0,
    this.totalRevenue = 0,
    this.averageCustomerValue = 0,
    this.periodDays = 30,
    this.periodLabel = '30 derniers jours',
  });

  const SellerCustomerStats.empty()
      : topCustomers = const [],
        newCustomers = 0,
        returningCustomers = 0,
        loyalCustomers = 0,
        totalCustomers = 0,
        newPercentage = 0,
        returningPercentage = 0,
        loyalPercentage = 0,
        totalRevenue = 0,
        averageCustomerValue = 0,
        periodDays = 30,
        periodLabel = '30 derniers jours';

  bool get hasCustomers => topCustomers.isNotEmpty;

  String get formattedTotalRevenue {
    final str = totalRevenue.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  String get formattedAverageCustomerValue {
    final str = averageCustomerValue.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} FCFA';
  }

  @override
  String toString() =>
      'SellerCustomerStats(customers: $totalCustomers, '
      'loyal: $loyalCustomers)';
}

// ============================================
// SOUS-ENTITÉ : SellerCustomerStat
// ============================================

class SellerCustomerStat {
  final int rank;
  final int id;
  final String name;
  final String initials;
  final int ordersCount;
  final double totalSpent;
  final String totalSpentFormatted;
  final double averageOrder;
  final String averageOrderFormatted;
  final DateTime? lastOrderAt;
  final String? lastOrderHuman;
  final bool isLoyal;
  final bool isNew;

  const SellerCustomerStat({
    required this.rank,
    required this.id,
    required this.name,
    required this.initials,
    required this.ordersCount,
    required this.totalSpent,
    required this.totalSpentFormatted,
    required this.averageOrder,
    required this.averageOrderFormatted,
    this.lastOrderAt,
    this.lastOrderHuman,
    this.isLoyal = false,
    this.isNew = false,
  });

  @override
  String toString() =>
      'SellerCustomerStat(rank: $rank, name: $name, orders: $ordersCount)';
}

// ============================================
// ENUM : SellerStatsPeriod
// ============================================
// Périodes disponibles pour les statistiques.
// ============================================

enum SellerStatsPeriod {
  week(7, '7 jours', '7j'),
  month(30, '30 jours', '30j'),
  quarter(90, '90 jours', '90j'),
  all(0, 'Tout', 'Tout');

  final int days;
  final String label;
  final String shortLabel;

  const SellerStatsPeriod(this.days, this.label, this.shortLabel);
}