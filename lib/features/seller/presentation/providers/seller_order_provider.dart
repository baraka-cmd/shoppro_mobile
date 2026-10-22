// ============================================
// PROVIDER : SellerOrderProvider
// ============================================
// Gestion d'état pour les commandes vendeur.
//
// Responsabilités :
//   - Chargement paginé avec filtres (statut seller, recherche, dates)
//   - Filtre par onglet (to_accept, preparing, shipped, delivered, cancelled)
//   - Actions : accept, prepare, ship, cancel
//   - Badges de comptage par statut (pour les tabs)
//   - Gestion des erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_order.dart';

// Data
import '../../data/sources/seller_order_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerOrderListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  forbidden,
  unauthorized,
}

enum SellerOrderActionStatus {
  idle,
  accepting,
  preparing,
  shipping,
  cancelling,
  error,
}

// ============================================
// ONGLETS (TABS)
// ============================================

enum SellerOrderTab {
  toAccept('to_accept', 'À accepter'),
  preparing('preparing', 'En préparation'),
  shipped('shipped', 'Expédiées'),
  delivered('delivered', 'Livrées'),
  cancelled('cancelled', 'Annulées'),
  all('all', 'Toutes');

  final String statusCode;
  final String label;

  const SellerOrderTab(this.statusCode, this.label);
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerOrderProvider extends ChangeNotifier {
  final SellerOrderApi _api;

  SellerOrderProvider({SellerOrderApi? api}) : _api = api ?? SellerOrderApi();

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerOrderListStatus _listStatus = SellerOrderListStatus.initial;
  List<SellerOrder> _orders = [];
  String? _listError;
  String? _kycStatus;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 15;

  // Filtre actif (onglet)
  SellerOrderTab _activeTab = SellerOrderTab.toAccept;

  // Recherche
  String _search = '';

  // ============================================
  // ÉTAT : BADGES (compteurs par onglet)
  // ============================================

  int _toAcceptCount = 0;
  int _preparingCount = 0;
  int _shippedCount = 0;
  int _deliveredCount = 0;
  int _cancelledCount = 0;

  // ============================================
  // ÉTAT : DÉTAIL
  // ============================================

  SellerOrder? _currentOrder;
  bool _isLoadingDetail = false;
  String? _detailError;

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerOrderActionStatus _actionStatus = SellerOrderActionStatus.idle;
  String? _actionError;
  String? _actionSuccessMessage;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerOrderListStatus get listStatus => _listStatus;
  List<SellerOrder> get orders => List.unmodifiable(_orders);
  String? get listError => _listError;
  String? get kycStatus => _kycStatus;

  bool get isLoading => _listStatus == SellerOrderListStatus.loading;
  bool get isLoaded => _listStatus == SellerOrderListStatus.loaded;
  bool get isLoadingMore => _listStatus == SellerOrderListStatus.loadingMore;
  bool get hasError => _listStatus == SellerOrderListStatus.error;
  bool get isForbidden => _listStatus == SellerOrderListStatus.forbidden;
  bool get isUnauthorized => _listStatus == SellerOrderListStatus.unauthorized;

  bool get isEmpty => _orders.isEmpty;
  int get ordersCount => _orders.length;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _hasMore;

  SellerOrderTab get activeTab => _activeTab;
  String get search => _search;

  // ============================================
  // GETTERS : BADGES
  // ============================================

  int get toAcceptCount => _toAcceptCount;
  int get preparingCount => _preparingCount;
  int get shippedCount => _shippedCount;
  int get deliveredCount => _deliveredCount;
  int get cancelledCount => _cancelledCount;

  /// Compteur total d'actions requises (accept + prepare).
  int get totalPendingActions => _toAcceptCount + _preparingCount;

  /// Retourne le count d'un onglet donné.
  int getCountForTab(SellerOrderTab tab) {
    switch (tab) {
      case SellerOrderTab.toAccept:
        return _toAcceptCount;
      case SellerOrderTab.preparing:
        return _preparingCount;
      case SellerOrderTab.shipped:
        return _shippedCount;
      case SellerOrderTab.delivered:
        return _deliveredCount;
      case SellerOrderTab.cancelled:
        return _cancelledCount;
      case SellerOrderTab.all:
        return _toAcceptCount + _preparingCount + _shippedCount + _deliveredCount + _cancelledCount;
    }
  }

  // ============================================
  // GETTERS : DÉTAIL
  // ============================================

  SellerOrder? get currentOrder => _currentOrder;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;
  bool get hasCurrentOrder => _currentOrder != null;

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerOrderActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  String? get actionSuccessMessage => _actionSuccessMessage;

  bool get isAccepting => _actionStatus == SellerOrderActionStatus.accepting;
  bool get isPreparing => _actionStatus == SellerOrderActionStatus.preparing;
  bool get isShipping => _actionStatus == SellerOrderActionStatus.shipping;
  bool get isCancelling => _actionStatus == SellerOrderActionStatus.cancelling;
  bool get hasActionError => _actionStatus == SellerOrderActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerOrderActionStatus.idle &&
      _actionStatus != SellerOrderActionStatus.error;

  // ============================================
  // CHARGEMENT DE LA LISTE
  // ============================================

  /// Charge la première page avec l'onglet actif.
  Future<void> loadOrders({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerOrderListStatus.loading;
    _listError = null;
    _kycStatus = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getOrders(
        page: 1,
        perPage: _perPage,
        sellerStatus: _activeTab.statusCode,
        search: _search.isNotEmpty ? _search : null,
      );

      _orders = result.orders;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerOrderListStatus.loaded;

      // Mettre à jour les compteurs
      await _loadCounts();
    } on SellerOrderForbiddenException catch (e) {
      _listStatus = SellerOrderListStatus.forbidden;
      _listError = e.message;
      _kycStatus = e.code;
    } on SellerOrderUnauthorizedException catch (e) {
      _listStatus = SellerOrderListStatus.unauthorized;
      _listError = e.message;
    } catch (e) {
      _listStatus = SellerOrderListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge la page suivante (pagination infinie).
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerOrderListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _api.getOrders(
        page: nextPage,
        perPage: _perPage,
        sellerStatus: _activeTab.statusCode,
        search: _search.isNotEmpty ? _search : null,
      );

      _orders = [..._orders, ...result.orders];
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerOrderListStatus.loaded;
    } catch (e) {
      _listStatus = SellerOrderListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit la liste (pull-to-refresh).
  Future<void> refresh() async {
    await loadOrders(forceRefresh: true);
  }

  /// Charge les compteurs de tous les onglets (pour les badges).
  Future<void> _loadCounts() async {
    try {
      // Charger les counts en parallèle
      final futures = await Future.wait([
        _api.getOrders(page: 1, perPage: 1, sellerStatus: 'to_accept'),
        _api.getOrders(page: 1, perPage: 1, sellerStatus: 'preparing'),
        _api.getOrders(page: 1, perPage: 1, sellerStatus: 'shipped'),
        _api.getOrders(page: 1, perPage: 1, sellerStatus: 'delivered'),
        _api.getOrders(page: 1, perPage: 1, sellerStatus: 'cancelled'),
      ]);

      _toAcceptCount = futures[0].total;
      _preparingCount = futures[1].total;
      _shippedCount = futures[2].total;
      _deliveredCount = futures[3].total;
      _cancelledCount = futures[4].total;
    } catch (e) {
      debugPrint('⚠️ Impossible de charger les compteurs: $e');
    }
  }

  // ============================================
  // CHANGEMENT D'ONGLET
  // ============================================

  /// Change l'onglet actif et recharge la liste.
  Future<void> setActiveTab(SellerOrderTab tab) async {
    if (_activeTab == tab) return;

    _activeTab = tab;
    _orders = [];
    _currentPage = 1;
    _hasMore = false;

    await loadOrders();
  }

  /// Change la recherche et recharge.
  Future<void> setSearch(String value) async {
    _search = value.trim();
    await loadOrders();
  }

  /// Efface la recherche.
  Future<void> clearSearch() async {
    _search = '';
    await loadOrders();
  }

  // ============================================
  // CHARGEMENT DU DÉTAIL
  // ============================================

  /// Charge le détail d'une commande.
  Future<void> loadOrderDetail(int orderId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _currentOrder = null;
    notifyListeners();

    try {
      final order = await _api.getOrderById(orderId);
      _currentOrder = order;
      _isLoadingDetail = false;
    } catch (e) {
      _isLoadingDetail = false;
      _detailError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Efface la commande courante.
  void clearCurrentOrder() {
    _currentOrder = null;
    _detailError = null;
    _actionStatus = SellerOrderActionStatus.idle;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();
  }

  // ============================================
  // ACTIONS : ACCEPT
  // ============================================

  Future<SellerOrder?> acceptOrder(int orderId) async {
    return _performAction(
      status: SellerOrderActionStatus.accepting,
      successMessage: 'Commande acceptée',
      action: () => _api.acceptOrder(orderId),
    );
  }

  // ============================================
  // ACTIONS : PREPARE
  // ============================================

  Future<SellerOrder?> prepareOrder(int orderId) async {
    return _performAction(
      status: SellerOrderActionStatus.preparing,
      successMessage: 'Commande en préparation',
      action: () => _api.prepareOrder(orderId),
    );
  }

  // ============================================
  // ACTIONS : SHIP
  // ============================================

  Future<SellerOrder?> shipOrder(
    int orderId, {
    required String trackingNumber,
    required String carrier,
    String? trackingUrl,
    String? sellerNote,
  }) async {
    return _performAction(
      status: SellerOrderActionStatus.shipping,
      successMessage: 'Commande expédiée',
      action: () => _api.shipOrder(
        orderId,
        trackingNumber: trackingNumber,
        carrier: carrier,
        trackingUrl: trackingUrl,
        sellerNote: sellerNote,
      ),
    );
  }

  // ============================================
  // ACTIONS : CANCEL
  // ============================================

  Future<SellerOrder?> cancelOrder(
    int orderId, {
    required String reason,
    String? reasonDetails,
    bool restock = true,
    List<int>? itemIds,
  }) async {
    return _performAction(
      status: SellerOrderActionStatus.cancelling,
      successMessage: 'Commande annulée',
      action: () => _api.cancelOrder(
        orderId,
        reason: reason,
        reasonDetails: reasonDetails,
        restock: restock,
        itemIds: itemIds,
      ),
    );
  }

  // ============================================
  // HELPER : EXÉCUTION D'ACTION
  // ============================================

      Future<SellerOrder?> _performAction({
    required SellerOrderActionStatus status,
    required String successMessage,
    required Future<SellerOrder> Function() action,
  }) async {
    _actionStatus = status;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await action();

      // Mettre à jour la commande courante
      if (_currentOrder?.id == updatedOrder.id) {
        _currentOrder = updatedOrder;
      }

      // Mettre à jour la commande dans la liste
      final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        final newList = List<SellerOrder>.from(_orders);
        newList[index] = updatedOrder;
        _orders = newList;
      }

      _actionStatus = SellerOrderActionStatus.idle;
      _actionSuccessMessage = successMessage;
      notifyListeners();

      // Rafraîchir les compteurs en arrière-plan
      _loadCounts().then((_) => notifyListeners());

      return updatedOrder;
    } catch (e) {
      _actionStatus = SellerOrderActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs courantes.
  void clearErrors() {
    _listError = null;
    _actionError = null;
    _detailError = null;

    if (_listStatus == SellerOrderListStatus.error) {
      _listStatus = _orders.isNotEmpty
          ? SellerOrderListStatus.loaded
          : SellerOrderListStatus.initial;
    }

    if (_actionStatus == SellerOrderActionStatus.error) {
      _actionStatus = SellerOrderActionStatus.idle;
    }

    notifyListeners();
  }

  /// Efface le message de succès (après affichage).
  void clearSuccessMessage() {
    _actionSuccessMessage = null;
    notifyListeners();
  }

  /// Réinitialise complètement le provider (logout).
  void reset() {
    _listStatus = SellerOrderListStatus.initial;
    _actionStatus = SellerOrderActionStatus.idle;
    _orders = [];
    _currentOrder = null;
    _listError = null;
    _actionError = null;
    _detailError = null;
    _actionSuccessMessage = null;
    _kycStatus = null;
    _search = '';
    _activeTab = SellerOrderTab.toAccept;
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;
    _toAcceptCount = 0;
    _preparingCount = 0;
    _shippedCount = 0;
    _deliveredCount = 0;
    _cancelledCount = 0;
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerOrderProvider(tab: ${_activeTab.label}, '
        'orders: ${_orders.length}, total: $_total, '
        'actionStatus: $_actionStatus)';
  }
}