import 'package:flutter/material.dart';

/// 📊 Entité représentant les statistiques du tableau de bord administrateur.
///
/// Cette entité est pure (pas de dépendances Flutter) et contient
/// toutes les données nécessaires pour afficher le dashboard admin :
/// - Statistiques générales (revenus, commandes, utilisateurs, produits)
/// - Données de graphiques (ventes par jour, commandes par statut)
/// - Top produits et catégories
/// - Données récentes (commandes, utilisateurs)
/// - Alertes (stock faible, avis en attente, commandes en attente)
class DashboardStats {
  // ============================================
  // STATISTIQUES GÉNÉRALES
  // ============================================
  
  /// Revenu total généré (toutes commandes payées)
  final double totalRevenue;
  
  /// Nombre total de commandes
  final int totalOrders;
  
  /// Nombre total d'utilisateurs inscrits
  final int totalUsers;
  
  /// Nombre total de produits actifs
  final int totalProducts;
  
  /// Nombre total de catégories
  final int totalCategories;
  
  /// Nombre total de marques
  final int totalBrands;
  
  /// Valeur moyenne d'une commande (panier moyen)
  final double averageOrderValue;
  
  /// Taux de conversion (commandes / visites)
  final double conversionRate;

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================
  
  /// Ventes par jour (pour le graphique des 30 derniers jours)
  /// Format : [{'date': '2026-08-01', 'amount': 150000}, ...]
  final List<Map<String, dynamic>> salesByDay;
  
  /// Commandes par statut (pour le graphique circulaire)
  /// Format : {'pending': 5, 'confirmed': 10, 'delivered': 50, ...}
  final Map<String, int> ordersByStatus;
  
  /// Revenus par mois (pour le graphique des 12 derniers mois)
  /// Format : [{'month': 'Jan', 'amount': 1500000}, ...]
  final List<Map<String, dynamic>> revenueByMonth;

  // ============================================
  // TOP ÉLÉMENTS
  // ============================================
  
  /// Top 5 produits les plus vendus
  /// Format : [{'name': 'Produit', 'quantity': 50, 'revenue': 500000}, ...]
  final List<Map<String, dynamic>> topProducts;
  
  /// Top 5 catégories les plus vendues
  /// Format : [{'name': 'Catégorie', 'quantity': 100, 'revenue': 1000000}, ...]
  final List<Map<String, dynamic>> topCategories;

  // ============================================
  // DONNÉES RÉCENTES
  // ============================================
  
  /// 10 dernières commandes
  /// Format : [{'id': 1, 'order_number': 'CMD-...', 'customer': 'Jean', 'total': 50000, 'status': 'pending'}, ...]
  final List<Map<String, dynamic>> recentOrders;
  
  /// 10 derniers utilisateurs inscrits
  /// Format : [{'id': 1, 'name': 'Jean', 'email': 'jean@...', 'created_at': '2026-08-01'}, ...]
  final List<Map<String, dynamic>> recentUsers;

  // ============================================
  // ALERTES
  // ============================================
  
  /// Produits avec stock faible (quantité <= min_stock)
  final int lowStockCount;
  
  /// Liste des produits en stock faible
  /// Format : [{'id': 1, 'name': 'Produit', 'stock': 3, 'min_stock': 5}, ...]
  final List<Map<String, dynamic>> lowStockProducts;
  
  /// Avis en attente de modération
  final int pendingReviewsCount;
  
  /// Commandes en attente de traitement
  final int pendingOrdersCount;
  
  /// Paiements en attente
  final int pendingPaymentsCount;
  
  /// Retours en attente
  final int pendingReturnsCount;

  // ============================================
  // PERFORMANCE
  // ============================================
  
  /// Nombre total de visites
  final int totalVisits;
  
  /// Nombre total de favoris
  final int totalFavorites;
  
  /// Nombre total d'avis
  final int totalReviews;
  
  /// Note moyenne des produits
  final double averageRating;

  // ============================================
  // CONSTRUCTEUR
  // ============================================
  
  const DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalProducts,
    required this.totalCategories,
    required this.totalBrands,
    required this.averageOrderValue,
    required this.conversionRate,
    required this.salesByDay,
    required this.ordersByStatus,
    required this.revenueByMonth,
    required this.topProducts,
    required this.topCategories,
    required this.recentOrders,
    required this.recentUsers,
    required this.lowStockCount,
    required this.lowStockProducts,
    required this.pendingReviewsCount,
    required this.pendingOrdersCount,
    required this.pendingPaymentsCount,
    required this.pendingReturnsCount,
    required this.totalVisits,
    required this.totalFavorites,
    required this.totalReviews,
    required this.averageRating,
  });

  // ============================================
  // VALEURS PAR DÉFAUT (VIDE)
  // ============================================
  
  /// Retourne une instance vide (utile pour l'état initial)
  factory DashboardStats.empty() {
    return const DashboardStats(
      totalRevenue: 0,
      totalOrders: 0,
      totalUsers: 0,
      totalProducts: 0,
      totalCategories: 0,
      totalBrands: 0,
      averageOrderValue: 0,
      conversionRate: 0,
      salesByDay: [],
      ordersByStatus: {},
      revenueByMonth: [],
      topProducts: [],
      topCategories: [],
      recentOrders: [],
      recentUsers: [],
      lowStockCount: 0,
      lowStockProducts: [],
      pendingReviewsCount: 0,
      pendingOrdersCount: 0,
      pendingPaymentsCount: 0,
      pendingReturnsCount: 0,
      totalVisits: 0,
      totalFavorites: 0,
      totalReviews: 0,
      averageRating: 0,
    );
  }

  // ============================================
  // GETTERS CALCULÉS
  // ============================================
  
  /// Vrai s'il y a des alertes à afficher
  bool get hasAlerts =>
      lowStockCount > 0 ||
      pendingReviewsCount > 0 ||
      pendingOrdersCount > 0 ||
      pendingPaymentsCount > 0 ||
      pendingReturnsCount > 0;

  /// Nombre total d'alertes
  int get totalAlerts =>
      lowStockCount +
      pendingReviewsCount +
      pendingOrdersCount +
      pendingPaymentsCount +
      pendingReturnsCount;

  /// Vrai si les statistiques sont vides
  bool get isEmpty =>
      totalRevenue == 0 &&
      totalOrders == 0 &&
      totalUsers == 0 &&
      totalProducts == 0;

  /// Formatage du revenu total en FCFA
  String get totalRevenueFormatted {
    return _formatCurrency(totalRevenue);
  }

  /// Formatage du panier moyen en FCFA
  String get averageOrderValueFormatted {
    return _formatCurrency(averageOrderValue);
  }

  /// Formatage du taux de conversion en pourcentage
  String get conversionRateFormatted {
    return '${conversionRate.toStringAsFixed(2)}%';
  }

  /// Formatage de la note moyenne
  String get averageRatingFormatted {
    return averageRating.toStringAsFixed(1);
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

  // ============================================
  // SERIALIZATION
  // ============================================
  
  /// Convertit l'entité en Map pour la sérialisation
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

  /// Crée une entité à partir d'une Map
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalCategories: (json['total_categories'] as num?)?.toInt() ?? 0,
      totalBrands: (json['total_brands'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,
      salesByDay: List<Map<String, dynamic>>.from(
        (json['sales_by_day'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      ordersByStatus: Map<String, int>.from(
        json['orders_by_status'] ?? {},
      ),
      revenueByMonth: List<Map<String, dynamic>>.from(
        (json['revenue_by_month'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topProducts: List<Map<String, dynamic>>.from(
        (json['top_products'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      topCategories: List<Map<String, dynamic>>.from(
        (json['top_categories'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      recentOrders: List<Map<String, dynamic>>.from(
        (json['recent_orders'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      recentUsers: List<Map<String, dynamic>>.from(
        (json['recent_users'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      lowStockProducts: List<Map<String, dynamic>>.from(
        (json['low_stock_products'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      pendingReviewsCount: (json['pending_reviews_count'] as num?)?.toInt() ?? 0,
      pendingOrdersCount: (json['pending_orders_count'] as num?)?.toInt() ?? 0,
      pendingPaymentsCount: (json['pending_payments_count'] as num?)?.toInt() ?? 0,
      pendingReturnsCount: (json['pending_returns_count'] as num?)?.toInt() ?? 0,
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 0,
      totalFavorites: (json['total_favorites'] as num?)?.toInt() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================
  
  /// Crée une copie avec des champs modifiés
  DashboardStats copyWith({
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
    return DashboardStats(
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
    return other is DashboardStats &&
        other.totalRevenue == totalRevenue &&
        other.totalOrders == totalOrders &&
        other.totalUsers == totalUsers &&
        other.totalProducts == totalProducts &&
        other.averageRating == averageRating;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalRevenue,
      totalOrders,
      totalUsers,
      totalProducts,
      averageRating,
    );
  }

  // ============================================
  // TOSTRING
  // ============================================
  
  @override
  String toString() {
    return 'DashboardStats('
        'revenue: $totalRevenueFormatted, '
        'orders: $totalOrders, '
        'users: $totalUsers, '
        'products: $totalProducts, '
        'alerts: $totalAlerts'
        ')';
  }
}