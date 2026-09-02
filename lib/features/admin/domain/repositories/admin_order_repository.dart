// ============================================
// REPOSITORY INTERFACE : AdminOrderRepository
// ============================================
// Interface définissant le contrat pour la gestion des commandes
// depuis le backoffice administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminOrderRepositoryImpl.
//
// Opérations couvertes :
// - Liste paginée des commandes avec filtres
// - Détails d'une commande
// - Changement de statut
// - Gestion des retours et remboursements
// - Suivi des commandes
// - Statistiques des commandes
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (autres features)
import '../../../orders/domain/entities/order.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des commandes.
///
/// Cette interface définit toutes les opérations de gestion
/// des commandes pour l'administration.
abstract class AdminOrderRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des commandes.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (commence à 1)
  /// - [perPage] : Nombre d'éléments par page (défaut : 20)
  /// - [status] : Filtrer par statut (pending, confirmed, shipped, etc.)
  /// - [paymentStatus] : Filtrer par statut de paiement
  /// - [userId] : Filtrer par client
  /// - [searchQuery] : Recherche par numéro de commande
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  /// - [sortBy] : Champ de tri (created_at, total, status)
  /// - [sortDirection] : Direction du tri (asc, desc)
  ///
  /// Retourne une liste de [Order].
  Future<List<Order>> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
    String? paymentStatus,
    int? userId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortDirection,
  });

  /// Recherche des commandes par numéro.
  ///
  /// Paramètres :
  /// - [query] : Numéro de commande ou nom du client
  /// - [limit] : Nombre maximum de résultats (défaut : 20)
  Future<List<Order>> searchOrders(String query, {int limit = 20});

  /// Récupère les commandes en attente de traitement.
  Future<List<Order>> getPendingOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes confirmées.
  Future<List<Order>> getConfirmedOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes en cours de traitement.
  Future<List<Order>> getProcessingOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes expédiées.
  Future<List<Order>> getShippedOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes livrées.
  Future<List<Order>> getDeliveredOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes annulées.
  Future<List<Order>> getCancelledOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes retournées.
  Future<List<Order>> getReturnedOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les commandes d'un client spécifique.
  ///
  /// Paramètres :
  /// - [userId] : Identifiant du client
  Future<List<Order>> getOrdersByUser(int userId);

  /// Récupère les commandes pour une période donnée.
  ///
  /// Paramètres :
  /// - [startDate] : Date de début
  /// - [endDate] : Date de fin
  Future<List<Order>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une commande par son ID.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la commande
  ///
  /// Retourne un [Order] complet avec items et historique.
  Future<Order?> getOrderById(int id);

  /// Récupère les détails d'une commande par son numéro.
  ///
  /// Paramètres :
  /// - [orderNumber] : Numéro unique de la commande
  Future<Order?> getOrderByNumber(String orderNumber);

  /// Récupère l'historique des statuts d'une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'status': 'pending', 'changed_at': '2026-08-01 10:00', 'note': '...'},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getOrderStatusHistory(int orderId);

  /// Récupère le suivi de livraison d'une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'tracking_number': 'TRACK-123',
  ///   'carrier': 'DHL',
  ///   'status': 'in_transit',
  ///   'current_location': 'Douala',
  ///   'estimated_delivery': '2026-08-15',
  /// }
  /// ```
  Future<Map<String, dynamic>?> getOrderTracking(int orderId);

  // ============================================
  // CHANGEMENT DE STATUT
  // ============================================

  /// Confirme une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> confirmOrder(int orderId);

  /// Marque une commande comme en traitement.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> processOrder(int orderId);

  /// Marque une commande comme expédiée.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  /// - [trackingNumber] : Numéro de suivi (optionnel)
  /// - [carrier] : Transporteur (optionnel)
  Future<bool> shipOrder(int orderId, {String? trackingNumber, String? carrier});

  /// Marque une commande comme livrée.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> deliverOrder(int orderId);

  /// Annule une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  /// - [reason] : Raison de l'annulation
  Future<bool> cancelOrder(int orderId, {String? reason});

  /// Marque une commande comme remboursée.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> refundOrder(int orderId);

  /// Marque une commande comme retournée.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  /// - [reason] : Raison du retour
  Future<bool> returnOrder(int orderId, {String? reason});

  /// Restaure une commande annulée.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> restoreOrder(int orderId);

  // ============================================
  // PAIEMENT
  // ============================================

  /// Marque le paiement comme reçu.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> markPaymentAsPaid(int orderId);

  /// Marque le paiement comme échoué.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> markPaymentAsFailed(int orderId);

  /// Marque le paiement comme remboursé.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<bool> markPaymentAsRefunded(int orderId);

  /// Récupère les paiements d'une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<List<Map<String, dynamic>>> getOrderPayments(int orderId);

  // ============================================
  // NOTES ADMIN
  // ============================================

  /// Ajoute une note admin à une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  /// - [note] : Contenu de la note
  Future<bool> addAdminNote(int orderId, String note);

  /// Récupère les notes admin d'une commande.
  ///
  /// Paramètres :
  /// - [orderId] : Identifiant de la commande
  Future<List<Map<String, dynamic>>> getAdminNotes(int orderId);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de commandes.
  Future<int> getTotalOrdersCount();

  /// Récupère le nombre de commandes par statut.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'pending': 5,
  ///   'confirmed': 10,
  ///   'processing': 8,
  ///   'shipped': 15,
  ///   'delivered': 50,
  ///   'cancelled': 3,
  ///   'refunded': 2,
  ///   'returned': 1,
  /// }
  /// ```
  Future<Map<String, int>> getOrdersCountByStatus();

  /// Récupère le nombre de commandes par statut de paiement.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'pending': 5,
  ///   'paid': 50,
  ///   'failed': 3,
  ///   'refunded': 2,
  /// }
  /// ```
  Future<Map<String, int>> getOrdersCountByPaymentStatus();

  /// Récupère le revenu total des commandes.
  Future<double> getTotalRevenue();

  /// Récupère le revenu moyen par commande.
  Future<double> getAverageOrderValue();

  /// Récupère les commandes les plus récentes.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Order>> getRecentOrders({int limit = 10});

  /// Récupère les commandes avec le montant le plus élevé.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 10)
  Future<List<Order>> getHighestValueOrders({int limit = 10});

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime une commande (soft delete).
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la commande
  Future<bool> deleteOrder(int id);

  /// Restaure une commande supprimée.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la commande
  Future<bool> restoreOrderById(int id);

  /// Supprime définitivement une commande.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la commande
  Future<bool> forceDeleteOrder(int id);

  // ============================================
  // PAGINATION
  // ============================================

  /// Vérifie s'il y a plus de pages à charger.
  ///
  /// Paramètres :
  /// - [page] : Page actuelle
  /// - [perPage] : Nombre d'éléments par page
  Future<bool> hasMoreOrders({required int page, int perPage = 20});

  /// Récupère le nombre total de pages.
  ///
  /// Paramètres :
  /// - [perPage] : Nombre d'éléments par page
  Future<int> getTotalPages({int perPage = 20});
}