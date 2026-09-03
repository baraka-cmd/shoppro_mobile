// ============================================
// PROVIDER DES COMMANDES - VERSION PREMIUM
// ============================================
// Gère l'état des commandes avec actions complètes,
// filtres, annulation et retour.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
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

  /// ID de la commande en cours de mise à jour
  int get updatingOrderId => _updatingOrderId;

  /// Filtre actuel
  String get currentFilter => _currentFilter;

  // ============================================
  // GETTERS FILTRÉS
  // ============================================

  /// Commandes filtrées selon le filtre actuel
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

  /// Commandes en cours
  List<Order> get activeOrders {
    return _orders
        .where((o) =>
            o.status != 'delivered' &&
            o.status != 'cancelled' &&
            o.status != 'returned')
        .toList();
  }

  /// Commandes livrées
  List<Order> get deliveredOrders {
    return _orders.where((o) => o.status == 'delivered').toList();
  }

  /// Commandes annulées
  List<Order> get cancelledOrders {
    return _orders.where((o) => o.status == 'cancelled').toList();
  }

  /// Nombre de commandes actives
  int get activeOrdersCount => activeOrders.length;

  /// Nombre de commandes livrées
  int get deliveredOrdersCount => deliveredOrders.length;

  /// Nombre de commandes annulées
  int get cancelledOrdersCount => cancelledOrders.length;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger les commandes
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
  // CRÉATION
  // ============================================

  /// Créer une commande
  Future<Order?> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double total,
    required double shippingFee,
    double discount = 0,
    double couponDiscount = 0,
    double tax = 0,
    String? couponCode,
    String? customerNote,
    String? shippingMethod,
    String? paymentMethod,
  }) async {
    _setStatus(OrderStatus.creating);
    _clearError();

    try {
      await _orderRepository.saveOrdersSnapshot();
      final order = await _orderRepository.createOrder(
        items: items,
        subtotal: subtotal,
        total: total,
        shippingFee: shippingFee,
        discount: discount,
        couponDiscount: couponDiscount,
        tax: tax,
        couponCode: couponCode,
        customerNote: customerNote,
        shippingMethod: shippingMethod,
        paymentMethod: paymentMethod,
      );

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

  /// Vérifier si une commande peut être annulée
  Future<bool> canCancelOrder(int orderId) async {
    return await _orderRepository.canCancelOrder(orderId);
  }

  /// Annuler une commande
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

  /// Vérifier si une commande peut être retournée
  Future<bool> canReturnOrder(int orderId) async {
    return await _orderRepository.canReturnOrder(orderId);
  }

  /// Retourner une commande
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

  /// Retourner un article spécifique
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

  /// Changer le filtre
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Effacer le filtre
  void clearFilter() {
    _currentFilter = 'all';
    notifyListeners();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Récupérer une commande par ID
  Order? getOrderById(int orderId) {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  /// Récupérer une commande par numéro
  Order? getOrderByNumber(String orderNumber) {
    for (final order in _orders) {
      if (order.orderNumber.toLowerCase() == orderNumber.toLowerCase()) {
        return order;
      }
    }
    return null;
  }

  /// Récupérer le timeline d'une commande
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    return await _orderRepository.getOrderTimeline(orderId);
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Annuler la dernière action
  Future<bool> undoLastAction() async {
    try {
      final restored = await _orderRepository.restoreOrdersSnapshot();
      if (restored != null) {
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

  /// Effacer l'erreur
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

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'OrderProvider(status: $_status, orders: ${_orders.length}, '
        'filter: $_currentFilter, active: $activeOrdersCount, '
        'delivered: $deliveredOrdersCount, cancelled: $cancelledOrdersCount)';
  }
}