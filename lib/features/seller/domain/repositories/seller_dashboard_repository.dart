// ============================================
// REPOSITORY (INTERFACE) : SellerDashboardRepository
// ============================================
// Contrat que doit respecter toute implémentation du
// repository du dashboard vendeur.
//
// Principe Clean Architecture :
//   - Le domaine définit CE QU'ON VEUT faire
//   - L'implémentation (data) définit COMMENT on le fait
//   - Le provider (presentation) utilise l'interface,
//     jamais l'implémentation directement
//
// Avantages :
//   - Testable (on peut mocker le repository)
//   - Découplé (on peut changer l'impl sans toucher au reste)
//   - Documenté (le contrat est explicite)
// ============================================

// Entity
import '../entities/seller_dashboard.dart';

abstract class SellerDashboardRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupère toutes les données du dashboard vendeur.
  ///
  /// Retourne :
  ///   - SellerDashboard contenant :
  ///     - seller (infos boutique)
  ///     - kpis (revenus, commandes, produits, avis, balance)
  ///     - alerts (alertes actionnables)
  ///     - recentOrders (5 dernières commandes)
  ///     - topProducts (5 top produits)
  ///
  /// Peut lever :
  ///   - SellerDashboardForbiddenException (KYC pending/rejected)
  ///   - SellerDashboardUnauthorizedException (token expiré)
  ///   - SellerDashboardNetworkException (offline)
  ///   - SellerDashboardServerException (500)
  Future<SellerDashboard> getDashboard();

  /// Récupère le graphique de ventes sur une période donnée.
  ///
  /// [period] : nombre de jours (7, 30 ou 90). Défaut : 30.
  ///
  /// Retourne :
  ///   - Map contenant :
  ///     - period (int)
  ///     - period_label (String)
  ///     - total_revenue (double)
  ///     - total_revenue_formatted (String)
  ///     - total_items (int)
  ///     - average_daily_revenue (double)
  ///     - data (List<Map> avec date, revenue, items, ...)
  Future<Map<String, dynamic>> getSalesChart({int period = 30});

  /// Récupère les dernières commandes du vendeur.
  ///
  /// [limit] : nombre de commandes à retourner (défaut : 10, max : 50).
  Future<List<DashboardOrderSummary>> getRecentOrders({int limit = 10});

  /// Récupère les produits les plus vendus.
  ///
  /// [limit] : nombre de produits à retourner (défaut : 5, max : 20).
  Future<List<DashboardTopProduct>> getTopProducts({int limit = 5});

  /// Récupère les alertes actionnables.
  Future<List<DashboardAlert>> getAlerts();

  // ============================================
  // CACHE
  // ============================================

  /// Force le rafraîchissement des données (ignore le cache).
  ///
  /// Utile pour un pull-to-refresh ou un bouton "Actualiser".
  Future<SellerDashboard> refreshDashboard();

  /// Efface le cache local (logout, changement de compte).
  Future<void> clearCache();
}