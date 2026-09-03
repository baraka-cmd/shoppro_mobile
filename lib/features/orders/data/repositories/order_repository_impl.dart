// ============================================
// IMPLÉMENTATION DU REPOSITORY DES COMMANDES - PREMIUM
// ============================================
// Gère la logique métier des commandes avec
// stockage local, annulation, retour et timeline.
// ============================================

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../sources/order_local_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource _localDataSource;

  OrderRepositoryImpl({OrderLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? OrderLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<Order>> getOrders() async {
    final orders = await _localDataSource.getOrders();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<Order?> getOrderById(int orderId) async {
    final orders = await getOrders();
    for (final order in orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  @override
  Future<Order?> getOrderByNumber(String orderNumber) async {
    final orders = await getOrders();
    for (final order in orders) {
      if (order.orderNumber.toLowerCase() == orderNumber.toLowerCase()) {
        return order;
      }
    }
    return null;
  }

  @override
  Future<List<Order>> getOrdersByStatus(String status) async {
    final orders = await getOrders();
    return orders.where((o) => o.status == status).toList();
  }

  @override
  Future<List<Order>> getActiveOrders() async {
    final orders = await getOrders();
    return orders
        .where((o) =>
            o.status != 'delivered' &&
            o.status != 'cancelled' &&
            o.status != 'returned')
        .toList();
  }

  @override
  Future<List<Order>> getDeliveredOrders() async {
    final orders = await getOrders();
    return orders.where((o) => o.status == 'delivered').toList();
  }

  @override
  Future<List<Order>> getCancelledOrders() async {
    final orders = await getOrders();
    return orders.where((o) => o.status == 'cancelled').toList();
  }

  @override
  Future<List<Order>> getOrdersByDate(DateTime date) async {
    final orders = await getOrders();
    return orders.where((o) {
      return o.createdAt.year == date.year &&
          o.createdAt.month == date.month &&
          o.createdAt.day == date.day;
    }).toList();
  }

  @override
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    final orders = await getOrders();
    return orders.take(limit).toList();
  }

  @override
  Future<bool> hasOrders() async {
    return await _localDataSource.hasOrders();
  }

  @override
  Future<int> getOrdersCount() async {
    return await _localDataSource.getOrdersCount();
  }

  @override
  Future<int> getActiveOrdersCount() async {
    final orders = await getActiveOrders();
    return orders.length;
  }

  // ============================================
  // CRÉATION
  // ============================================

  @override
  Future<Order> createOrder({
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
    final orders = await getOrders();

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch,
      orderNumber: _generateOrderNumber(),
      items: items,
      subtotal: subtotal,
      discount: discount,
      couponDiscount: couponDiscount,
      shippingFee: shippingFee,
      tax: tax,
      total: total,
      status: 'pending',
      paymentStatus: paymentMethod == 'cash_on_delivery' ? 'pending' : 'paid',
      shippingMethod: shippingMethod,
      customerNote: customerNote,
      couponCode: couponCode,
      currency: 'FCFA',
      createdAt: DateTime.now(),
    );

    orders.add(order);
    await _localDataSource.saveOrders(orders);

    return order;
  }

  // ============================================
  // MODIFICATION
  // ============================================

  @override
  Future<Order> updateOrderStatus(int orderId, String status) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(status: status);
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  @override
  Future<Order> updatePaymentStatus(int orderId, String paymentStatus) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(paymentStatus: paymentStatus);
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  @override
  Future<Order> addTrackingNumber(int orderId, String trackingNumber) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(trackingNumber: trackingNumber);
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  @override
  Future<Order> addAdminNote(int orderId, String note) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(adminNote: note);
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  // ============================================
  // ANNULATION
  // ============================================

  @override
  Future<bool> canCancelOrder(int orderId) async {
    final order = await getOrderById(orderId);
    return order != null && order.canCancel;
  }

  @override
  Future<Order> cancelOrder(int orderId, String reason) async {
    if (!await canCancelOrder(orderId)) {
      throw Exception('Cette commande ne peut plus être annulée.');
    }

    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(
        status: 'cancelled',
        cancelledAt: DateTime.now(),
        cancellationReason: reason,
      );
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  // ============================================
  // RETOUR
  // ============================================

  @override
  Future<bool> canReturnOrder(int orderId) async {
    final order = await getOrderById(orderId);
    return order != null && order.canReturn;
  }

  @override
  Future<Order> returnOrder(int orderId, String reason) async {
    if (!await canReturnOrder(orderId)) {
      throw Exception('Cette commande ne peut pas être retournée.');
    }

    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      orders[index] = orders[index].copyWith(status: 'returned');
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  @override
  Future<Order> returnOrderItem(int orderId, int itemId, String reason) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      final updatedItems = orders[index].items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            itemStatus: 'returned',
            isReturned: true,
            returnDate: DateTime.now(),
            returnReason: reason,
          );
        }
        return item;
      }).toList();

      orders[index] = orders[index].copyWith(items: updatedItems);
      await _localDataSource.saveOrders(orders);
      return orders[index];
    }

    throw Exception('Commande introuvable');
  }

  // ============================================
  // TIMELINE
  // ============================================

  @override
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    final order = await getOrderById(orderId);

    if (order == null) {
      return [];
    }

    final events = <OrderTimelineEvent>[];

    // Commande créée
    events.add(OrderTimelineEvent(
      status: 'pending',
      label: 'Commande créée',
      date: order.createdAt,
      isCompleted: true,
    ));

    if (order.status != 'cancelled') {
      // Confirmée
      events.add(OrderTimelineEvent(
        status: 'confirmed',
        label: 'Commande confirmée',
        date: order.createdAt.add(const Duration(hours: 1)),
        isCompleted: order.status != 'pending',
        isCurrent: order.status == 'confirmed',
      ));

      // En préparation
      events.add(OrderTimelineEvent(
        status: 'processing',
        label: 'En préparation',
        date: order.createdAt.add(const Duration(hours: 3)),
        isCompleted: order.status != 'pending' && order.status != 'confirmed',
        isCurrent: order.status == 'processing',
      ));

      // Expédiée
      events.add(OrderTimelineEvent(
        status: 'shipped',
        label: 'Expédiée',
        date: order.shippedAt ?? order.createdAt.add(const Duration(hours: 6)),
        isCompleted: order.status == 'shipped' || order.status == 'delivered',
        isCurrent: order.status == 'shipped',
      ));

      // En livraison
      events.add(OrderTimelineEvent(
        status: 'in_transit',
        label: 'En livraison',
        date: order.shippedAt?.add(const Duration(hours: 12)) ??
            order.createdAt.add(const Duration(hours: 12)),
        isCompleted: order.status == 'delivered',
        isCurrent: order.status == 'delivered',
      ));

      // Livrée
      events.add(OrderTimelineEvent(
        status: 'delivered',
        label: 'Livrée',
        date: order.deliveredAt ?? order.createdAt.add(const Duration(days: 2)),
        isCompleted: order.status == 'delivered',
        isCurrent: false,
      ));
    }

    if (order.status == 'cancelled') {
      events.add(OrderTimelineEvent(
        status: 'cancelled',
        label: 'Annulée',
        date: order.cancelledAt ?? DateTime.now(),
        note: order.cancellationReason,
        isCompleted: true,
      ));
    }

    return events;
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  @override
  Future<void> saveOrders(List<Order> orders) async {
    await _localDataSource.saveOrders(orders);
  }

  @override
  Future<void> saveOrder(Order order) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == order.id);

    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.add(order);
    }

    await _localDataSource.saveOrders(orders);
  }

  @override
  Future<void> deleteOrder(int orderId) async {
    final orders = await getOrders();
    orders.removeWhere((o) => o.id == orderId);
    await _localDataSource.saveOrders(orders);
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  @override
  Future<List<Order>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getOrders();
  }

  @override
  Future<bool> isOrdersSynced() async {
    return true;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> saveOrdersSnapshot() async {
    await _localDataSource.saveOrdersSnapshot();
  }

  @override
  Future<List<Order>> restoreOrdersSnapshot() async {
    return await _localDataSource.restoreOrdersSnapshot() ?? [];
  }

  @override
  Future<void> clearOrdersSnapshot() async {
    await _localDataSource.clearOrdersSnapshot();
  }

  // ============================================
  // GÉNÉRATION DU NUMÉRO DE COMMANDE
  // ============================================

  String _generateOrderNumber() {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'CMD-$dateStr-$random';
  }
}