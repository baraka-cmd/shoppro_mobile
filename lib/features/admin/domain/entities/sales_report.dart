// ============================================
// ENTITÉ : SalesReport
// ============================================
// Représente un rapport de ventes complet pour l'administration.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les données nécessaires pour les statistiques et rapports :
// - Revenus par période
// - Comparaison avec la période précédente
// - Données de graphiques
// - Top produits et catégories
// - Analyse des commandes
// ============================================

/// Période d'un rapport de ventes
enum SalesReportPeriod {
  today('today', "Aujourd'hui"),
  yesterday('yesterday', 'Hier'),
  last7Days('last_7_days', '7 derniers jours'),
  last30Days('last_30_days', '30 derniers jours'),
  thisMonth('this_month', 'Ce mois'),
  lastMonth('last_month', 'Mois dernier'),
  thisYear('this_year', 'Cette année'),
  lastYear('last_year', 'Année dernière'),
  custom('custom', 'Personnalisé');

  final String code;
  final String displayName;

  const SalesReportPeriod(this.code, this.displayName);

  static SalesReportPeriod fromCode(String? code) {
    return SalesReportPeriod.values.firstWhere(
      (period) => period.code == code,
      orElse: () => SalesReportPeriod.last30Days,
    );
  }
}

/// Type de comparaison pour les rapports
enum SalesComparisonType {
  previousPeriod('previous_period', 'Période précédente'),
  samePeriodLastYear('same_period_last_year', "Même période l'année dernière"),
  custom('custom', 'Personnalisé');

  final String code;
  final String displayName;

  const SalesComparisonType(this.code, this.displayName);

  static SalesComparisonType fromCode(String? code) {
    return SalesComparisonType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => SalesComparisonType.previousPeriod,
    );
  }
}

/// Entité représentant un rapport de ventes détaillé
class SalesReport {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Période du rapport
  final SalesReportPeriod period;

  /// Date de début de la période
  final DateTime startDate;

  /// Date de fin de la période
  final DateTime endDate;

  /// Date de génération du rapport
  final DateTime generatedAt;

  // ============================================
  // REVENUS
  // ============================================

  /// Revenu total de la période
  final double totalRevenue;

  /// Revenu net (après remboursements)
  final double netRevenue;

  /// Revenu des taxes
  final double taxRevenue;

  /// Revenu des frais de livraison
  final double shippingRevenue;

  /// Revenu des remises appliquées
  final double discountAmount;

  /// Revenu des remboursements
  final double refundAmount;

  // ============================================
  // COMMANDES
  // ============================================

  /// Nombre total de commandes
  final int totalOrders;

  /// Nombre de commandes payées
  final int paidOrders;

  /// Nombre de commandes en attente
  final int pendingOrders;

  /// Nombre de commandes annulées
  final int cancelledOrders;

  /// Nombre de commandes retournées
  final int returnedOrders;

  /// Nombre de commandes en cours de livraison
  final int shippedOrders;

  /// Nombre de commandes livrées
  final int deliveredOrders;

  /// Valeur moyenne d'une commande
  final double averageOrderValue;

  /// Valeur médiane d'une commande
  final double medianOrderValue;

  // ============================================
  // CLIENTS
  // ============================================

  /// Nombre total de clients
  final int totalCustomers;

  /// Nombre de nouveaux clients
  final int newCustomers;

  /// Nombre de clients actifs (ont commandé)
  final int activeCustomers;

  /// Nombre de clients fidèles (plus de 5 commandes)
  final int loyalCustomers;

  /// Taux de rétention client
  final double retentionRate;

  // ============================================
  // PRODUITS
  // ============================================

  /// Nombre total de produits vendus
  final int totalItemsSold;

  /// Nombre de produits actifs
  final int activeProducts;

  /// Nombre de produits en rupture de stock
  final int outOfStockProducts;

  /// Produit le plus vendu
  final String? topProduct;

  /// Quantité du produit le plus vendu
  final int topProductQuantity;

  // ============================================
  // COMPARAISON
  // ============================================

  /// Type de comparaison
  final SalesComparisonType comparisonType;

  /// Variation du revenu (en %)
  final double revenueChange;

  /// Variation des commandes (en %)
  final double ordersChange;

  /// Variation des clients (en %)
  final double customersChange;

  /// Variation du panier moyen (en %)
  final double averageOrderChange;

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================

  /// Revenus par jour
  /// Format : [{'date': '2026-08-01', 'revenue': 150000, 'orders': 5}, ...]
  final List<Map<String, dynamic>> revenueByDay;

  /// Revenus par semaine
  /// Format : [{'week': 'Semaine 31', 'revenue': 1000000}, ...]
  final List<Map<String, dynamic>> revenueByWeek;

  /// Revenus par mois
  /// Format : [{'month': 'Jan', 'revenue': 5000000}, ...]
  final List<Map<String, dynamic>> revenueByMonth;

  /// Commandes par heure de la journée
  /// Format : [{'hour': 8, 'orders': 25}, ...]
  final List<Map<String, dynamic>> ordersByHour;

  /// Commandes par jour de la semaine
  /// Format : [{'day': 'Lundi', 'orders': 50}, ...]
  final List<Map<String, dynamic>> ordersByDayOfWeek;

  // ============================================
  // TOP ÉLÉMENTS
  // ============================================

  /// Top 10 produits par revenu
  /// Format : [{'id': 1, 'name': 'Produit', 'revenue': 500000, 'quantity': 50}, ...]
  final List<Map<String, dynamic>> topProducts;

  /// Top 10 produits par quantité
  /// Format : [{'id': 1, 'name': 'Produit', 'quantity': 100, 'revenue': 800000}, ...]
  final List<Map<String, dynamic>> topProductsByQuantity;

  /// Top 10 catégories par revenu
  /// Format : [{'id': 1, 'name': 'Catégorie', 'revenue': 2000000, 'orders': 100}, ...]
  final List<Map<String, dynamic>> topCategories;

  /// Top 10 marques par revenu
  /// Format : [{'id': 1, 'name': 'Marque', 'revenue': 1500000, 'orders': 80}, ...]
  final List<Map<String, dynamic>> topBrands;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const SalesReport({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalRevenue,
    required this.netRevenue,
    required this.taxRevenue,
    required this.shippingRevenue,
    required this.discountAmount,
    required this.refundAmount,
    required this.totalOrders,
    required this.paidOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.returnedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.averageOrderValue,
    required this.medianOrderValue,
    required this.totalCustomers,
    required this.newCustomers,
    required this.activeCustomers,
    required this.loyalCustomers,
    required this.retentionRate,
    required this.totalItemsSold,
    required this.activeProducts,
    required this.outOfStockProducts,
    this.topProduct,
    required this.topProductQuantity,
    required this.comparisonType,
    required this.revenueChange,
    required this.ordersChange,
    required this.customersChange,
    required this.averageOrderChange,
    required this.revenueByDay,
    required this.revenueByWeek,
    required this.revenueByMonth,
    required this.ordersByHour,
    required this.ordersByDayOfWeek,
    required this.topProducts,
    required this.topProductsByQuantity,
    required this.topCategories,
    required this.topBrands,
  });

  // ============================================
  // VALEURS PAR DÉFAUT (VIDE)
  // ============================================

  /// Retourne une instance vide
  factory SalesReport.empty() {
    final now = DateTime.now();
    return SalesReport(
      period: SalesReportPeriod.last30Days,
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
      generatedAt: now,
      totalRevenue: 0,
      netRevenue: 0,
      taxRevenue: 0,
      shippingRevenue: 0,
      discountAmount: 0,
      refundAmount: 0,
      totalOrders: 0,
      paidOrders: 0,
      pendingOrders: 0,
      cancelledOrders: 0,
      returnedOrders: 0,
      shippedOrders: 0,
      deliveredOrders: 0,
      averageOrderValue: 0,
      medianOrderValue: 0,
      totalCustomers: 0,
      newCustomers: 0,
      activeCustomers: 0,
      loyalCustomers: 0,
      retentionRate: 0,
      totalItemsSold: 0,
      activeProducts: 0,
      outOfStockProducts: 0,
      topProduct: null,
      topProductQuantity: 0,
      comparisonType: SalesComparisonType.previousPeriod,
      revenueChange: 0,
      ordersChange: 0,
      customersChange: 0,
      averageOrderChange: 0,
      revenueByDay: [],
      revenueByWeek: [],
      revenueByMonth: [],
      ordersByHour: [],
      ordersByDayOfWeek: [],
      topProducts: [],
      topProductsByQuantity: [],
      topCategories: [],
      topBrands: [],
    );
  }

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Vrai si le revenu a augmenté
  bool get isRevenueUp => revenueChange > 0;

  /// Vrai si le revenu a diminué
  bool get isRevenueDown => revenueChange < 0;

  /// Vrai si les commandes ont augmenté
  bool get isOrdersUp => ordersChange > 0;

  /// Vrai si les clients ont augmenté
  bool get isCustomersUp => customersChange > 0;

  /// Taux de commandes payées
  double get paidOrdersRate {
    if (totalOrders == 0) return 0;
    return (paidOrders / totalOrders) * 100;
  }

  /// Taux de commandes annulées
  double get cancelledOrdersRate {
    if (totalOrders == 0) return 0;
    return (cancelledOrders / totalOrders) * 100;
  }

  /// Taux de commandes retournées
  double get returnedOrdersRate {
    if (totalOrders == 0) return 0;
    return (returnedOrders / totalOrders) * 100;
  }

  /// Taux de commandes livrées
  double get deliveredOrdersRate {
    if (totalOrders == 0) return 0;
    return (deliveredOrders / totalOrders) * 100;
  }

  /// Taux de conversion (commandes / clients actifs)
  double get conversionRate {
    if (activeCustomers == 0) return 0;
    return (totalOrders / activeCustomers) * 100;
  }

  /// Nombre moyen d'articles par commande
  double get averageItemsPerOrder {
    if (totalOrders == 0) return 0;
    return totalItemsSold / totalOrders;
  }

  /// Marge brute estimée (30% du revenu net)
  double get estimatedGrossMargin {
    return netRevenue * 0.30;
  }

  /// Vrai si le rapport est vide
  bool get isEmpty =>
      totalRevenue == 0 &&
      totalOrders == 0 &&
      totalCustomers == 0;

  /// Vrai si le rapport a des données
  bool get hasData => !isEmpty;

  /// Formatage du revenu total
  String get totalRevenueFormatted => _formatCurrency(totalRevenue);

  /// Formatage du revenu net
  String get netRevenueFormatted => _formatCurrency(netRevenue);

  /// Formatage des taxes
  String get taxRevenueFormatted => _formatCurrency(taxRevenue);

  /// Formatage des frais de livraison
  String get shippingRevenueFormatted => _formatCurrency(shippingRevenue);

  /// Formatage des remises
  String get discountAmountFormatted => _formatCurrency(discountAmount);

  /// Formatage des remboursements
  String get refundAmountFormatted => _formatCurrency(refundAmount);

  /// Formatage du panier moyen
  String get averageOrderValueFormatted => _formatCurrency(averageOrderValue);

  /// Formatage du panier médian
  String get medianOrderValueFormatted => _formatCurrency(medianOrderValue);

  /// Formatage de la marge brute
  String get estimatedGrossMarginFormatted => _formatCurrency(estimatedGrossMargin);

  /// Formatage de la variation du revenu
  String get revenueChangeFormatted {
    final sign = revenueChange > 0 ? '+' : '';
    return '$sign${revenueChange.toStringAsFixed(2)}%';
  }

  /// Formatage de la variation des commandes
  String get ordersChangeFormatted {
    final sign = ordersChange > 0 ? '+' : '';
    return '$sign${ordersChange.toStringAsFixed(2)}%';
  }

  /// Formatage de la variation des clients
  String get customersChangeFormatted {
    final sign = customersChange > 0 ? '+' : '';
    return '$sign${customersChange.toStringAsFixed(2)}%';
  }

  /// Formatage du taux de rétention
  String get retentionRateFormatted => '${retentionRate.toStringAsFixed(2)}%';

  /// Formatage du taux de conversion
  String get conversionRateFormatted => '${conversionRate.toStringAsFixed(2)}%';

  /// Formatage du taux de commandes payées
  String get paidOrdersRateFormatted => '${paidOrdersRate.toStringAsFixed(1)}%';

  /// Formatage du taux d'annulation
  String get cancelledOrdersRateFormatted => '${cancelledOrdersRate.toStringAsFixed(1)}%';

  /// Formatage du taux de retour
  String get returnedOrdersRateFormatted => '${returnedOrdersRate.toStringAsFixed(1)}%';

  /// Formatage de la période
  String get periodFormatted {
    return '${_formatDate(startDate)} → ${_formatDate(endDate)}';
  }

  /// Formatage du nom de la période
  String get periodName => period.displayName;

  /// Formatage de la date de génération
  String get generatedAtFormatted {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${generatedAt.day} ${months[generatedAt.month - 1]} ${generatedAt.year} '
        'à ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Formatage du produit le plus vendu
  String get topProductFormatted {
    if (topProduct == null || topProduct!.isEmpty) return 'Aucun';
    return '$topProduct (x$topProductQuantity)';
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Formate un montant en FCFA avec séparateurs de milliers
  String _formatCurrency(double amount) {
    final buffer = StringBuffer();
    final amountStr = amount.round().toString();

    for (int i = 0; i < amountStr.length; i++) {
      buffer.write(amountStr[i]);
      final remaining = amountStr.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }

    return '$buffer FCFA';
  }

  /// Formate une date en format lisible
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================
  // SERIALIZATION
  // ============================================

  /// Convertit l'entité en Map pour la sérialisation
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

  /// Crée une entité à partir d'une Map
  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      period: SalesReportPeriod.fromCode(json['period'] as String?),
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ?? DateTime.now(),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0,
      taxRevenue: (json['tax_revenue'] as num?)?.toDouble() ?? 0,
      shippingRevenue: (json['shipping_revenue'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      paidOrders: (json['paid_orders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pending_orders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelled_orders'] as num?)?.toInt() ?? 0,
      returnedOrders: (json['returned_orders'] as num?)?.toInt() ?? 0,
      shippedOrders: (json['shipped_orders'] as num?)?.toInt() ?? 0,
      deliveredOrders: (json['delivered_orders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0,
      medianOrderValue: (json['median_order_value'] as num?)?.toDouble() ?? 0,
      totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
      newCustomers: (json['new_customers'] as num?)?.toInt() ?? 0,
      activeCustomers: (json['active_customers'] as num?)?.toInt() ?? 0,
      loyalCustomers: (json['loyal_customers'] as num?)?.toInt() ?? 0,
      retentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0,
      totalItemsSold: (json['total_items_sold'] as num?)?.toInt() ?? 0,
      activeProducts: (json['active_products'] as num?)?.toInt() ?? 0,
      outOfStockProducts: (json['out_of_stock_products'] as num?)?.toInt() ?? 0,
      topProduct: json['top_product'] as String?,
      topProductQuantity: (json['top_product_quantity'] as num?)?.toInt() ?? 0,
      comparisonType: SalesComparisonType.fromCode(json['comparison_type'] as String?),
      revenueChange: (json['revenue_change'] as num?)?.toDouble() ?? 0,
      ordersChange: (json['orders_change'] as num?)?.toDouble() ?? 0,
      customersChange: (json['customers_change'] as num?)?.toDouble() ?? 0,
      averageOrderChange: (json['average_order_change'] as num?)?.toDouble() ?? 0,
      revenueByDay: List<Map<String, dynamic>>.from(
        (json['revenue_by_day'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      revenueByWeek: List<Map<String, dynamic>>.from(
        (json['revenue_by_week'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      revenueByMonth: List<Map<String, dynamic>>.from(
        (json['revenue_by_month'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      ordersByHour: List<Map<String, dynamic>>.from(
        (json['orders_by_hour'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      ordersByDayOfWeek: List<Map<String, dynamic>>.from(
        (json['orders_by_day_of_week'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topProducts: List<Map<String, dynamic>>.from(
        (json['top_products'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topProductsByQuantity: List<Map<String, dynamic>>.from(
        (json['top_products_by_quantity'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topCategories: List<Map<String, dynamic>>.from(
        (json['top_categories'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topBrands: List<Map<String, dynamic>>.from(
        (json['top_brands'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  SalesReport copyWith({
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
    return SalesReport(
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
    return other is SalesReport &&
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
    return 'SalesReport(period: ${period.displayName}, '
        'revenue: $totalRevenueFormatted, '
        'orders: $totalOrders, '
        'customers: $totalCustomers, '
        'change: $revenueChangeFormatted)';
  }
}