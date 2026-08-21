// Provider des commandes
// Gère l'état des commandes et les actions

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

  OrderStatus _status = OrderStatus.initial;
  List<Order> _orders = [];
  String? _errorMessage;

  // Getters
  OrderStatus get status => _status;
  List<Order> get orders => _orders;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == OrderStatus.loading;
  bool get isCreating => _status == OrderStatus.creating;
  bool get isUpdating => _status == OrderStatus.updating;
  bool get hasError => _status == OrderStatus.error;
  bool get isEmpty => _orders.isEmpty;
  int get ordersCount => _orders.length;

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

  /// Annuler une commande
  Future<bool> cancelOrder(int orderId, String reason) async {
    _setStatus(OrderStatus.updating);

    try {
      await _orderRepository.cancelOrder(orderId, reason);
      _orders = await _orderRepository.getOrders();
      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Retourner une commande
  Future<bool> returnOrder(int orderId, String reason) async {
    _setStatus(OrderStatus.updating);

    try {
      await _orderRepository.returnOrder(orderId, reason);
      _orders = await _orderRepository.getOrders();
      _setStatus(OrderStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(OrderStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Récupérer une commande par ID
  Order? getOrderById(int orderId) {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  /// Récupérer le timeline d'une commande
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    return await _orderRepository.getOrderTimeline(orderId);
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(OrderStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}