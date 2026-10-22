// ============================================
// PROVIDER : SellerPayoutProvider
// ============================================
// Gestion d'état pour les payouts vendeur.
//
// Responsabilités :
//   - Charger le solde (balance)
//   - Charger la liste paginée des payouts
//   - Filtrer par statut (all, pending, processing, completed, failed)
//   - Demander un versement (request)
//   - Annuler un payout pending (cancel)
//   - Gérer les erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_payout.dart';

// Data
import '../../data/sources/seller_payout_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerPayoutBalanceStatus {
  initial,
  loading,
  loaded,
  error,
  unauthorized,
}

enum SellerPayoutListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

enum SellerPayoutActionStatus {
  idle,
  requesting,
  cancelling,
  error,
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerPayoutProvider extends ChangeNotifier {
  final SellerPayoutApi _api;

  SellerPayoutProvider({SellerPayoutApi? api})
      : _api = api ?? SellerPayoutApi();

  // ============================================
  // ÉTAT : BALANCE
  // ============================================

  SellerPayoutBalanceStatus _balanceStatus = SellerPayoutBalanceStatus.initial;
  SellerBalance _balance = const SellerBalance.empty();
  String? _balanceError;

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerPayoutListStatus _listStatus = SellerPayoutListStatus.initial;
  List<SellerPayout> _payouts = [];
  String? _listError;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 20;

  // Filtre
  SellerPayoutFilter _filter = SellerPayoutFilter.all;

  // Stats
  SellerPayoutStats _stats = const SellerPayoutStats.empty();

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerPayoutActionStatus _actionStatus = SellerPayoutActionStatus.idle;
  String? _actionError;
  SellerPayout? _lastAffectedPayout;

  // ============================================
  // GETTERS : BALANCE
  // ============================================

  SellerPayoutBalanceStatus get balanceStatus => _balanceStatus;
  SellerBalance get balance => _balance;
  String? get balanceError => _balanceError;

  bool get isBalanceLoading =>
      _balanceStatus == SellerPayoutBalanceStatus.loading;
  bool get isBalanceLoaded =>
      _balanceStatus == SellerPayoutBalanceStatus.loaded;
  bool get hasBalanceError =>
      _balanceStatus == SellerPayoutBalanceStatus.error;
  bool get isBalanceUnauthorized =>
      _balanceStatus == SellerPayoutBalanceStatus.unauthorized;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerPayoutListStatus get listStatus => _listStatus;
  List<SellerPayout> get payouts => List.unmodifiable(_payouts);
  String? get listError => _listError;

  bool get isLoading => _listStatus == SellerPayoutListStatus.loading;
  bool get isLoaded => _listStatus == SellerPayoutListStatus.loaded;
  bool get isLoadingMore => _listStatus == SellerPayoutListStatus.loadingMore;
  bool get hasError => _listStatus == SellerPayoutListStatus.error;

  bool get isEmpty => _payouts.isEmpty;
  int get payoutsCount => _payouts.length;
  int get total => _total;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  SellerPayoutFilter get filter => _filter;

  // ============================================
  // GETTERS : STATS
  // ============================================

  SellerPayoutStats get stats => _stats;

  int get totalPayouts => _stats.totalPayouts;
  int get completedCount => _stats.completedCount;
  int get pendingCount => _stats.pendingCount;
  int get processingCount => _stats.processingCount;
  double get totalWithdrawn => _stats.totalWithdrawn;

  bool get hasPayouts => _stats.hasPayouts;

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerPayoutActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  SellerPayout? get lastAffectedPayout => _lastAffectedPayout;

  bool get isRequesting =>
      _actionStatus == SellerPayoutActionStatus.requesting;
  bool get isCancelling =>
      _actionStatus == SellerPayoutActionStatus.cancelling;
  bool get hasActionError =>
      _actionStatus == SellerPayoutActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerPayoutActionStatus.idle &&
      _actionStatus != SellerPayoutActionStatus.error;

  // ============================================
  // CHARGEMENT DU SOLDE
  // ============================================

  /// Charge le solde du vendeur.
  Future<void> loadBalance({bool forceRefresh = false}) async {
    if (isBalanceLoading && !forceRefresh) return;

    _balanceStatus = SellerPayoutBalanceStatus.loading;
    _balanceError = null;
    notifyListeners();

    try {
      final balance = await _api.getBalance();
      _balance = balance;
      _balanceStatus = SellerPayoutBalanceStatus.loaded;
    } on SellerPayoutUnauthorizedException catch (e) {
      _balanceStatus = SellerPayoutBalanceStatus.unauthorized;
      _balanceError = e.message;
    } catch (e) {
      _balanceStatus = SellerPayoutBalanceStatus.error;
      _balanceError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  // ============================================
  // CHARGEMENT DE LA LISTE
  // ============================================

  /// Charge la première page.
  Future<void> loadPayouts({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerPayoutListStatus.loading;
    _listError = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getPayouts(
        page: 1,
        perPage: _perPage,
        status: _filter.code,
      );

      _payouts = result.payouts;
      _stats = result.stats;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerPayoutListStatus.loaded;
    } catch (e) {
      _listStatus = SellerPayoutListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge la page suivante.
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerPayoutListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _api.getPayouts(
        page: nextPage,
        perPage: _perPage,
        status: _filter.code,
      );

      _payouts = [..._payouts, ...result.payouts];
      _stats = result.stats;
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerPayoutListStatus.loaded;
    } catch (e) {
      _listStatus = SellerPayoutListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit tout (balance + liste).
  Future<void> refresh() async {
    await Future.wait([
      loadBalance(forceRefresh: true),
      loadPayouts(forceRefresh: true),
    ]);
  }

  /// Charge tout au démarrage.
  Future<void> loadAll() async {
    await Future.wait([
      loadBalance(),
      loadPayouts(),
    ]);
  }

  // ============================================
  // FILTRE
  // ============================================

  /// Change le filtre et recharge.
  Future<void> setFilter(SellerPayoutFilter filter) async {
    if (_filter == filter) return;
    _filter = filter;
    _payouts = [];
    await loadPayouts();
  }

  // ============================================
  // REQUEST — DEMANDER UN VERSEMENT
  // ============================================

  /// Demande un versement.
  ///
  /// [amount]  : montant demandé
  /// [method]  : mobile_money | bank_transfer | paypal
  /// [account] : compte destinataire (optionnel)
  /// [note]    : note optionnelle
  Future<SellerPayout?> requestPayout({
    required double amount,
    required String method,
    String? account,
    String? note,
  }) async {
    _actionStatus = SellerPayoutActionStatus.requesting;
    _actionError = null;
    notifyListeners();

    try {
      final payout = await _api.requestPayout(
        amount: amount,
        method: method,
        account: account,
        note: note,
      );

      // Ajouter en tête de liste
      _payouts = [payout, ..._payouts];
      _total++;
      _lastAffectedPayout = payout;

      _actionStatus = SellerPayoutActionStatus.idle;
      notifyListeners();

      // Rafraîchir le solde en arrière-plan
      loadBalance(forceRefresh: true);

      return payout;
    } catch (e) {
      _actionStatus = SellerPayoutActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // CANCEL — ANNULER
  // ============================================

  /// Annule un payout pending.
  Future<SellerPayout?> cancelPayout(int id) async {
    _actionStatus = SellerPayoutActionStatus.cancelling;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await _api.cancelPayout(id);

      // Mettre à jour dans la liste
      final index = _payouts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newList = List<SellerPayout>.from(_payouts);
        newList[index] = updated;
        _payouts = newList;
      }

      _lastAffectedPayout = updated;
      _actionStatus = SellerPayoutActionStatus.idle;
      notifyListeners();

      // Rafraîchir le solde en arrière-plan
      loadBalance(forceRefresh: true);

      return updated;
    } catch (e) {
      _actionStatus = SellerPayoutActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs.
  void clearErrors() {
    _balanceError = null;
    _listError = null;
    _actionError = null;
    _lastAffectedPayout = null;

    if (_balanceStatus == SellerPayoutBalanceStatus.error) {
      _balanceStatus = SellerPayoutBalanceStatus.loaded;
    }

    if (_listStatus == SellerPayoutListStatus.error) {
      _listStatus = _payouts.isNotEmpty
          ? SellerPayoutListStatus.loaded
          : SellerPayoutListStatus.initial;
    }

    if (_actionStatus == SellerPayoutActionStatus.error) {
      _actionStatus = SellerPayoutActionStatus.idle;
    }

    notifyListeners();
  }

  /// Réinitialise complètement le provider.
  void reset() {
    _balanceStatus = SellerPayoutBalanceStatus.initial;
    _listStatus = SellerPayoutListStatus.initial;
    _actionStatus = SellerPayoutActionStatus.idle;
    _balance = const SellerBalance.empty();
    _payouts = [];
    _balanceError = null;
    _listError = null;
    _actionError = null;
    _lastAffectedPayout = null;
    _filter = SellerPayoutFilter.all;
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;
    _stats = const SellerPayoutStats.empty();
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerPayoutProvider(balance: ${_balance.availableFormatted}, '
        'payouts: ${_payouts.length}, filter: ${_filter.label})';
  }
}