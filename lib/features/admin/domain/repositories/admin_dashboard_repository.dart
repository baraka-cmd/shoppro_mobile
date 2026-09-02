// ============================================
// REPOSITORY INTERFACE : AdminDashboardRepository
// ============================================
// Interface définissant le contrat pour l'accès aux données
// du tableau de bord administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminDashboardRepositoryImpl.
//
// Avantages de cette approche :
// - Testabilité (mock facile)
// - Découplage (changement d'implémentation sans toucher au métier)
// - Clean Architecture respectée
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/dashboard_stats.dart';
import '../entities/sales_report.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository du tableau de bord administrateur.
///
/// Cette interface définit toutes les opérations nécessaires
/// pour alimenter le dashboard admin en données :
/// - Statistiques générales
/// - Données de graphiques
/// - Rapports de ventes
/// - Alertes et notifications
abstract class AdminDashboardRepository {
  // ============================================
  // STATISTIQUES GÉNÉRALES
  // ============================================

  /// Récupère les statistiques générales du dashboard.
  ///
  /// Retourne un [DashboardStats] contenant :
  /// - Revenus totaux, commandes, utilisateurs, produits
  /// - Données de graphiques (ventes par jour, commandes par statut)
  /// - Top produits et catégories
  /// - Données récentes (commandes, utilisateurs)
  /// - Alertes (stock faible, avis en attente)
  ///
  /// Lance une [Exception] en cas d'erreur réseau ou serveur.
  Future<DashboardStats> getDashboardStats();

  /// Récupère les statistiques pour une période donnée.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  ///
  /// Retourne les mêmes statistiques filtrées par période.
  Future<DashboardStats> getStatsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================

  /// Récupère les ventes par jour pour les 30 derniers jours.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'date': '2026-08-01', 'revenue': 150000, 'orders': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getSalesByDay();

  /// Récupère les ventes par mois pour les 12 derniers mois.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'month': 'Janvier', 'revenue': 5000000, 'orders': 150},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRevenueByMonth();

  /// Récupère les commandes par statut.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'pending': 5,
  ///   'confirmed': 10,
  ///   'delivered': 50,
  ///   ...
  /// }
  /// ```
  Future<Map<String, int>> getOrdersByStatus();

  /// Récupère les commandes par heure de la journée.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'hour': 8, 'orders': 25},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getOrdersByHour();

  /// Récupère les commandes par jour de la semaine.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'day': 'Lundi', 'orders': 50},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getOrdersByDayOfWeek();

  // ============================================
  // TOP ÉLÉMENTS
  // ============================================

  /// Récupère les 10 produits les plus vendus (par revenu).
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Produit', 'revenue': 500000, 'quantity': 50},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getTopProducts();

  /// Récupère les 10 catégories les plus vendues.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Catégorie', 'revenue': 2000000, 'orders': 100},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getTopCategories();

  /// Récupère les 10 marques les plus vendues.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Marque', 'revenue': 1500000, 'orders': 80},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getTopBrands();

  // ============================================
  // DONNÉES RÉCENTES
  // ============================================

  /// Récupère les 10 dernières commandes.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'order_number': 'CMD-20260801-0001', 'customer': 'Jean', 'total': 50000, 'status': 'pending'},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10});

  /// Récupère les 10 derniers utilisateurs inscrits.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Jean', 'email': 'jean@example.com', 'created_at': '2026-08-01'},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10});

  // ============================================
  // ALERTES
  // ============================================

  /// Récupère la liste des produits en stock faible.
  ///
  /// Retourne une liste de maps avec le format :
  /// ```dart
  /// [
  ///   {'id': 1, 'name': 'Produit', 'stock': 3, 'min_stock': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getLowStockProducts();

  /// Récupère le nombre d'avis en attente de modération.
  Future<int> getPendingReviewsCount();

  /// Récupère le nombre de commandes en attente de traitement.
  Future<int> getPendingOrdersCount();

  /// Récupère le nombre de paiements en attente.
  Future<int> getPendingPaymentsCount();

  /// Récupère le nombre de retours en attente.
  Future<int> getPendingReturnsCount();

  // ============================================
  // RAPPORTS DE VENTES
  // ============================================

  /// Génère un rapport de ventes pour une période donnée.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  ///
  /// Retourne un [SalesReport] complet avec :
  /// - Revenus détaillés
  /// - Commandes par statut
  /// - Analyse des clients
  /// - Top produits, catégories, marques
  /// - Comparaison avec la période précédente
  Future<SalesReport> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Récupère le rapport de ventes du jour.
  Future<SalesReport> getTodayReport();

  /// Récupère le rapport de ventes des 7 derniers jours.
  Future<SalesReport> getLast7DaysReport();

  /// Récupère le rapport de ventes des 30 derniers jours.
  Future<SalesReport> getLast30DaysReport();

  /// Récupère le rapport de ventes du mois en cours.
  Future<SalesReport> getThisMonthReport();

  // ============================================
  // PERFORMANCE
  // ============================================

  /// Récupère les statistiques de performance du site.
  ///
  /// Retourne une map avec le format :
  /// ```dart
  /// {
  ///   'total_visits': 15000,
  ///   'total_favorites': 500,
  ///   'total_reviews': 200,
  ///   'average_rating': 4.2,
  ///   'conversion_rate': 3.5,
  /// }
  /// ```
  Future<Map<String, dynamic>> getPerformanceStats();

  /// Récupère le taux de conversion actuel.
  Future<double> getConversionRate();

  /// Récupère la note moyenne des produits.
  Future<double> getAverageRating();

  // ============================================
  // ACTIONS ADMIN
  // ============================================

  /// Rafraîchit le cache des statistiques.
  ///
  /// Force la régénération des statistiques depuis l'API.
  Future<void> refreshStatsCache();

  /// Efface le cache des statistiques.
  Future<void> clearStatsCache();

  /// Vérifie si les statistiques sont en cache.
  Future<bool> hasCachedStats();

  /// Récupère les statistiques depuis le cache.
  Future<DashboardStats?> getCachedStats();
}