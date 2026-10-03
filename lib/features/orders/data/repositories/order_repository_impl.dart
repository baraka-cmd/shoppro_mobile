// ============================================
// IMPLÉMENTATION DU REPOSITORY DES COMMANDES - PREMIUM
// ============================================
// Source principale : API Laravel
// Source secondaire : cache local (fallback offline)
// Gère : lecture, création, annulation, timeline
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';
import '../sources/order_api.dart';
import '../sources/order_local_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderApi _api;
  final OrderLocalDataSource _localDataSource;

  OrderRepositoryImpl({
    OrderApi? api,
    OrderLocalDataSource? localDataSource,
  })  : _api = api ?? OrderApi(),
        _localDataSource = localDataSource ?? OrderLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<Order>> getOrders({String? status}) async {
    try {
      // 1. Récupérer depuis l'API
      final orders = await _api.getOrders(status: status);

      // 2. Mettre à jour le cache local
      await _localDataSource.saveOrders(orders);

      // 3. Retourner (triées par date desc)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      debugPrint('⚠️ API getOrders échouée, fallback cache local: $e');

      // Fallback : lire depuis le cache local
      final cached = await _localDataSource.getOrders();
      cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cached;
    }
  }

  @override
  Future<Order?> getOrderById(int orderId) async {
    try {
      return await _api.getOrderById(orderId);
    } catch (e) {
      debugPrint('⚠️ API getOrderById échouée, fallback local: $e');

      final orders = await _localDataSource.getOrders();
      for (final o in orders) {
        if (o.id == orderId) return o;
      }
      return null;
    }
  }

  @override
  Future<Order?> getOrderByNumber(String orderNumber) async {
    final orders = await _localDataSource.getOrders();
    for (final o in orders) {
      if (o.orderNumber.toLowerCase() == orderNumber.toLowerCase()) {
        return o;
      }
    }
    return null;
  }

  @override
  Future<List<Order>> getOrdersByStatus(String status) async {
    return await getOrders(status: status);
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
    final orders = await getOrders();
    return orders.isNotEmpty;
  }

  @override
  Future<int> getOrdersCount() async {
    final orders = await getOrders();
    return orders.length;
  }

  @override
  Future<int> getActiveOrdersCount() async {
    final orders = await getActiveOrders();
    return orders.length;
  }

  // ============================================
  // CRÉATION (appelle l'API Laravel avec items)
  // ============================================

  @override
  Future<Order> createOrder({
    required int shippingAddressId,
    required List<Map<String, dynamic>> items,
    int? billingAddressId,
    String? shippingMethod,
    String? paymentMethod,
    String? couponCode,
    String? customerNote,
  }) async {
    try {
      // 1. Créer la commande côté serveur Laravel
      final order = await _api.createOrder(
        shippingAddressId: shippingAddressId,
        billingAddressId: billingAddressId,
        shippingMethod: shippingMethod,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        customerNote: customerNote,
        items: items,
      );

      // 2. Ajouter la commande au cache local
      final cached = await _localDataSource.getOrders();
      cached.add(order);
      await _localDataSource.saveOrders(cached);

      debugPrint('✅ Commande créée côté serveur : ${order.orderNumber}');
      return order;
    } catch (e) {
      debugPrint('❌ Erreur createOrder: $e');
      rethrow;
    }
  }

  // ============================================
  // MODIFICATION
  // ============================================

  @override
  Future<Order> updateOrderStatus(int orderId, String status) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Commande introuvable');
    }
    return order;
  }

  @override
  Future<Order> updatePaymentStatus(int orderId, String paymentStatus) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Commande introuvable');
    }
    return order;
  }

  @override
  Future<Order> addTrackingNumber(int orderId, String trackingNumber) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Commande introuvable');
    }
    return order;
  }

  @override
  Future<Order> addAdminNote(int orderId, String note) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Commande introuvable');
    }
    return order;
  }

  // ============================================
  // ANNULATION (appelle l'API Laravel)
  // ============================================

  @override
  Future<bool> canCancelOrder(int orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return order.status != 'shipped' &&
        order.status != 'delivered' &&
        order.status != 'cancelled' &&
        order.status != 'returned';
  }

  @override
  Future<Order> cancelOrder(int orderId, String reason) async {
    if (!await canCancelOrder(orderId)) {
      throw Exception('Cette commande ne peut plus être annulée.');
    }

    try {
      final order = await _api.cancelOrder(orderId, reason);

      final cached = await _localDataSource.getOrders();
      final index = cached.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        cached[index] = order;
        await _localDataSource.saveOrders(cached);
      }

      debugPrint('✅ Commande annulée : ${order.orderNumber}');
      return order;
    } catch (e) {
      debugPrint('❌ Erreur cancelOrder: $e');
      rethrow;
    }
  }

  // ============================================
  // RETOUR
  // ============================================

  @override
  Future<bool> canReturnOrder(int orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    if (order.status != 'delivered') return false;

    final daysSinceDelivery =
        DateTime.now().difference(order.createdAt).inDays;
    return daysSinceDelivery <= 7;
  }

  @override
  Future<Order> returnOrder(int orderId, String reason) async {
    throw UnimplementedError(
      'Le retour de commande nécessite un endpoint API dédié.',
    );
  }

  @override
  Future<Order> returnOrderItem(int orderId, int itemId, String reason) async {
    throw UnimplementedError(
      'Le retour d\'article nécessite un endpoint API dédié.',
    );
  }

  // ============================================
  // TIMELINE
  // ============================================

  @override
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId) async {
    final order = await getOrderById(orderId);

    if (order == null) return [];

    final events = <OrderTimelineEvent>[];

    events.add(OrderTimelineEvent(
      status: 'pending',
      label: 'Commande créée',
      date: order.createdAt,
      isCompleted: true,
    ));

    if (order.status != 'cancelled') {
      events.add(OrderTimelineEvent(
        status: 'confirmed',
        label: 'Commande confirmée',
        date: order.createdAt.add(const Duration(hours: 1)),
        isCompleted: order.status != 'pending',
        isCurrent: order.status == 'confirmed',
      ));

      events.add(OrderTimelineEvent(
        status: 'processing',
        label: 'En préparation',
        date: order.createdAt.add(const Duration(hours: 3)),
        isCompleted: order.status != 'pending' && order.status != 'confirmed',
        isCurrent: order.status == 'processing',
      ));

      events.add(OrderTimelineEvent(
        status: 'shipped',
        label: 'Expédiée',
        date: order.shippedAt ?? order.createdAt.add(const Duration(hours: 6)),
        isCompleted: order.status == 'shipped' || order.status == 'delivered',
        isCurrent: order.status == 'shipped',
      ));

      events.add(OrderTimelineEvent(
        status: 'in_transit',
        label: 'En livraison',
        date: order.shippedAt?.add(const Duration(hours: 12)) ??
            order.createdAt.add(const Duration(hours: 12)),
        isCompleted: order.status == 'delivered',
        isCurrent: order.status == 'delivered',
      ));

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
  // SAUVEGARDE (CACHE LOCAL)
  // ============================================

  @override
  Future<void> saveOrders(List<Order> orders) async {
    await _localDataSource.saveOrders(orders);
  }

  @override
  Future<void> saveOrder(Order order) async {
    final orders = await _localDataSource.getOrders();
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
    final orders = await _localDataSource.getOrders();
    orders.removeWhere((o) => o.id == orderId);
    await _localDataSource.saveOrders(orders);
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearOrders();
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  @override
  Future<List<Order>> syncWithBackend() async {
    try {
      final orders = await _api.getOrders();
      await _localDataSource.saveOrders(orders);
      debugPrint('✅ Synchronisation réussie : ${orders.length} commandes');
      return orders;
    } catch (e) {
      debugPrint('❌ Erreur syncWithBackend: $e');
      return await _localDataSource.getOrders();
    }
  }

  @override
  Future<bool> isOrdersSynced() async {
    try {
      final cached = await _localDataSource.getOrders();
      return cached.isNotEmpty;
    } catch (e) {
      return false;
    }
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
}