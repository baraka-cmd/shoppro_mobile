// ============================================
// PROVIDER : SellerDashboardProvider
// ============================================
// Gestion d'état du dashboard vendeur.
//
// Responsabilités :
//   - Charger les KPIs via le repository
//   - Gérer les états (loading, loaded, error, empty)
//   - Gérer le refresh (pull-to-refresh)
//   - Gérer les erreurs (KYC, réseau, serveur)
//   - Exposer les données aux widgets
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enum
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_dashboard.dart';
import '../../domain/repositories/seller_dashboard_repository.dart';

// Data
import '../../data/repositories/seller_dashboard_repository_impl.dart';
import '../../data/sources/seller_dashboard_api.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

enum SellerDashboardStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
  forbidden,  // KYC pending/rejected
  unauthorized,  // Token expiré
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerDashboardProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final SellerDashboardRepository _repository;

  SellerDashboardProvider({SellerDashboardRepository? repository})
      : _repository = repository ?? SellerDashboardRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  SellerDashboardStatus _status = SellerDashboardStatus.initial;
  SellerDashboard? _dashboard;
  String? _errorMessage;
  String? _kycStatus;  // pending, rejected, verified

  // Graphique de ventes
  Map<String, dynamic>? _salesChart;
  int _selectedPeriod = 30;
  bool _isLoadingChart = false;
  String? _chartError;

  // ============================================
  // GETTERS — ÉTAT
  // ============================================

  SellerDashboardStatus get status => _status;
  SellerDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _status == SellerDashboardStatus.loading;
  bool get isLoaded => _status == SellerDashboardStatus.loaded;
  bool get isRefreshing => _status == SellerDashboardStatus.refreshing;
  bool get hasError => _status == SellerDashboardStatus.error;
  bool get isForbidden => _status == SellerDashboardStatus.forbidden;
  bool get isUnauthorized => _status == SellerDashboardStatus.unauthorized;

  bool get hasDashboard => _dashboard != null;
  bool get isEmpty => _dashboard?.isEmpty ?? true;

  // ============================================
  // GETTERS — DONNÉES
  // ============================================

  SellerInfo? get seller => _dashboard?.seller;
  RevenueKpi? get revenue => _dashboard?.revenue;
  OrdersKpi? get orders => _dashboard?.orders;
  ProductsKpi? get products => _dashboard?.products;
  ReviewsKpi? get reviews => _dashboard?.reviews;
  BalanceKpi? get balance => _dashboard?.balance;
  List<DashboardAlert> get alerts => _dashboard?.alerts ?? const [];
  List<DashboardOrderSummary> get recentOrders =>
      _dashboard?.recentOrders ?? const [];
  List<DashboardTopProduct> get topProducts =>
      _dashboard?.topProducts ?? const [];

  int get alertsCount => alerts.length;
  int get pendingOrdersCount => orders?.pendingCount ?? 0;

  // ============================================
  // GETTERS — GRAPHIQUE
  // ============================================

  Map<String, dynamic>? get salesChart => _salesChart;
  int get selectedPeriod => _selectedPeriod;
  bool get isLoadingChart => _isLoadingChart;
  String? get chartError => _chartError;
  bool get hasChartData => _salesChart != null;

  // ============================================
  // CHARGEMENT PRINCIPAL
  // ============================================

  /// Charge le dashboard complet.
  ///
  /// [forceRefresh] : si true, ignore le cache.
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    // Si on a déjà des données, on est en mode "refreshing"
    final isRefresh = _dashboard != null && !forceRefresh;

    _status = isRefresh
        ? SellerDashboardStatus.refreshing
        : SellerDashboardStatus.loading;
    _errorMessage = null;
    _kycStatus = null;
    notifyListeners();

    try {
      final dashboard = forceRefresh
          ? await _repository.refreshDashboard()
          : await _repository.getDashboard();

      _dashboard = dashboard;
      _status = SellerDashboardStatus.loaded;
    } on SellerDashboardForbiddenException catch (e) {
      _status = SellerDashboardStatus.forbidden;
      _errorMessage = e.message;
      _kycStatus = e.kycStatus;
      debugPrint('🚫 Dashboard forbidden: ${e.message}');
    } on SellerDashboardUnauthorizedException catch (e) {
      _status = SellerDashboardStatus.unauthorized;
      _errorMessage = e.message;
      debugPrint('🔒 Dashboard unauthorized: ${e.message}');
    } on SellerDashboardNetworkException catch (e) {
      _status = SellerDashboardStatus.error;
      _errorMessage = e.message;
      debugPrint('📡 Dashboard network error: ${e.message}');
    } on SellerDashboardServerException catch (e) {
      _status = SellerDashboardStatus.error;
      _errorMessage = e.message;
      debugPrint('💥 Dashboard server error: ${e.message}');
    } catch (e) {
      _status = SellerDashboardStatus.error;
      _errorMessage = 'Une erreur inattendue est survenue.';
      debugPrint('❌ Dashboard unknown error: $e');
    }

    notifyListeners();
  }

  /// Refresh (pull-to-refresh).
  Future<void> refresh() async {
    await loadDashboard(forceRefresh: true);

    // Recharger aussi le graphique si présent
    if (_salesChart != null) {
      await loadSalesChart(period: _selectedPeriod, forceRefresh: true);
    }
  }

  // ============================================
  // GRAPHIQUE
  // ============================================

  /// Charge le graphique de ventes.
  ///
  /// [period] : 7, 30 ou 90 jours.
  Future<void> loadSalesChart({
    int? period,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingChart) return;

    final newPeriod = period ?? _selectedPeriod;

    // Si on demande la même période sans force, on skip
    if (!forceRefresh && _salesChart != null && newPeriod == _selectedPeriod) {
      return;
    }

    _selectedPeriod = newPeriod;
    _isLoadingChart = true;
    _chartError = null;
    notifyListeners();

    try {
      final chart = await _repository.getSalesChart(period: newPeriod);

      _salesChart = chart;
      _isLoadingChart = false;
    } catch (e) {
      _isLoadingChart = false;
      _chartError = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Erreur loadSalesChart: $e');
    }

    notifyListeners();
  }

  /// Change la période du graphique.
  Future<void> changePeriod(int period) async {
    if (period == _selectedPeriod) return;

    await loadSalesChart(period: period, forceRefresh: true);
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Réinitialise complètement le provider.
  ///
  /// Utilisé au logout.
  Future<void> reset() async {
    _status = SellerDashboardStatus.initial;
    _dashboard = null;
    _errorMessage = null;
    _kycStatus = null;
    _salesChart = null;
    _selectedPeriod = 30;
    _isLoadingChart = false;
    _chartError = null;

    await _repository.clearCache();

    notifyListeners();
  }

  /// Efface l'erreur courante.
  void clearError() {
    _errorMessage = null;

    if (_status == SellerDashboardStatus.error ||
        _status == SellerDashboardStatus.forbidden ||
        _status == SellerDashboardStatus.unauthorized) {
      _status = _dashboard != null
          ? SellerDashboardStatus.loaded
          : SellerDashboardStatus.initial;
    }

    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SellerDashboardProvider(status: $_status, '
        'hasDashboard: $hasDashboard, '
        'alerts: $alertsCount, '
        'pendingOrders: $pendingOrdersCount)';
  }
}