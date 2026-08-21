// Interface du repository des commandes
// Définit le contrat que le repository doit respecter

import '../entities/order.dart';
import '../entities/order_item.dart';

abstract class OrderRepository {
  /// Récupérer toutes les commandes
  Future<List<Order>> getOrders();

  /// Récupérer une commande par ID
  Future<Order?> getOrderById(int orderId);

  /// Récupérer une commande par numéro
  Future<Order?> getOrderByNumber(String orderNumber);

  /// Créer une nouvelle commande
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
  });

  /// Mettre à jour le statut d'une commande
  Future<Order> updateOrderStatus(int orderId, String status);

  /// Annuler une commande
  Future<Order> cancelOrder(int orderId, String reason);

  /// Retourner une commande
  Future<Order> returnOrder(int orderId, String reason);

  /// Récupérer les commandes par statut
  Future<List<Order>> getOrdersByStatus(String status);

  /// Récupérer les commandes en cours
  Future<List<Order>> getActiveOrders();

  /// Récupérer les commandes livrées
  Future<List<Order>> getDeliveredOrders();

  /// Récupérer le suivi d'une commande
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId);

  /// Sauvegarder les commandes localement
  Future<void> saveOrders(List<Order> orders);

  /// Synchroniser avec le backend
  Future<List<Order>> syncWithBackend();

  /// Vérifier si des commandes existent
  Future<bool> hasOrders();

  /// Récupérer le nombre de commandes
  Future<int> getOrdersCount();
}

// Événement de timeline
class OrderTimelineEvent {
  final String status;
  final String label;
  final DateTime date;
  final String? location;
  final String? note;
  final bool isCompleted;

  const OrderTimelineEvent({
    required this.status,
    required this.label,
    required this.date,
    this.location,
    this.note,
    this.isCompleted = false,
  });
}