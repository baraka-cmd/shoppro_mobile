// ============================================
// PROVIDER : AdminStatsProvider
// ============================================
// Provider de gestion d'état pour les statistiques et rapports.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Génération de rapports par période
// - Analyse des revenus, commandes, clients, produits
// - Export de rapports
// - Gestion du cache
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/sales_report.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_stats_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_stats_repository_impl.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider statistiques
enum AdminStatsStatus {
  initial,
  loading,
  loaded,
  generating,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider des statistiques et rapports.
///
/// Gère :
/// - La génération des rapports de ventes
/// - Les analyses multi-dimensionnelles
/// - Les exports CSV/JSON
/// - Le cache des rapports
class AdminStatsProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminStatsRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminStatsStatus _status = AdminStatsStatus.initial;
  SalesReport? _currentReport;
  String? _errorMessage;
  SalesReportPeriod _selectedPeriod = SalesReportPeriod.last30Days;

  // Données de graphiques
  List<Map<String, dynamic>> _revenueByDay = [];
  List<Map<String, dynamic>> _revenueByWeek = [];
  List<Map<String, dynamic>> _revenueByMonth = [];
  List<Map<String, dynamic>> _ordersByHour = [];
  List<Map<String, dynamic>> _ordersByDayOfWeek = [];

  // Analyses
  Map<String, int> _ordersByStatus = {};
  Map<String, int> _paymentsByMethod = {};
  Map<String, int> _paymentsByStatus = {};
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _topCategories = [];
  List<Map<String, dynamic>> _topBrands = [];

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminStatsProvider({AdminStatsRepository? repository})
      : _repository = repository ?? AdminStatsRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminStatsStatus get status => _status;
  SalesReport? get currentReport => _currentReport;
  String? get errorMessage => _errorMessage;
  SalesReportPeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _status == AdminStatsStatus.loading;
  bool get isLoaded => _status == AdminStatsStatus.loaded;
  bool get isGenerating => _status == AdminStatsStatus.generating;
  bool get hasError => _status == AdminStatsStatus.error;

  // Données de graphiques
  List<Map<String, dynamic>> get revenueByDay => List.unmodifiable(_revenueByDay);
  List<Map<String, dynamic>> get revenueByWeek => List.unmodifiable(_revenueByWeek);
  List<Map<String, dynamic>> get revenueByMonth => List.unmodifiable(_revenueByMonth);
  List<Map<String, dynamic>> get ordersByHour => List.unmodifiable(_ordersByHour);
  List<Map<String, dynamic>> get ordersByDayOfWeek => List.unmodifiable(_ordersByDayOfWeek);

  // Analyses
  Map<String, int> get ordersByStatus => Map.unmodifiable(_ordersByStatus);
  Map<String, int> get paymentsByMethod => Map.unmodifiable(_paymentsByMethod);
  Map<String, int> get paymentsByStatus => Map.unmodifiable(_paymentsByStatus);
  List<Map<String, dynamic>> get topProducts => List.unmodifiable(_topProducts);
  List<Map<String, dynamic>> get topCategories => List.unmodifiable(_topCategories);
  List<Map<String, dynamic>> get topBrands => List.unmodifiable(_topBrands);

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge le rapport pour la période sélectionnée.
  Future<void> loadReport() async {
    _status = AdminStatsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _getReportForPeriod(_selectedPeriod);
      _currentReport = report;
      _status = AdminStatsStatus.loaded;
      await _loadGraphData();
      await _loadAnalysisData();
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStatsStatus.error;
      debugPrint('Erreur loadReport: $e');
    }

    notifyListeners();
  }

  /// Change la période et recharge le rapport.
  Future<void> changePeriod(SalesReportPeriod period) async {
    _selectedPeriod = period;
    await loadReport();
  }

  /// Charge le rapport du jour.
  Future<void> loadTodayReport() async {
    _selectedPeriod = SalesReportPeriod.today;
    await loadReport();
  }

  /// Charge le rapport des 7 derniers jours.
  Future<void> loadLast7DaysReport() async {
    _selectedPeriod = SalesReportPeriod.last7Days;
    await loadReport();
  }

  /// Charge le rapport des 30 derniers jours.
  Future<void> loadLast30DaysReport() async {
    _selectedPeriod = SalesReportPeriod.last30Days;
    await loadReport();
  }

  /// Charge le rapport du mois en cours.
  Future<void> loadThisMonthReport() async {
    _selectedPeriod = SalesReportPeriod.thisMonth;
    await loadReport();
  }

  /// Charge le rapport de l'année en cours.
  Future<void> loadThisYearReport() async {
    _selectedPeriod = SalesReportPeriod.thisYear;
    await loadReport();
  }

  // ============================================
  // GÉNÉRATION PERSONNALISÉE
  // ============================================

  /// Génère un rapport personnalisé.
  Future<void> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _status = AdminStatsStatus.generating;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _repository.generateReport(
        startDate: startDate,
        endDate: endDate,
      );
      _currentReport = report;
      _status = AdminStatsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminStatsStatus.error;
      debugPrint('Erreur generateCustomReport: $e');
    }

    notifyListeners();
  }

  // ============================================
  // EXPORT
  // ============================================

  /// Exporte le rapport actuel en CSV.
  Future<String?> exportCurrentReportToCsv() async {
    final report = _currentReport;
    if (report == null) return null;
    return _repository.exportReportToCsv(report);
  }

  /// Exporte le rapport actuel en JSON.
  Future<String?> exportCurrentReportToJson() async {
    final report = _currentReport;
    if (report == null) return null;
    return _repository.exportReportToJson(report);
  }

  // ============================================
  // COMPARAISON
  // ============================================

  /// Compare la période actuelle avec la précédente.
  Future<Map<String, dynamic>?> compareWithPreviousPeriod() async {
    final report = _currentReport;
    if (report == null) return null;

    final currentStart = report.startDate;
    final currentEnd = report.endDate;
    final duration = currentEnd.difference(currentStart);
    final previousStart = currentStart.subtract(duration);
    final previousEnd = currentStart.subtract(const Duration(seconds: 1));

    try {
      return await _repository.comparePeriods(
        currentStart: currentStart,
        currentEnd: currentEnd,
        previousStart: previousStart,
        previousEnd: previousEnd,
      );
    } catch (e) {
      debugPrint('Erreur compareWithPreviousPeriod: $e');
      return null;
    }
  }

  // ============================================
  // CACHE
  // ============================================

  /// Rafraîchit le cache.
  Future<void> refreshCache() async {
    await _repository.refreshCache();
  }

  /// Efface le cache.
  Future<void> clearCache() async {
    await _repository.clearCache();
  }

  /// Vérifie si le cache existe.
  Future<bool> hasCachedData() async {
    return _repository.hasCachedStats();
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Récupère le rapport pour une période donnée.
  Future<SalesReport> _getReportForPeriod(SalesReportPeriod period) async {
    switch (period) {
      case SalesReportPeriod.today:
        return _repository.getTodayReport();
      case SalesReportPeriod.yesterday:
        return _repository.getYesterdayReport();
      case SalesReportPeriod.last7Days:
        return _repository.getLast7DaysReport();
      case SalesReportPeriod.last30Days:
        return _repository.getLast30DaysReport();
      case SalesReportPeriod.thisMonth:
        return _repository.getThisMonthReport();
      case SalesReportPeriod.lastMonth:
        return _repository.getLastMonthReport();
      case SalesReportPeriod.thisYear:
        return _repository.getThisYearReport();
      case SalesReportPeriod.lastYear:
        return _repository.getLastYearReport();
      case SalesReportPeriod.custom:
        final now = DateTime.now();
        return _repository.generateReport(
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now,
        );
    }
  }

  /// Charge les données de graphiques.
  Future<void> _loadGraphData() async {
    final report = _currentReport;
    if (report == null) return;

    _revenueByDay = report.revenueByDay;
    _revenueByWeek = report.revenueByWeek;
    _revenueByMonth = report.revenueByMonth;
    _ordersByHour = report.ordersByHour;
    _ordersByDayOfWeek = report.ordersByDayOfWeek;
  }

  /// Charge les données d'analyse.
  Future<void> _loadAnalysisData() async {
    try {
      _ordersByStatus = await _repository.getOrdersCountByStatus();
      _paymentsByMethod = await _repository.getPaymentsByMethod();
      _paymentsByStatus = await _repository.getPaymentsByStatus();
      _topProducts = await _repository.getTopProductsByRevenue();
      _topCategories = await _repository.getTopCategories();
      _topBrands = await _repository.getTopBrands();
    } catch (e) {
      debugPrint('Erreur _loadAnalysisData: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminStatsStatus.initial;
    _currentReport = null;
    _errorMessage = null;
    _selectedPeriod = SalesReportPeriod.last30Days;
    _revenueByDay = [];
    _revenueByWeek = [];
    _revenueByMonth = [];
    _ordersByHour = [];
    _ordersByDayOfWeek = [];
    _ordersByStatus = {};
    _paymentsByMethod = {};
    _paymentsByStatus = {};
    _topProducts = [];
    _topCategories = [];
    _topBrands = [];
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminStatsProvider(status: $_status, period: ${_selectedPeriod.displayName}, '
        'report: ${_currentReport != null ? 'loaded' : 'null'})';
  }
}