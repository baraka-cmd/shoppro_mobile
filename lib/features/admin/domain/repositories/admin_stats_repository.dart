// ============================================
// REPOSITORY INTERFACE : AdminStatsRepository
// ============================================
// Interface définissant le contrat pour l'accès aux statistiques
// et rapports détaillés de l'administration.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminStatsRepositoryImpl.
//
// Opérations couvertes :
// - Rapports de ventes détaillés
// - Analyse des revenus
// - Analyse des commandes
// - Analyse des clients
// - Analyse des produits
// - Export de rapports
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/sales_report.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository des statistiques et rapports.
///
/// Cette interface définit toutes les opérations nécessaires
/// pour générer et récupérer les rapports de ventes détaillés.
abstract class AdminStatsRepository {
  // ============================================
  // RAPPORTS DE VENTES
  // ============================================

  /// Génère un rapport de ventes pour une période personnalisée.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début de la période
  /// - [endDate] : Date de fin de la période
  ///
  /// Retourne un [SalesReport] complet avec :
  /// - Revenus détaillés (total, net, taxes, livraison)
  /// - Commandes par statut
  /// - Analyse des clients
  /// - Top produits et catégories
  /// - Comparaison avec période précédente
  Future<SalesReport> generateReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère le rapport du jour.
  Future<SalesReport> getTodayReport();

  /// Récupère le rapport d'hier.
  Future<SalesReport> getYesterdayReport();

  /// Récupère le rapport des 7 derniers jours.
  Future<SalesReport> getLast7DaysReport();

  /// Récupère le rapport des 30 derniers jours.
  Future<SalesReport> getLast30DaysReport();

  /// Récupère le rapport des 90 derniers jours.
  Future<SalesReport> getLast90DaysReport();

  /// Récupère le rapport du mois en cours.
  Future<SalesReport> getThisMonthReport();

  /// Récupère le rapport du mois dernier.
  Future<SalesReport> getLastMonthReport();

  /// Récupère le rapport de l'année en cours.
  Future<SalesReport> getThisYearReport();

  /// Récupère le rapport de l'année dernière.
  Future<SalesReport> getLastYearReport();

  // ============================================
  // ANALYSE DES REVENUS
  // ============================================

  /// Récupère les revenus par jour pour une période.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'date': '2026-08-01', 'revenue': 150000, 'orders': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRevenueByDay({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère les revenus par semaine.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'week': 'Semaine 31', 'revenue': 1000000, 'orders': 45},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRevenueByWeek({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère les revenus par mois.
  ///
  /// Paramètres :
  /// - [year] : Année (ex: 2026)
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'month': 'Janvier', 'revenue': 5000000, 'orders': 150},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRevenueByMonth({int? year});

  /// Récupère le revenu total pour une période.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  Future<double> getTotalRevenue({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère le revenu net pour une période.
  Future<double> getNetRevenue({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================
  // ANALYSE DES COMMANDES
  // ============================================

  /// Récupère les commandes par statut.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'pending': 5,
  ///   'confirmed': 10,
  ///   'processing': 8,
  ///   'shipped': 15,
  ///   'delivered': 50,
  ///   'cancelled': 3,
  ///   'refunded': 2,
  /// }
  /// ```
  Future<Map<String, int>> getOrdersCountByStatus();

  /// Récupère les commandes par heure de la journée.
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'hour': 8, 'orders': 25},
  ///   {'hour': 9, 'orders': 35},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getOrdersByHour();

  /// Récupère les commandes par jour de la semaine.
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'day': 'Lundi', 'orders': 50},
  ///   {'day': 'Mardi', 'orders': 45},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getOrdersByDayOfWeek();

  /// Récupère le nombre total de commandes pour une période.
  Future<int> getTotalOrders({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère la valeur moyenne d'une commande.
  Future<double> getAverageOrderValue({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================
  // ANALYSE DES CLIENTS
  // ============================================

  /// Récupère le nombre de nouveaux clients par jour.
  ///
  /// Paramètres :
  /// - [days] : Nombre de jours (défaut : 30)
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'date': '2026-08-01', 'count': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getNewCustomersByDay({int days = 30});

  /// Récupère le nombre total de clients.
  Future<int> getTotalCustomers();

  /// Récupère le nombre de clients actifs (ont commandé).
  Future<int> getActiveCustomers();

  /// Récupère le taux de rétention client.
  Future<double> getRetentionRate();

  /// Récupère les clients les plus fidèles.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Jean', 'orders': 25, 'spent': 500000},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getLoyalCustomers({int limit = 10});

  // ============================================
  // ANALYSE DES PRODUITS
  // ============================================

  /// Récupère les produits les plus vendus par revenu.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Produit', 'revenue': 500000, 'quantity': 50},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getTopProductsByRevenue({int limit = 10});

  /// Récupère les produits les plus vendus par quantité.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Map<String, dynamic>>> getTopProductsByQuantity({int limit = 10});

  /// Récupère les produits les moins vendus.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Map<String, dynamic>>> getWorstProducts({int limit = 10});

  /// Récupère les produits en rupture de stock.
  Future<List<Map<String, dynamic>>> getOutOfStockProducts();

  /// Récupère le nombre total d'articles vendus.
  Future<int> getTotalItemsSold();

  // ============================================
  // ANALYSE DES CATÉGORIES ET MARQUES
  // ============================================

  /// Récupère les catégories les plus vendues.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Map<String, dynamic>>> getTopCategories({int limit = 10});

  /// Récupère les marques les plus vendues.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Map<String, dynamic>>> getTopBrands({int limit = 10});

  // ============================================
  // ANALYSE DES PAIEMENTS
  // ============================================

  /// Récupère les paiements par méthode.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'card': 50,
  ///   'mobile_money': 30,
  ///   'cash_on_delivery': 20,
  ///   ...
  /// }
  /// ```
  Future<Map<String, int>> getPaymentsByMethod();

  /// Récupère les paiements par statut.
  Future<Map<String, int>> getPaymentsByStatus();

  /// Récupère le montant total des remboursements.
  Future<double> getTotalRefunds();

  // ============================================
  // COMPARAISON
  // ============================================

  /// Compare deux périodes.
  ///
  /// Paramètres :
  /// - [currentStart] : Début de la période actuelle
  /// - [currentEnd] : Fin de la période actuelle
  /// - [previousStart] : Début de la période précédente
  /// - [previousEnd] : Fin de la période précédente
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'revenue_change': 15.5,
  ///   'orders_change': 10.2,
  ///   'customers_change': 8.3,
  ///   'average_order_change': 5.1,
  /// }
  /// ```
  Future<Map<String, dynamic>> comparePeriods({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  });

  // ============================================
  // EXPORT
  // ============================================

  /// Exporte un rapport en format CSV.
  ///
  /// Paramètres :
  /// - [report] : Le rapport à exporter
  ///
  /// Retourne le contenu CSV en String.
  Future<String> exportReportToCsv(SalesReport report);

  /// Exporte un rapport en format JSON.
  ///
  /// Paramètres :
  /// - [report] : Le rapport à exporter
  ///
  /// Retourne le contenu JSON en String.
  Future<String> exportReportToJson(SalesReport report);

  // ============================================
  // CACHE
  // ============================================

  /// Rafraîchit le cache des statistiques.
  Future<void> refreshCache();

  /// Efface le cache des statistiques.
  Future<void> clearCache();

  /// Vérifie si des statistiques sont en cache.
  Future<bool> hasCachedStats();
}