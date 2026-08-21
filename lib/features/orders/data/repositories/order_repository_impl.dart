// Implémentation du repository des commandes
// Gère la logique métier des commandes avec stockage local

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';
import '../sources/order_local_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource _localDataSource;

  OrderRepositoryImpl({OrderLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? OrderLocalDataSource();

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
      if (order.orderNumber == orderNumber) {
        return order;
      }
    }
    return null;
  }

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
  Future<Order> cancelOrder(int orderId, String reason) async {
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

  @override
  Future<Order> returnOrder(int orderId, String reason) async {
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
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    final order = await getOrderById(orderId);

    if (order == null) {
      return [];
    }

    return [
      OrderTimelineEvent(
        status: 'pending',
        label: 'Commande créée',
        date: order.createdAt,
        isCompleted: true,
      ),
      if (order.status != 'cancelled')
        OrderTimelineEvent(
          status: 'confirmed',
          label: 'Commande confirmée',
          date: order.createdAt.add(const Duration(hours: 1)),
          isCompleted: order.status != 'pending',
        ),
      if (order.status != 'cancelled')
        OrderTimelineEvent(
          status: 'processing',
          label: 'En préparation',
          date: order.createdAt.add(const Duration(hours: 3)),
          isCompleted: order.status != 'pending' && order.status != 'confirmed',
        ),
      if (order.status != 'cancelled')
        OrderTimelineEvent(
          status: 'shipped',
          label: 'Expédiée',
          date: order.shippedAt ?? order.createdAt.add(const Duration(hours: 6)),
          isCompleted: order.status == 'shipped' || order.status == 'delivered',
        ),
      if (order.status == 'delivered')
        OrderTimelineEvent(
          status: 'delivered',
          label: 'Livrée',
          date: order.deliveredAt ?? order.createdAt.add(const Duration(days: 2)),
          isCompleted: true,
        ),
      if (order.status == 'cancelled')
        OrderTimelineEvent(
          status: 'cancelled',
          label: 'Annulée',
          date: order.cancelledAt ?? DateTime.now(),
          note: order.cancellationReason,
          isCompleted: true,
        ),
    ];
  }

  @override
  Future<void> saveOrders(List<Order> orders) async {
    await _localDataSource.saveOrders(orders);
  }

  @override
  Future<List<Order>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getOrders();
  }

  @override
  Future<bool> hasOrders() async {
    return await _localDataSource.hasOrders();
  }

  @override
  Future<int> getOrdersCount() async {
    return await _localDataSource.getOrdersCount();
  }

  // Générer un numéro de commande unique
  String _generateOrderNumber() {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'CMD-$dateStr-$random';
  }
}