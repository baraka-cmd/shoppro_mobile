// ============================================
// PROVIDER : AdminDashboardProvider
// ============================================
// Provider de gestion d'état pour le tableau de bord admin.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des statistiques
// - Gestion des états (loading, loaded, error)
// - Rafraîchissement des données
// - Gestion du cache
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/dashboard_stats.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_dashboard_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_dashboard_repository_impl.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider dashboard
enum DashboardStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider du tableau de bord administrateur.
///
/// Gère :
/// - Le chargement des statistiques générales
/// - Les données de graphiques
/// - Les alertes
/// - Le rafraîchissement
class AdminDashboardProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminDashboardRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  DashboardStatus _status = DashboardStatus.initial;
  DashboardStats? _stats;
  String? _errorMessage;
  bool _isLoadingMore = false;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminDashboardProvider({AdminDashboardRepository? repository})
      : _repository = repository ?? AdminDashboardRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  DashboardStatus get status => _status;
  DashboardStats? get stats => _stats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get isLoaded => _status == DashboardStatus.loaded;
  bool get isRefreshing => _status == DashboardStatus.refreshing;
  bool get hasError => _status == DashboardStatus.error;
  bool get isLoadingMore => _isLoadingMore;

  /// Vrai si les statistiques sont disponibles
  bool get hasStats => _stats != null;

  /// Vrai s'il y a des alertes
  bool get hasAlerts => _stats?.hasAlerts ?? false;

  /// Nombre total d'alertes
  int get totalAlerts => _stats?.totalAlerts ?? 0;

  /// Revenu total formaté
  String get totalRevenueFormatted => _stats?.totalRevenueFormatted ?? '0 FCFA';

  /// Nombre total de commandes
  int get totalOrders => _stats?.totalOrders ?? 0;

  /// Nombre total d'utilisateurs
  int get totalUsers => _stats?.totalUsers ?? 0;

  /// Nombre total de produits
  int get totalProducts => _stats?.totalProducts ?? 0;

  /// Panier moyen formaté
  String get averageOrderValueFormatted => _stats?.averageOrderValueFormatted ?? '0 FCFA';

  /// Taux de conversion formaté
  String get conversionRateFormatted => _stats?.conversionRateFormatted ?? '0%';

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge les statistiques du dashboard.
  ///
  /// Si des statistiques sont déjà chargées, effectue un rafraîchissement.
  Future<void> loadDashboard() async {
    if (_stats != null) {
      await refreshDashboard();
      return;
    }

    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _repository.getDashboardStats();
      _stats = stats;
      _status = DashboardStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = DashboardStatus.error;
      debugPrint('Erreur loadDashboard: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit les statistiques sans afficher le loader.
  Future<void> refreshDashboard() async {
    if (_status == DashboardStatus.refreshing) return;

    _status = DashboardStatus.refreshing;
    notifyListeners();

    try {
      final stats = await _repository.getDashboardStats();
      _stats = stats;
      _status = DashboardStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = DashboardStatus.error;
      debugPrint('Erreur refreshDashboard: $e');
    }

    notifyListeners();
  }

  /// Recharge depuis le cache si disponible.
  Future<void> loadFromCache() async {
    try {
      final cached = await _repository.getCachedStats();
      if (cached != null) {
        _stats = cached;
        _status = DashboardStatus.loaded;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur loadFromCache: $e');
    }
  }

  /// Efface le cache des statistiques.
  Future<void> clearCache() async {
    await _repository.clearStatsCache();
  }

  /// Vérifie si le cache est disponible.
  Future<bool> hasCachedData() async {
    return _repository.hasCachedStats();
  }

  // ============================================
  // DONNÉES DE GRAPHIQUES
  // ============================================

  /// Ventes par jour (30 derniers jours)
  List<Map<String, dynamic>> get salesByDay => _stats?.salesByDay ?? [];

  /// Revenus par mois (12 derniers mois)
  List<Map<String, dynamic>> get revenueByMonth => _stats?.revenueByMonth ?? [];

  /// Commandes par statut
  Map<String, int> get ordersByStatus => _stats?.ordersByStatus ?? {};

  /// Top produits
  List<Map<String, dynamic>> get topProducts => _stats?.topProducts ?? [];

  /// Top catégories
  List<Map<String, dynamic>> get topCategories => _stats?.topCategories ?? [];

  /// Commandes récentes
  List<Map<String, dynamic>> get recentOrders => _stats?.recentOrders ?? [];

  /// Utilisateurs récents
  List<Map<String, dynamic>> get recentUsers => _stats?.recentUsers ?? [];

  // ============================================
  // DONNÉES D'ALERTES
  // ============================================

  /// Produits en stock faible
  List<Map<String, dynamic>> get lowStockProducts => _stats?.lowStockProducts ?? [];

  /// Nombre de produits en stock faible
  int get lowStockCount => _stats?.lowStockCount ?? 0;

  /// Nombre d'avis en attente
  int get pendingReviewsCount => _stats?.pendingReviewsCount ?? 0;

  /// Nombre de commandes en attente
  int get pendingOrdersCount => _stats?.pendingOrdersCount ?? 0;

  /// Nombre de paiements en attente
  int get pendingPaymentsCount => _stats?.pendingPaymentsCount ?? 0;

  /// Nombre de retours en attente
  int get pendingReturnsCount => _stats?.pendingReturnsCount ?? 0;

  // ============================================
  // DONNÉES DE PERFORMANCE
  // ============================================

  /// Nombre total de visites
  int get totalVisits => _stats?.totalVisits ?? 0;

  /// Nombre total de favoris
  int get totalFavorites => _stats?.totalFavorites ?? 0;

  /// Nombre total d'avis
  int get totalReviews => _stats?.totalReviews ?? 0;

  /// Note moyenne
  double get averageRating => _stats?.averageRating ?? 0;

  /// Note moyenne formatée
  String get averageRatingFormatted => _stats?.averageRatingFormatted ?? '0.0';

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  /// Réinitialise le provider à l'état initial.
  void reset() {
    _status = DashboardStatus.initial;
    _stats = null;
    _errorMessage = null;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Charge plus de données (pagination si nécessaire).
  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    // La pagination sera implémentée si l'API la supporte
    _isLoadingMore = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoadingMore = false;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminDashboardProvider(status: $_status, stats: ${_stats != null ? 'loaded' : 'null'}, '
        'revenue: $totalRevenueFormatted, alerts: $totalAlerts)';
  }
}