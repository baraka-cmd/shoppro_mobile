// ============================================
// INTERFACE DU REPOSITORY DES COMMANDES - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des commandes,
// annulation, retour et timeline.
// ============================================

import '../entities/order.dart';
import '../entities/order_item.dart';

abstract class OrderRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer toutes les commandes
  Future<List<Order>> getOrders();

  /// Récupérer une commande par ID
  Future<Order?> getOrderById(int orderId);

  /// Récupérer une commande par numéro
  Future<Order?> getOrderByNumber(String orderNumber);

  /// Récupérer les commandes par statut
  Future<List<Order>> getOrdersByStatus(String status);

  /// Récupérer les commandes en cours
  Future<List<Order>> getActiveOrders();

  /// Récupérer les commandes livrées
  Future<List<Order>> getDeliveredOrders();

  /// Récupérer les commandes annulées
  Future<List<Order>> getCancelledOrders();

  /// Récupérer les commandes par date
  Future<List<Order>> getOrdersByDate(DateTime date);

  /// Récupérer les commandes récentes
  Future<List<Order>> getRecentOrders({int limit = 10});

  /// Vérifier si des commandes existent
  Future<bool> hasOrders();

  /// Récupérer le nombre de commandes
  Future<int> getOrdersCount();

  /// Récupérer le nombre de commandes actives
  Future<int> getActiveOrdersCount();

  // ============================================
  // CRÉATION
  // ============================================

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

  // ============================================
  // MODIFICATION
  // ============================================

  /// Mettre à jour le statut d'une commande
  Future<Order> updateOrderStatus(int orderId, String status);

  /// Mettre à jour le statut de paiement
  Future<Order> updatePaymentStatus(int orderId, String paymentStatus);

  /// Ajouter un numéro de suivi
  Future<Order> addTrackingNumber(int orderId, String trackingNumber);

  /// Ajouter une note admin
  Future<Order> addAdminNote(int orderId, String note);

  // ============================================
  // ANNULATION
  // ============================================

  /// Annuler une commande
  Future<Order> cancelOrder(int orderId, String reason);

  /// Vérifier si une commande peut être annulée
  Future<bool> canCancelOrder(int orderId);

  // ============================================
  // RETOUR
  // ============================================

  /// Retourner une commande
  Future<Order> returnOrder(int orderId, String reason);

  /// Retourner un article spécifique
  Future<Order> returnOrderItem(int orderId, int itemId, String reason);

  /// Vérifier si une commande peut être retournée
  Future<bool> canReturnOrder(int orderId);

  // ============================================
  // TIMELINE
  // ============================================

  /// Récupérer le suivi d'une commande
  Future<List<OrderTimelineEvent>> getOrderTimeline(int orderId);

  // ============================================
  // SAUVEGARDE
  // ============================================

  /// Sauvegarder les commandes localement
  Future<void> saveOrders(List<Order> orders);

  /// Sauvegarder une commande
  Future<void> saveOrder(Order order);

  /// Supprimer une commande
  Future<void> deleteOrder(int orderId);

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Synchroniser avec le backend
  Future<List<Order>> syncWithBackend();

  /// Vérifier si les commandes sont synchronisées
  Future<bool> isOrdersSynced();

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Sauvegarder le snapshot des commandes
  Future<void> saveOrdersSnapshot();

  /// Restaurer le snapshot des commandes
  Future<List<Order>> restoreOrdersSnapshot();

  /// Effacer le snapshot
  Future<void> clearOrdersSnapshot();
}

// ============================================
// ÉVÉNEMENT DE TIMELINE
// ============================================

class OrderTimelineEvent {
  final String status;
  final String label;
  final DateTime date;
  final String? location;
  final String? note;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTimelineEvent({
    required this.status,
    required this.label,
    required this.date,
    this.location,
    this.note,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  /// Formater la date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// L'événement a-t-il un lieu ?
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// L'événement a-t-il une note ?
  bool get hasNote => note != null && note!.isNotEmpty;
}