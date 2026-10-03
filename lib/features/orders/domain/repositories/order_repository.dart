// ============================================
// INTERFACE DU REPOSITORY DES COMMANDES - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des commandes,
// annulation, retour et timeline.
//
// ⚠️ L'implémentation utilise l'API Laravel
//    comme source principale, avec un cache local.
// ============================================

import '../entities/order.dart';

abstract class OrderRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer toutes les commandes
  /// [status] : filtre optionnel ('pending', 'delivered', etc.)
  Future<List<Order>> getOrders({String? status});

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

  /// Créer une nouvelle commande côté serveur.
  ///
  /// ⚠️ Les articles sont envoyés directement dans la requête.
  ///    Le serveur Laravel ne dépend plus de son panier interne.
  ///
  /// [shippingAddressId] : ID de l'adresse de livraison (obligatoire)
  /// [items] : liste des articles à commander (obligatoire)
  ///           Format : [{ product_id, quantity, variant_id? }]
  /// [billingAddressId] : ID de l'adresse de facturation (optionnel)
  /// [shippingMethod] : 'standard' | 'express' | 'pickup'
  /// [paymentMethod] : 'cash_on_delivery' | 'mobile_money' | 'card'
  /// [couponCode] : code promo (optionnel)
  /// [customerNote] : note du client (optionnel)
  Future<Order> createOrder({
    required int shippingAddressId,
    required List<Map<String, dynamic>> items,
    int? billingAddressId,
    String? shippingMethod,
    String? paymentMethod,
    String? couponCode,
    String? customerNote,
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
  // SAUVEGARDE (CACHE LOCAL)
  // ============================================

  /// Sauvegarder les commandes localement
  Future<void> saveOrders(List<Order> orders);

  /// Sauvegarder une commande
  Future<void> saveOrder(Order order);

  /// Supprimer une commande
  Future<void> deleteOrder(int orderId);

  /// Vider le cache local
  Future<void> clearCache();

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
    return '${date.day}/${date.month}/${date.year} à '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// L'événement a-t-il un lieu ?
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// L'événement a-t-il une note ?
  bool get hasNote => note != null && note!.isNotEmpty;
}