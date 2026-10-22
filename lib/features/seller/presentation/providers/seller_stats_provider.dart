// ============================================
// PROVIDER : SellerStatsProvider
// ============================================
// Gestion d'état pour les statistiques vendeur.
//
// Responsabilités :
//   - Charger les 3 blocs de stats (sales, products, customers)
//   - Gérer le changement de période (7j/30j/90j/Tout)
//   - Cache local par période (évite les rechargements inutiles)
//   - Exporter les CSV (commandes/produits)
//   - Gestion des erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Cache par période pour performance
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_stats.dart';

// Data
import '../../data/sources/seller_stats_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerStatsStatus {
  initial,
  loading,
  loaded,
  error,
  forbidden,
  unauthorized,
}

enum SellerStatsExportStatus {
  idle,
  exporting,
  success,
  error,
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerStatsProvider extends ChangeNotifier {
  final SellerStatsApi _api;

  SellerStatsProvider({SellerStatsApi? api}) : _api = api ?? SellerStatsApi();

  // ============================================
  // ÉTAT : GLOBAL
  // ============================================

  SellerStatsStatus _status = SellerStatsStatus.initial;
  String? _errorMessage;
  String? _kycStatus;

  SellerStatsPeriod _period = SellerStatsPeriod.month;

  // ============================================
  // ÉTAT : DATA
  // ============================================

  SellerSalesStats _sales = const SellerSalesStats.empty();
  SellerProductStats _products = const SellerProductStats.empty();
  SellerCustomerStats _customers = const SellerCustomerStats.empty();

  bool _isLoadingSales = false;
  bool _isLoadingProducts = false;
  bool _isLoadingCustomers = false;

  // ============================================
  // CACHE PAR PÉRIODE
  // ============================================

  final Map<SellerStatsPeriod, SellerSalesStats> _salesCache = {};
  final Map<SellerStatsPeriod, SellerProductStats> _productsCache = {};
  final Map<SellerStatsPeriod, SellerCustomerStats> _customersCache = {};

  // ============================================
  // ÉTAT : EXPORT
  // ============================================

  SellerStatsExportStatus _exportStatus = SellerStatsExportStatus.idle;
  String? _exportError;
  SellerStatsExportResult? _lastExportResult;

  // ============================================
  // GETTERS : ÉTAT GLOBAL
  // ============================================

  SellerStatsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _status == SellerStatsStatus.loading;
  bool get isLoaded => _status == SellerStatsStatus.loaded;
  bool get hasError => _status == SellerStatsStatus.error;
  bool get isForbidden => _status == SellerStatsStatus.forbidden;
  bool get isUnauthorized => _status == SellerStatsStatus.unauthorized;

  SellerStatsPeriod get period => _period;

  // ============================================
  // GETTERS : DATA
  // ============================================

  SellerSalesStats get sales => _sales;
  SellerProductStats get products => _products;
  SellerCustomerStats get customers => _customers;

  bool get isLoadingSales => _isLoadingSales;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCustomers => _isLoadingCustomers;

  bool get hasAnyData =>
      _sales.hasSales ||
      _products.hasProducts ||
      _customers.hasCustomers;

  bool get hasSalesData => _sales.hasSales;
  bool get hasProductsData => _products.hasProducts;
  bool get hasCustomersData => _customers.hasCustomers;

  // ============================================
  // GETTERS : EXPORT
  // ============================================

  SellerStatsExportStatus get exportStatus => _exportStatus;
  String? get exportError => _exportError;
  SellerStatsExportResult? get lastExportResult => _lastExportResult;

  bool get isExporting => _exportStatus == SellerStatsExportStatus.exporting;
  bool get hasExportError => _exportStatus == SellerStatsExportStatus.error;
  bool get hasExportSuccess => _exportStatus == SellerStatsExportStatus.success;

  // ============================================
  // CHARGEMENT GLOBAL
  // ============================================

  /// Charge toutes les stats (sales, products, customers) pour la période active.
  Future<void> loadAll({bool forceRefresh = false}) async {
    // Vérifier le cache
    if (!forceRefresh && _isCacheValid()) {
      _sales = _salesCache[_period]!;
      _products = _productsCache[_period]!;
      _customers = _customersCache[_period]!;
      _status = SellerStatsStatus.loaded;
      notifyListeners();
      return;
    }

    _status = SellerStatsStatus.loading;
    _errorMessage = null;
    _kycStatus = null;
    notifyListeners();

    try {
      // Charger en parallèle
      final results = await Future.wait([
        _api.getSales(period: _period.days),
        _api.getProducts(period: _period.days),
        _api.getCustomers(period: _period.days),
      ]);

      _sales = results[0] as SellerSalesStats;
      _products = results[1] as SellerProductStats;
      _customers = results[2] as SellerCustomerStats;

      // Mettre en cache
      _salesCache[_period] = _sales;
      _productsCache[_period] = _products;
      _customersCache[_period] = _customers;

      _status = SellerStatsStatus.loaded;
    } on SellerStatsForbiddenException catch (e) {
      _status = SellerStatsStatus.forbidden;
      _errorMessage = e.message;
      _kycStatus = e.code;
    } on SellerStatsUnauthorizedException catch (e) {
      _status = SellerStatsStatus.unauthorized;
      _errorMessage = e.message;
    } catch (e) {
      _status = SellerStatsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // ============================================
  // CHANGEMENT DE PÉRIODE
  // ============================================

  /// Change la période et recharge les stats.
  Future<void> setPeriod(SellerStatsPeriod newPeriod) async {
    if (_period == newPeriod) return;

    _period = newPeriod;
    notifyListeners();

    // Recharger avec la nouvelle période
    await loadAll();
  }

  /// Rafraîchit les stats (force le rechargement).
  Future<void> refresh() async {
    // Vider le cache pour la période active
    _salesCache.remove(_period);
    _productsCache.remove(_period);
    _customersCache.remove(_period);

    await loadAll(forceRefresh: true);
  }

  // ============================================
  // CHARGEMENTS SPÉCIFIQUES (optionnel)
  // ============================================

  /// Charge uniquement les stats de ventes.
  Future<void> loadSalesOnly() async {
    if (_salesCache.containsKey(_period)) {
      _sales = _salesCache[_period]!;
      notifyListeners();
      return;
    }

    _isLoadingSales = true;
    notifyListeners();

    try {
      final sales = await _api.getSales(period: _period.days);
      _sales = sales;
      _salesCache[_period] = sales;
      _isLoadingSales = false;
    } catch (e) {
      _isLoadingSales = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge uniquement les top produits.
  Future<void> loadProductsOnly() async {
    if (_productsCache.containsKey(_period)) {
      _products = _productsCache[_period]!;
      notifyListeners();
      return;
    }

    _isLoadingProducts = true;
    notifyListeners();

    try {
      final products = await _api.getProducts(period: _period.days);
      _products = products;
      _productsCache[_period] = products;
      _isLoadingProducts = false;
    } catch (e) {
      _isLoadingProducts = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge uniquement les top clients.
  Future<void> loadCustomersOnly() async {
    if (_customersCache.containsKey(_period)) {
      _customers = _customersCache[_period]!;
      notifyListeners();
      return;
    }

    _isLoadingCustomers = true;
    notifyListeners();

    try {
      final customers = await _api.getCustomers(period: _period.days);
      _customers = customers;
      _customersCache[_period] = customers;
      _isLoadingCustomers = false;
    } catch (e) {
      _isLoadingCustomers = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // ============================================
  // EXPORT CSV
  // ============================================

  /// Exporte les commandes en CSV.
  ///
  /// [openAfterDownload] : si true, ouvre le fichier après téléchargement.
  Future<SellerStatsExportResult?> exportOrders({
    bool openAfterDownload = true,
  }) async {
    return _performExport(
      type: 'orders',
      openAfterDownload: openAfterDownload,
    );
  }

  /// Exporte les produits en CSV.
  Future<SellerStatsExportResult?> exportProducts({
    bool openAfterDownload = true,
  }) async {
    return _performExport(
      type: 'products',
      openAfterDownload: openAfterDownload,
    );
  }

  /// Méthode interne d'export.
  Future<SellerStatsExportResult?> _performExport({
    required String type,
    bool openAfterDownload = true,
  }) async {
    _exportStatus = SellerStatsExportStatus.exporting;
    _exportError = null;
    _lastExportResult = null;
    notifyListeners();

    try {
      final result = await _api.exportCsv(
        type: type,
        period: _period.days,
        openAfterDownload: openAfterDownload,
      );

      _lastExportResult = result;
      _exportStatus = SellerStatsExportStatus.success;
      notifyListeners();

      return result;
    } catch (e) {
      _exportStatus = SellerStatsExportStatus.error;
      _exportError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Partage le dernier fichier exporté.
  Future<void> shareLastExport() async {
    if (_lastExportResult == null) return;

    try {
      await _api.shareCsv(
        _lastExportResult!.filePath,
        subject: 'Export ShopPro - ${_period.label}',
      );
    } catch (e) {
      debugPrint('❌ Erreur shareLastExport: $e');
    }
  }

  /// Ouvre le dernier fichier exporté.
  Future<void> openLastExport() async {
    if (_lastExportResult == null) return;

    try {
      await _api.openCsv(_lastExportResult!.filePath);
    } catch (e) {
      debugPrint('❌ Erreur openLastExport: $e');
    }
  }

  /// Efface le statut d'export.
  void clearExportStatus() {
    _exportStatus = SellerStatsExportStatus.idle;
    _exportError = null;
    _lastExportResult = null;
    notifyListeners();
  }

  // ============================================
  // CACHE
  // ============================================

  /// Vérifie si le cache est valide pour la période actuelle.
  bool _isCacheValid() {
    return _salesCache.containsKey(_period) &&
        _productsCache.containsKey(_period) &&
        _customersCache.containsKey(_period);
  }

  /// Efface le cache.
  void clearCache() {
    _salesCache.clear();
    _productsCache.clear();
    _customersCache.clear();
    notifyListeners();
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs.
  void clearErrors() {
    _errorMessage = null;
    _exportError = null;

    if (_status == SellerStatsStatus.error) {
      _status = hasAnyData
          ? SellerStatsStatus.loaded
          : SellerStatsStatus.initial;
    }

    if (_exportStatus == SellerStatsExportStatus.error) {
      _exportStatus = SellerStatsExportStatus.idle;
    }

    notifyListeners();
  }

  /// Réinitialise complètement le provider (logout).
  void reset() {
    _status = SellerStatsStatus.initial;
    _exportStatus = SellerStatsExportStatus.idle;
    _sales = const SellerSalesStats.empty();
    _products = const SellerProductStats.empty();
    _customers = const SellerCustomerStats.empty();
    _errorMessage = null;
    _exportError = null;
    _kycStatus = null;
    _lastExportResult = null;
    _period = SellerStatsPeriod.month;
    _isLoadingSales = false;
    _isLoadingProducts = false;
    _isLoadingCustomers = false;
    _salesCache.clear();
    _productsCache.clear();
    _customersCache.clear();
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerStatsProvider(status: $_status, period: ${_period.label}, '
        'revenue: ${_sales.formattedRevenue})';
  }
}