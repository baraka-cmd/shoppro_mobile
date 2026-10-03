// ============================================
// PROVIDER DES COMMANDES - VERSION PREMIUM
// ============================================
// Gère l'état des commandes avec actions complètes,
// filtres, annulation et retour.
//
// ⚠️ La création de commande passe par l'API Laravel.
//    Les items sont envoyés directement dans la requête.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';

enum OrderStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;

  OrderProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  OrderStatus _status = OrderStatus.initial;
  List<Order> _orders = [];
  String? _errorMessage;
  int _updatingOrderId = -1;
  String _currentFilter = 'all';

  // ============================================
  // GETTERS DE BASE
  // ============================================

  OrderStatus get status => _status;
  List<Order> get orders => _orders;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == OrderStatus.loading;
  bool get isCreating => _status == OrderStatus.creating;
  bool get isUpdating => _status == OrderStatus.updating;
  bool get hasError => _status == OrderStatus.error;
  bool get isEmpty => _orders.isEmpty;
  int get ordersCount => _orders.length;

  int get updatingOrderId => _updatingOrderId;
  String get currentFilter => _currentFilter;

  // ============================================
  // GETTERS FILTRÉS
  // ============================================

  List<Order> get filteredOrders {
    switch (_currentFilter) {
      case 'active':
        return activeOrders;
      case 'delivered':
        return deliveredOrders;
      case 'cancelled':
        return cancelledOrders;
      default:
        return List.from(_orders);
    }
  }

  List<Order> get activeOrders {
    return _orders
        .where((o) =>
            o.status != 'delivered' &&
            o.status != 'cancelled' &&
            o.status != 'returned')
        .toList();
  }

  List<Order> get deliveredOrders {
    return _orders.where((o) => o.status == 'delivered').toList();
  }

  List<Order> get cancelledOrders {
    return _orders.where((o) => o.status == 'cancelled').toList();
  }

  int get activeOrdersCount => activeOrders.length;
  int get deliveredOrdersCount => deliveredOrders.length;
  int get cancelledOrdersCount => cancelledOrders.length;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger les commandes depuis l'API (avec fallback local)
  Future<void> loadOrders() async {
    _setStatus(OrderStatus.loading);
    _clearError();

    try {
      _orders = await _orderRepository.getOrders();
      _setStatus(OrderStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(OrderStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les commandes
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  // ============================================
  // CRÉATION (via API Laravel)
  // ============================================

  /// Créer une commande côté serveur.
  ///
  /// [shippingAddressId] : ID de l'adresse de livraison (obligatoire)
  /// [items] : liste des articles (obligatoire)
  ///           Format : [{ 'product_id': 1, 'quantity': 2, 'variant_id': null }]
  /// [billingAddressId] : ID de l'adresse de facturation (optionnel)
  /// [shippingMethod] : 'standard' | 'express' | 'pickup'
  /// [paymentMethod] : 'cash_on_delivery' | 'mobile_money' | 'card'
  /// [couponCode] : code promo (optionnel)
  /// [customerNote] : note du client (optionnel)
  Future<Order?> createOrder({
    required int shippingAddressId,
    required List<Map<String, dynamic>> items,
    int? billingAddressId,
    String? shippingMethod,
    String? paymentMethod,
    String? couponCode,
    String? customerNote,
  }) async {
    _setStatus(OrderStatus.creating);
    _clearError();

    try {
      // 1. Sauvegarder un snapshot (undo)
      await _orderRepository.saveOrdersSnapshot();

      // 2. Créer la commande côté serveur
      final order = await _orderRepository.createOrder(
        shippingAddressId: shippingAddressId,
        items: items,
        billingAddressId: billingAddressId,
        shippingMethod: shippingMethod,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        customerNote: customerNote,
      );

      // 3. Recharger la liste complète
      _orders = await _orderRepository.getOrders();

      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return order;
    } catch (e) {
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // ANNULATION
  // ============================================

  Future<bool> canCancelOrder(int orderId) async {
    return await _orderRepository.canCancelOrder(orderId);
  }

  Future<bool> cancelOrder(int orderId, String reason) async {
    _setStatus(OrderStatus.updating);
    _updatingOrderId = orderId;

    try {
      await _orderRepository.saveOrdersSnapshot();
      await _orderRepository.cancelOrder(orderId, reason);
      _orders = await _orderRepository.getOrders();
      _updatingOrderId = -1;
      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingOrderId = -1;
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RETOUR
  // ============================================

  Future<bool> canReturnOrder(int orderId) async {
    return await _orderRepository.canReturnOrder(orderId);
  }

  Future<bool> returnOrder(int orderId, String reason) async {
    _setStatus(OrderStatus.updating);
    _updatingOrderId = orderId;

    try {
      await _orderRepository.saveOrdersSnapshot();
      await _orderRepository.returnOrder(orderId, reason);
      _orders = await _orderRepository.getOrders();
      _updatingOrderId = -1;
      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingOrderId = -1;
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnOrderItem(int orderId, int itemId, String reason) async {
    _setStatus(OrderStatus.updating);
    _updatingOrderId = orderId;

    try {
      await _orderRepository.saveOrdersSnapshot();
      await _orderRepository.returnOrderItem(orderId, itemId, reason);
      _orders = await _orderRepository.getOrders();
      _updatingOrderId = -1;
      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingOrderId = -1;
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // FILTRES
  // ============================================

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _currentFilter = 'all';
    notifyListeners();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  Order? getOrderById(int orderId) {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  Order? getOrderByNumber(String orderNumber) {
    for (final order in _orders) {
      if (order.orderNumber.toLowerCase() == orderNumber.toLowerCase()) {
        return order;
      }
    }
    return null;
  }

  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    return await _orderRepository.getOrderTimeline(orderId);
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  Future<bool> undoLastAction() async {
    try {
      final restored = await _orderRepository.restoreOrdersSnapshot();
      if (restored.isNotEmpty) {
        _orders = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(OrderStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  @override
  String toString() {
    return 'OrderProvider(status: $_status, orders: ${_orders.length}, '
        'filter: $_currentFilter, active: $activeOrdersCount, '
        'delivered: $deliveredOrdersCount, cancelled: $cancelledOrdersCount)';
  }
}